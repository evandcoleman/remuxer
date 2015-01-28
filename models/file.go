package models

type File struct {
  Streams     []Stream    `json:"streams"`
  Format      *Format     `json:"format"`
}