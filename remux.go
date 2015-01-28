package main

import (
  "encoding/json"
  "fmt"
  "log"
  "path/filepath"
  "strconv"

  "github.com/codegangsta/cli"
  "github.com/edc1591/remuxer/models"
  "github.com/wsxiaoys/terminal/color"
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
    probeArgs := []string{"ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", "-show_streams"}

    input := c.String("input")
    if input != "" {
      color.Println("@{!b}Processing File: @{|}" + input)
      probeArgs = append(probeArgs, input)
    } else {
      log.Fatal("Missing input file.")
    }

    // Probe input file and unmarshal into model
    probeOutput, err := executeCommand(probeArgs...)
    if err != nil {
      log.Fatal(err.Error())
    }
    var file models.File
    err = json.Unmarshal(probeOutput, &file)
    if err != nil {
      log.Fatal(err)
    }
    // Check file validity
    if !file.IsValidMKV() {
      log.Fatal("An MKV file with an x264 and AC3 stream is required.")
    }

    // Print file streams
    color.Println("@{!b}Input:")
    for _, stream := range file.Streams {
      var str = fmt.Sprintf("\t@{!y}%d:@{|} %s, %s", stream.Index, stream.CodecType, stream.CodecName)
      if stream.Tags.Title != nil {
        str += " - " + *stream.Tags.Title
      }
      color.Println(str)
    }

    // Prepare the ffmpeg command arguments
    var totalOutputStreams = 0
    h264TrackIndex := strconv.FormatInt(*file.H264TrackIndex(), 10)
    ac3TrackIndex := strconv.FormatInt(*file.AC3TrackIndex(), 10)
    convertArgs := []string{"ffmpeg", "-i", input}
    convertArgs = append(convertArgs, "-map", "0:" + h264TrackIndex)
    convertArgs = append(convertArgs, "-c:v", "copy")
    totalOutputStreams++
    convertArgs = append(convertArgs, "-map", "0:" + ac3TrackIndex)
    convertArgs = append(convertArgs, "-c:a:0", "aac", "-ab", "160k", "-ac", "2", "-strict", "experimental")
    totalOutputStreams++
    convertArgs = append(convertArgs, "-map", "0:" + ac3TrackIndex)
    convertArgs = append(convertArgs, "-c:a:1", "copy")
    totalOutputStreams++

    color.Println("@{!b}Output:")
    color.Println(fmt.Sprintf("\t@{!y}%s:@{|} h264 -> @{!y}0:@{|} copy", h264TrackIndex))
    color.Println(fmt.Sprintf("\t@{!y}%s:@{|} ac3 -> @{!y}1:@{|} aac", ac3TrackIndex))
    color.Println(fmt.Sprintf("\t@{!y}%s:@{|} ac3 -> @{!y}2:@{|} copy", ac3TrackIndex))

    // Copy Vorbis streams
    var audioStreamIndex = 2
    for _, stream := range file.VorbisStreams() {
      convertArgs = append(convertArgs, fmt.Sprintf("-map", "0:%d", stream.Index))
      convertArgs = append(convertArgs, fmt.Sprintf("-c:a:%d", audioStreamIndex), "copy")
      color.Println(fmt.Sprintf("\t@{!y}%d:@{|} %s -> @{!y}%d:@{|} copy", stream.Index, stream.CodecName, totalOutputStreams))
      audioStreamIndex++
      totalOutputStreams++
    }

    // Copy subtitle streams
    var subtitleStreamIndex = 0
    for _, stream := range file.SubtitleStreams() {
      var outputCodec string
      if stream.CodecName == "subrip" {
        outputCodec = "mov_text"
      } else if stream.CodecName == "mov_text" {
        outputCodec = "copy"
      } else {
        continue
      }
      convertArgs = append(convertArgs, fmt.Sprintf("-map", "0:%d", stream.Index))
      convertArgs = append(convertArgs, fmt.Sprintf("-c:s:%d", subtitleStreamIndex), outputCodec)
      color.Println(fmt.Sprintf("\t@{!y}%d:@{|} %s -> @{!y}%d:@{|} %s", stream.Index, stream.CodecName, totalOutputStreams, outputCodec))
      subtitleStreamIndex++
      totalOutputStreams++
    }

    var name = input[0:len(input)-len(filepath.Ext(input))]
    convertArgs = append(convertArgs, "-f", "mp4", name + ".m4v")

    Do the conversion
    _, convertErr := executeCommand(convertArgs...)
    if convertErr != nil {
      log.Fatal(convertErr.Error())
    }
  },
}