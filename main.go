package main

import (
  "bufio"
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

  output, err := cmd.Output()

  return output, err
}

func pipeCommand(args ...string) (*bufio.Reader, error) {
  cmd := cmdForCommand(args...)

  stderr, _ := cmd.StderrPipe()

  err := cmd.Start()

  reader := bufio.NewReader(stderr)

  return reader, err
}

func printCommand(cmd *exec.Cmd) {
  a := make([]interface{}, len(cmd.Args))
  for i, arg := range cmd.Args {
    a[i] = arg
  }
  log.Println(a...)
}