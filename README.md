# remuxer
Remuxer x264 MKV files into Apple TV Compatible MP4s

Remuxer will take an x264/ac3 MKV file and output an mp4 file with the same streams plus a stereo AAC stream. Subtitle and vorbis commentary streams will also be copied.

If `Dolby Digital Out` is enabled on the Apple TV, the 5.1 ac3 track will passthrough to your receiver.

The old Objective-C version can be found in the `ec-legacy` branch.

# Installation

    $ brew install ffmpeg
    $ go get github.com/brettaweston/remuxer

# Usage

    $ remuxer remux -i /path/to/video.mkv
