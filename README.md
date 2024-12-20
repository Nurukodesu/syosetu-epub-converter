
# Yomou2ebook
小説を読もう (https://syosetu.com/) is a Japanese website that publishes novels for free. It is possible to read novels online and to download them as a pdf. However, it is not possible possible to download the novels as a epub or text file. This is very incovenient as the pdf file cannot be converted easily into another format. It is even more annoying that most ebook readers won't be able to read the file properly.

This script is meant to solve the issue: it will download a whole novel from the website as a text file and convert it to the epub format.


## Requirements
Tested on Linux, but it should also work on Mac OS. For Windows, please install and use a Windows Subsystem for Linux (or equivalent)

Extra requirements:
- pandoc: to convert txt -> epub
- pandocfilters: for furigana


## How to use
Usage is as follow:
```bash
./yomou2ebook.sh <main_url> <from> <to>
```
where: `<main_url>` is the url of the main page of the book,
                 for example: http://ncode.syosetu.com/n6316bn
        <from> chapter to <to> chapter

For example, to download 転生したらスライムだった件 (http://ncode.syosetu.com/n6316bn) from chapter 1 to 10, simply run:
```bash
./yomou2ebook.sh http://ncode.syosetu.com/n6316bn　1 10
```

An output.txt file will be created, then converted into an output.epub file 
![example](https://raw.githubusercontent.com/vingtfranc/yomou2ebook/master/example.png)


## Limitations
Not supported (yet):
 


## Troubleshoot
I only tested this script on a few novels. I cannot garantee it will work on all of them. Also, the script may stop working overnight if the website gets an update. If you have any trouble feel free to open a new issue.


## Similar projects
- https://github.com/whiteleaf7/narou
