package main

import (
  "encoding/json"
  "fmt"
  "log"
  "path/filepath"
  "strconv"
  "strings"

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
    h264Stream := file.H264Stream()
    ac3Stream := file.AC3Stream()
    h264TrackIndex := strconv.FormatInt(h264Stream.Index, 10)
    ac3TrackIndex := strconv.FormatInt(ac3Stream.Index, 10)
    convertArgs := []string{"ffmpeg", "-i", input}
    convertArgs = append(convertArgs, "-map", "0:" + h264TrackIndex)
    convertArgs = append(convertArgs, "-c:v", "copy")
    if h264Stream.Tags != nil {
      if h264Stream.Tags.Language != nil {
        convertArgs = append(convertArgs, "-metadata:s:v:0", fmt.Sprintf("lang='%s'", *h264Stream.Tags.Language))
      }
    }
    totalOutputStreams++
    convertArgs = append(convertArgs, "-map", "0:" + ac3TrackIndex)
    convertArgs = append(convertArgs, "-c:a:0", "aac", "-ab", "160k", "-ac", "2", "-strict", "experimental")
    if ac3Stream.Tags != nil {
      if ac3Stream.Tags.Language != nil {
        convertArgs = append(convertArgs, "-metadata:s:a:1", fmt.Sprintf("lang='%s'", *ac3Stream.Tags.Language))
      }
    }
    totalOutputStreams++
    convertArgs = append(convertArgs, "-map", "0:" + ac3TrackIndex)
    convertArgs = append(convertArgs, "-c:a:1", "copy")
    if ac3Stream.Tags != nil {
      if ac3Stream.Tags.Language != nil {
        convertArgs = append(convertArgs, "-metadata:s:a:2", fmt.Sprintf("lang='%s'", *ac3Stream.Tags.Language))
      }
    }
    totalOutputStreams++

    color.Println("@{!b}Output:")
    color.Printf("\t@{!y}%s:@{|} h264 -> @{!y}0:@{|} copy\n", h264TrackIndex)
    color.Printf("\t@{!y}%s:@{|} ac3 -> @{!y}1:@{|} aac\n", ac3TrackIndex)
    color.Printf("\t@{!y}%s:@{|} ac3 -> @{!y}2:@{|} copy\n", ac3TrackIndex)

    // Copy Vorbis streams
    var audioStreamIndex = 2
    for _, stream := range file.VorbisStreams() {
      convertArgs = append(convertArgs, "-map", fmt.Sprintf("0:%d", stream.Index))
      convertArgs = append(convertArgs, fmt.Sprintf("-c:a:%d", audioStreamIndex), "copy")
      if stream.Tags != nil {
        if stream.Tags.Language != nil {
          convertArgs = append(convertArgs, fmt.Sprintf("-metadata:s:a:%d", audioStreamIndex), fmt.Sprintf("lang='%s'", *stream.Tags.Language))
        }
        if stream.Tags.Title != nil {
          convertArgs = append(convertArgs, fmt.Sprintf("-metadata:s:a:%d", audioStreamIndex), fmt.Sprintf("title='%s'", *stream.Tags.Title))
        }
      }
      color.Printf("\t@{!y}%d:@{|} %s -> @{!y}%d:@{|} copy\n", stream.Index, stream.CodecName, totalOutputStreams)
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
      convertArgs = append(convertArgs, "-map", fmt.Sprintf("0:%d", stream.Index))
      convertArgs = append(convertArgs, fmt.Sprintf("-c:s:%d", subtitleStreamIndex), outputCodec)
      if stream.Tags != nil {
        if stream.Tags.Language != nil {
          convertArgs = append(convertArgs, fmt.Sprintf("-metadata:s:s:%d", subtitleStreamIndex), fmt.Sprintf("lang='%s'", *stream.Tags.Language))
        }
        if stream.Tags.Title != nil {
          convertArgs = append(convertArgs, fmt.Sprintf("-metadata:s:s:%d", subtitleStreamIndex), fmt.Sprintf("title='%s'", *stream.Tags.Title))
        }
      }
      color.Printf("\t@{!y}%d:@{|} %s -> @{!y}%d:@{|} %s\n", stream.Index, stream.CodecName, totalOutputStreams, outputCodec)
      subtitleStreamIndex++
      totalOutputStreams++
    }

    var name = input[0:len(input)-len(filepath.Ext(input))]
    convertArgs = append(convertArgs, "-f", "mp4", name + ".m4v")
    var duration float64 = file.GetDuration()

    // Do the conversion
    reader, convertErr := pipeCommand(convertArgs...)
    if convertErr != nil {
      log.Fatal(convertErr.Error())
    }
    for {
      line, err := reader.ReadString('\r')
      if err != nil {
        break
      }
      if strings.Contains(line, "muxing overhead") {
        color.Println("\r@{!m}Remuxing: @{!r}100%%")
      } else {
        var time float64 = 0
        parts := strings.Split(line, "time=")
        if len(parts) >= 2 {
          timeParts := strings.Split(parts[1], " ")
          if len(timeParts) >= 1 {
            times := strings.Split(timeParts[0], ":")
            hours, _ := strconv.ParseFloat(times[0], 64)
            minutes, _ := strconv.ParseFloat(times[1], 64)
            seconds, _ := strconv.ParseFloat(times[2], 64)
            time = (hours * 60 * 60) + (minutes * 60) + seconds
          }
        }
        var percentage float64 = (time / duration) * 100
        color.Printf("\r@{!m}Remuxing: @{!r}%0.0f%%", percentage)
      }
    }
  },
}