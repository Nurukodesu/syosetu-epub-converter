#!/bin/bash

set -e

SELF_DIR=$(dirname $(realpath -s $0))
TMP_DIR=$SELF_DIR/tmp

usage () {
    echo "usage:" 
    echo "  $0 <main_url> <from_nth_chapter> <to_nth_chapter>"
    echo ""
    echo "where: "
    echo "  <main_url> is the url of the main page of the book"
    echo "             for example: http://ncode.syosetu.com/n6316bn"
}

if [[ $# != 3 ]]; then
    usage
    exit 1
fi

MAIN_URL="$1"
# remove trailing '/'
MAIN_URL=${1%/}
TXT_OUT="output.txt"
EPUB_OUT="output.epub"
START=$2
END=$3

# IP will be banned for a short time if pages are loaded too fast
SLEEP_TIME=0.1

if [[ -e $TMP_DIR ]]; then
    rm -r $TMP_DIR
fi
mkdir $TMP_DIR

pushd $TMP_DIR > /dev/null

# Load main page
wget -q --user-agent="Mozilla" $MAIN_URL -O main_page.html
sleep $SLEEP_TIME
# <h1 class="p-novel__title">XXX</h1>
NOVEL_TITLE=`pcregrep -Mo '(?s)<h1 class=\"p-novel__title\">.*?</h1>' main_page.html | sed -E 's/<[^>]*>//g'`
# <div class="p-novel__author">...<a ...>XXX</a></div>
WRITER_NAME=`pcregrep -Mo '(?s)<div class=\"p-novel__author\">.*?</div>' main_page.html | grep -Po '<a .*?>.*?</a>' | sed -E 's/<[^>]*>//g'`
# <div id="novel_ex">XXX</div>
NOVEL_SUMMARY=`pcregrep -Mo '(?s)<div id=\"novel_ex\" class=\"p-novel__summary\">.*?</div>' main_page.html | sed -E 's/<[^>]*>//g'`

echo "Found the following novel:"
echo "Title: $NOVEL_TITLE"
echo "Author: $WRITER_NAME"
echo "Summary:"
echo "$NOVEL_SUMMARY"
echo ""

if [[ -e $TXT_OUT ]]; then
    rm $TXT_OUT
fi
touch $TXT_OUT

echo "% $NOVEL_TITLE" >> $TXT_OUT
echo "% $WRITER_NAME" >> $TXT_OUT
echo "$NOVEL_SUMMARY" >> $TXT_OUT
# 2 empty lines
echo "" >> $TXT_OUT
echo "" >> $TXT_OUT

for chapter_page in $(seq $START $END); do
    wget -q --user-agent="Mozilla" $MAIN_URL/$chapter_page -O $chapter_page.html
    sleep $SLEEP_TIME
    # <h1 class="p-novel__title p-novel__title--rensai">XXX</h1>
    chapter_title=`pcregrep -Mo '(?s)<h1 class=\"p-novel__title p-novel__title--rensai\">.*?</h1>' $chapter_page.html | sed -E 's/<[^>]*>//gi'`
    # <div class="js-novel-text p-novel__text"><p id="L1">XXX</p><p id="L2">XXX</p>...</div>
    chapter_paragraph=`pcregrep --buffer-size=100K -Mo '(?s)<div class=\"js-novel-text p-novel__text\">.*?</div>' $chapter_page.html | grep -P '<p id=\"L[0-9]+\">.*?</p>'`
    echo "$chapter_title"
    echo "# $chapter_title" >> $TXT_OUT
    echo "" >> $TXT_OUT
    printf %s "$chapter_paragraph" |
    while IFS= read -r paragraph; do
        # parse image (if any)
        if [[ `echo $paragraph | grep -Po "<img .*/>"` ]]; then
            image=`echo $paragraph | grep -Po "<img .*/>"`
            line_id=`echo $paragraph | sed -E 's/^.*<p id=\"([^"]*)\">.*$/\1/g'`
            image_path=`echo $image | sed -E 's/^.*src=\"([^"]*)\".*$/\1/g'`
            image_name=`echo $image | sed -E 's/^.*alt=\"([^"]*)\".*$/\1/g'`
            wget -q --user-agent="Mozilla" http:$image_path -O ${chapter_page}_${line_id}.jpg
            sleep $SLEEP_TIME
            paragraph=`echo $paragraph | sed -E 's/<img [^>]*>/!['"$image_name"']('"${chapter_page}_${line_id}.jpg"')/g'`
        fi
		# add furigana
		text=`echo $paragraph | sed -E -e 's/<rp>（/<rp>(/g' -e 's/<rp>）/<rp>)/g' -e 's/<rt>[^<\/rt>]*/-&/g' -e 's/<ruby>[^<rt>]*/[&]/g' -e 's/<[^>]*>//g' -e 's/&quot;/"/g'`
        # double space = new line
        echo "$text  " >> $TXT_OUT
    done
    # 2 empty lines
    echo "" >> $TXT_OUT
    echo "" >> $TXT_OUT
done
echo ""

if [[ -e $EPUB_OUT ]]; then
    rm $EPUB_OUT
fi

echo "Convert raw txt to epub"
pandoc -F $SELF_DIR/furigana.py $TXT_OUT -o $EPUB_OUT

cp $TXT_OUT $SELF_DIR
cp $EPUB_OUT $SELF_DIR

echo "Done"

popd > /dev/null
rm -r $TMP_DIR
