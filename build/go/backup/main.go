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
	"strconv"
	"slices"

	"github.com/11notes/go/util"
)

const SCHEDULE = "POSTGRES_BACKUP_SCHEDULE"
const RETENTION = "POSTGRES_BACKUP_RETENTION"

var (
	retentionPoints int = 0
)

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
		util.Log("inf", "setting schedule: " + os.Getenv(SCHEDULE))
		scheduler, err := gocron.NewScheduler()
		if err != nil {
			util.Log("err", "cron error: " + err.Error())
		}
		_, err = scheduler.NewJob(gocron.CronJob(os.Getenv(SCHEDULE), false), gocron.NewTask(backup))
		if err != nil {
			util.Log("err", "cron error: " + err.Error())
		}
		scheduler.Start()
	}

	// set retention
	if s, ok := os.LookupEnv(RETENTION); ok {
		if i, err := strconv.Atoi(s); err == nil {
			retentionPoints = i
			util.Log("inf", fmt.Sprintf("setting retention to last %d point(s)", retentionPoints))
		}
	}
	if(retentionPoints <= 0){
		util.Log("inf", "disable retention")
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
					util.Log("inf", stdout)
				}
			}
		}()

		// start backup process
		err := cmd.Start()
		if err != nil {
			util.Log("err", "backup error: " + err.Error())
		}else{
			err = cmd.Wait()
			if err != nil {
				util.Log("err", "backup error: " + err.Error())
			}else{
				// backup complete
				if _, err := os.Stat(fmt.Sprintf("%s/%s", backupPath, "base.tar.lz4")); !os.IsNotExist(err){
					util.Log("inf", fmt.Sprintf("backup to %s complete", backupPath))
					if(retentionPoints > 0){
						retention()
					}
				}else{
					util.Log("err", "backup error: " + err.Error())
				}
			}
		}
	}else{
		util.Log("err", fmt.Sprintf("backup error: target %s exists already", backupPath))
	}
}

func retention(){
	ls, err := os.ReadDir("/postgres/backup")
	if err != nil {
		util.Log("err", "retention error: " + err.Error())
	}else{
		var backups []string
		for _, e := range ls {
			if e.IsDir() {
				backups = append(backups, "/postgres/backup/" + e.Name())
			}
		}
		slices.Sort(backups)
		slices.Reverse(backups)
		if(len(backups) > 0){
			if(len(backups) > retentionPoints){
				// check retention settings
				keep := backups[0:retentionPoints]
				util.Log("inf", fmt.Sprintf("backup(s) in retention [%d]: %v", len(keep), keep))
				remove := backups[retentionPoints:]
				if(len(remove) > 0){
					for _, backup := range remove {
						os.RemoveAll(backup)
					}
					util.Log("inf", fmt.Sprintf("backups deleted [%d]: %v", len(remove), remove))
				}
			}else{
				// no retention needed
				util.Log("inf", fmt.Sprintf("backup(s) in retention [%d]: %v", len(backups), backups))
			}
		}
	}
}