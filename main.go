package main

import (
  "log"
  "os"
  "os/exec"
  
  "github.com/codegangsta/cli"
)

func main() {
  app := cli.NewApp()
  app.Name = "remuxer"
  app.Usage = "A tool to easily remux x264 MKV files into an Apple TV compatible format."
  app.EnableBashCompletion = true
  app.Commands = []cli.Command{
    remuxCommand,
  }
  app.Run(os.Args)
}

func cmdForCommand(args ...string) *exec.Cmd {
  cmd := exec.Command(args[0], args[1:]...)
  printCommand(cmd)

  return cmd
}

func executeCommand(args ...string) ([]byte, error) {
  cmd := cmdForCommand(args...)

  cmd.Stdin = os.Stdin
  cmd.Stderr = os.Stderr

  output, err := cmd.Output()

  return output, err
}

func printCommand(cmd *exec.Cmd) {
  a := make([]interface{}, len(cmd.Args))
  for i, arg := range cmd.Args {
    a[i] = arg
  }
  log.Println(a...)
}