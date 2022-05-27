#! /bin/bash
# script to download audio from youtube and split audio w/ timecodes
# https://www.youtube.com/watch?v=z_CcQhbwINU&list=PL-p5XmQHB_JREOtBfLdKSswBGYyXwXMUy&index=19&t=158s
# https://github.com/LukeSmithxyz/voidrice/blob/master/.local/bin/booksplit

[ ! -f "$2" ] && printf "The first file should be the audio, the second should be the timecodes.\\n" && exit

echo "Enter the album/book title:"; read -r booktitle
echo "Enter the artist/author:"; read -r author
echo "Enter the publication year:"; read -r year

inputaudio="$1"
ext="${1#*.}"

# Get a safe file name from the book.
escbook="$(echo "$booktitle" | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"

! mkdir -p "$escbook" &&
    echo "Do you have write access in this directory?" &&
    exit 1

# Get the total number of tracks from the number of lines.
total="$(wc -l < "$2")"

cmd="ffmpeg -i \"$inputaudio\" -nostdin -y"

while read -r x;
do
    end="$(echo "$x" | cut -d'	' -f1)"
    file="$escbook/$(printf "%.2d" "$track")-$esctitle.$ext"
    if [ -n "$start" ]; then
	cmd="$cmd -metadata artist=\"$author\" -metadata title=\"$title\" -metadata album=\"$booktitle\" -metadata year=\"$year\" -metadata track=\"$track\" -metadata total=\"$total\" -ss \"$start\" -to \"$end\" -vn -c:a copy \"$file\" "
    fi
    title="$(echo "$x" | cut -d'	' -f2-)"
    esctitle="$(echo "$title" | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"
    track="$((track+1))"
    start="$end"
done < "$2"

# Last track must be added out of the loop.
file="$escbook/$(printf "%.2d" "$track")-$esctitle.$ext"
cmd="$cmd -metadata artist=\"$author\" -metadata title=\"$title\" -metadata album=\"$booktitle\" -metadata year=\"$year\" -metadata track=\"$track\" -ss \"$start\" -vn -c copy \"$file\""

eval "$cmd"
