package main

import (
  "encoding/json"
  "log"

  "github.com/codegangsta/cli"
  "github.com/edc1591/remuxer/models"
)

var remuxCommand = cli.Command{
  Name:  "remux",
  Usage: "Remux an AC3 x264 MKV file into an MP4 with AAC and AC3 audio tracks.",
  Flags: []cli.Flag{
    cli.StringFlag{
      Name:  "input, i",
      Usage: "The input file.",
    },
  },
  Action: func(c *cli.Context) {
    args := []string{"ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", "-show_streams"}

    if input := c.String("input"); input != "" {
      args = append(args, input)
    } else {
      log.Fatal("Missing input file.")
    }

    output, err := executeCommand(args...)
    if err != nil {
      log.Fatal(err.Error())
    }

    var file models.File
    err = json.Unmarshal(output, &file)
    if err != nil {
      log.Fatal(err)
    }
    if !file.IsValidMKV() {
      log.Fatal("An MKV file with an x264 and AC3 stream is required.")
    }
  },
}