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
	// syscalls
	signalChannel := make(chan os.Signal, 1)
	signal.Notify(signalChannel, syscall.SIGTERM, syscall.SIGSTOP, syscall.SIGINT)

	// event listener
	go func() {
		<- signalChannel
		os.Exit(0)
	}()

	// set schedule
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
	files := fmt.Sprintf("/postgres/backup/%s", time.Now().Format("20060102150405"))
	cmd := exec.Command("pg_basebackup", "--compress","server-lz4","-D",files,"-cfast","-Xfetch","-Ft","-U", "postgres")
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

	err := cmd.Start()
	fmt.Printf("starting backup to [%s/base.tar.lz4]\n", files)
	if err != nil {
		fmt.Fprintf(os.Stderr, "backup error: %s\n", err)
	}

	err = cmd.Wait()
	if err != nil {
		fmt.Fprintf(os.Stderr, "backup error: %s\n", err)
	}
}