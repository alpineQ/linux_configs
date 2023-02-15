gethash() {
        echo "$1" | md5sum | head -c 32 | xclip -selection clipboard
        exit
}

waitfor() {
    while [ -n "$(pgrep "$1")" ];
    do
        sleep 1
    done
    shutdown now
}

git_fetch_upstream() {
	if (( $# < 1 )); then
		echo "Usage: $0 <branch>"
		return
	fi
	git checkout "$1"
	git fetch upstream
	git merge "upstream/$1"
}
	
git_partial_checkout() {
	if (( $# < 2 )); then
		echo "Usage: $0 <git_repo> <checkout_dir>"
		return
	fi
	git clone --depth 1 --filter=tree:0 --sparse "$1" "$2"
	cd "$2" && git sparse-checkout set "$2" && cd ..
	TEMPORARY_DIRECTORY=$(mktemp -u)
	mv "$2" "$TEMPORARY_DIRECTORY" && mv "$TEMPORARY_DIRECTORY/$2" "$2"
}
