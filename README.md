# remuxer
Remuxer x264 MKV files into Apple TV Compatible MP4s

# Installation

1. This project uses CocoaPods. After installing CocoaPods, run `pod install` from the project directory
2. Open the workspace and build
3. Copy the built binary to `/usr/local/bin/`
4. Install dependencies using [homebrew](http://brew.sh)
    brew install ffmpeg mp4v2 mkvtoolnix
5. `cd` into a directory with the MKV file(s) you wish to remuxer and run `remuxer`