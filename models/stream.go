package models

type Stream struct {
  Index         int64       `json:"index"`
  CodecName     string      `json:"codec_name"`
  CodecType     string      `json:"codec_type"`
  Tags          *Tags       `json:"tags"`
}