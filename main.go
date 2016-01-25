package main

import (
	"bufio"
	"fmt"
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

func cmdForCommand(verbose bool, args ...string) *exec.Cmd {
	cmd := exec.Command(args[0], args[1:]...)

	if verbose {
		printCommand(cmd)
	}

	return cmd
}

func executeCommand(verbose bool, args ...string) ([]byte, error) {
	cmd := cmdForCommand(verbose, args...)

	cmd.Stdin = os.Stdin

	output, err := cmd.Output()

	return output, err
}

func pipeCommand(verbose bool, args ...string) (*bufio.Reader, error) {
	cmd := cmdForCommand(verbose, args...)

	stderr, _ := cmd.StderrPipe()

	if verbose {
		cmd.Stderr = os.Stderr
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin
	}

	err := cmd.Start()

	reader := bufio.NewReader(stderr)

	return reader, err
}

func printCommand(cmd *exec.Cmd) {
	a := make([]interface{}, len(cmd.Args))
	for i, arg := range cmd.Args {
		a[i] = arg
	}
	fmt.Println(a...)
}
