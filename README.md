# remuxer
Remuxer x264 MKV files into Apple TV Compatible MP4s

Remuxer will take an x264/ac3 MKV file and output an mp4 file with the same streams plus a stereo AAC stream. Subtitle and vorbis commentary streams will also be copied.

If `Dolby Digital Out` is enabled on the Apple TV, the 5.1 ac3 track will passthrough to your receiver.

# Installation

1. This project uses CocoaPods. After installing CocoaPods, run `pod install` from the project directory
2. Open the workspace and build
3. Copy the built binary to `/usr/local/bin/`
4. Install dependencies using [homebrew](http://brew.sh)

        brew install ffmpeg mp4v2 mkvtoolnix
5. `cd` into a directory with the MKV file(s) you wish to remuxer and run `remuxer`

# Caveats

A few assumptions are made about the input file.

1. The first audio track in the file is the AC3 audio track
2. I thought there were more assumptions