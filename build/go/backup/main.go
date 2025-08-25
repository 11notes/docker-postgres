package main

import (
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"fmt"
	"time"
	"bufio"
	"io"
	"github.com/go-co-op/gocron/v2"
	"strings"
)

const SCHEDULE = "POSTGRES_BACKUP_SCHEDULE"

func main(){
	// catch syscalls
	signalChannel := make(chan os.Signal, 1)
	signal.Notify(signalChannel, syscall.SIGTERM, syscall.SIGSTOP, syscall.SIGINT)
	go func() {
		<- signalChannel
		os.Exit(0)
	}()

	// set backup schedule
	if _, ok := os.LookupEnv(SCHEDULE); ok {
		fmt.Fprintf(os.Stdout, "setting schedule: %s\n", os.Getenv(SCHEDULE))
		scheduler, err := gocron.NewScheduler()
		if err != nil {
			fmt.Fprintf(os.Stderr, "cron error: %s\n", err)
		}
		_, err = scheduler.NewJob(gocron.CronJob(os.Getenv(SCHEDULE), false), gocron.NewTask(backup))
		if err != nil {
			fmt.Fprintf(os.Stderr, "cron error: %s\n", err)
		}
		scheduler.Start()
	}

	// wait for schedule to execute
	select {}
}

func backup(){
	// create new path based on time stamp
	backupPath := fmt.Sprintf("/postgres/backup/%s", time.Now().Format("20060102150405"))

	// check if destination exists already
	if _, err := os.Stat(backupPath); os.IsNotExist(err){

		// prepare pg_basebackup with LZ2 compression
		cmd := exec.Command("pg_basebackup", "--compress","server-lz4","-D",backupPath,"-cfast","-Xfetch","-Ft","-U", "postgres")
		cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid:true}

		stdout, _ := cmd.StdoutPipe()
		stderr, _ := cmd.StderrPipe()

		go func() {
			stdoutScanner := bufio.NewScanner(io.MultiReader(stdout,stderr))
			for stdoutScanner.Scan() {
				stdout := stdoutScanner.Text()
				if ! strings.HasPrefix(stdout, "WARNING:  skipping special file"){
					fmt.Println(stdout)
				}
			}
		}()

		// start backup process
		err := cmd.Start()
		fmt.Printf("starting backup to [%s/base.tar.lz4]\n", backupPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "backup error: %s\n", err)
		}

		err = cmd.Wait()
		if err != nil {
			fmt.Fprintf(os.Stderr, "backup error: %s\n", err)
		}
	}else{
		fmt.Fprintf(os.Stderr, "backup error: target %s exists already\n", backupPath)
	}
}