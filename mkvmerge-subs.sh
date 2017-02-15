#!/bin/sh
die () {
    echo >&2 "$@"
    exit 1
}

# Validate arguments
[ "$#" -eq 1 ] || die "Usage: $0 <path-to-srt>"
[ -e "$1" ] || die "File $1 does not exist."

# Find the associated MKV file and make sure it exists
fullfile="$1"
srtfile="${fullfile##*/}"
mkvfile="${srtfile%.*}.mkv"
tmpfile="${srtfile%.*}-subs.mkv"
path="${fullfile%/*}"
[ -e "$path/$mkvfile" ] || die "Video file $mkvfile does not exist."

# Make sure that docker is installed
docker -v >/dev/null 2>&1 || die "Docker is not installed"

# Run a docker container to mkvmerge the subtitles in
docker run --name "mkvmerge-subs" -v "$path":/source -w /source -it moul/mkvtoolnix mkvmerge -o /source/"$tmpfile" "$mkvfile" "$srtfile"
docker rm "mkvmerge-subs"

# Remove the original mkvfile and replace it with the merged file
rm "$path/$mkvfile"
mv "$path/$tmpfile" "$path/$mkvfile"