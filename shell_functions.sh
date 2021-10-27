gethash() {
        echo "$1" | md5sum | head -c 32 | xclip -selection clipboard
        exit
}

waitfor() {
    while [ ! -z "$(pgrep $1)" ];
    do
        sleep 1
    done
    shutdown now
}
