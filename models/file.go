package models

import "strconv"

type VideoFile interface {
  IsValidMKV() bool
  IsMKV() bool
  HasH264Stream() bool
  HasAC3Stream() bool

  H264Stream() *Stream
  AC3Stream() *Stream

  SubtitleStreams() []Stream
  VorbisStreams() []Stream

  GetDuration() float64
}

type File struct {
  Streams     []Stream    `json:"streams"`
  Format      *Format     `json:"format"`
}

func (f *File) IsValidMKV() bool {
  return f.IsMKV()
}

func (f *File) IsMKV() bool {
  if f.Format == nil {
    return false
  }
  return (f.Format.FormatName == "matroska,webm")
}

func (f *File) HasH264Stream() bool {
  for _, stream := range f.Streams {
    if stream.CodecName == "h264" {
      return true
    }
  }
  return false
}

func (f *File) HasAC3Stream() bool {
  for _, stream := range f.Streams {
    if stream.CodecName == "ac3" {
      return true
    }
  }
  return false
}

func (f *File) HasAACStream() bool {
  for _, stream := range f.Streams {
    if stream.CodecName == "aac" {
      return true
    }
  }
  return false
}

func (f *File) H264Stream() *Stream {
  for _, stream := range f.Streams {
    if stream.CodecName == "h264" {
      return &stream
    }
  }
  return nil
}

func (f *File) AC3Stream() *Stream {
  for _, stream := range f.Streams {
    if stream.CodecName == "ac3" {
      return &stream
    }
  }
  return nil
}

func (f *File) AACStream() *Stream {
  for _, stream := range f.Streams {
    if stream.CodecName == "aac" {
      return &stream
    }
  }
  return nil
}

func (f *File) SubtitleStreams() []Stream {
  subtitleStreams := []Stream{}
  for _, stream := range f.Streams {
    if stream.CodecType == "subtitle" {
      subtitleStreams = append(subtitleStreams, stream)
    }
  }
  return subtitleStreams
}

func (f *File) VorbisStreams() []Stream {
  vorbisStreams := []Stream{}
  for _, stream := range f.Streams {
    if stream.CodecType == "audio" && stream.CodecName == "vorbis" {
      vorbisStreams = append(vorbisStreams, stream)
    }
  }
  return vorbisStreams
}

func (f *File) GetDuration() float64 {
  duration, err := strconv.ParseFloat(f.Format.Duration, 64)
  if err != nil {
    return 0
  }
  return duration
}