#!/usr/bin/env bash

if [[ ! "$IN_NIX_SHELL" ]] && type -P nix-shell >/dev/null
then
    exec nix-shell --run "$0 $*"
fi

cmds="$@"
gist=$(cat ./scala/GIST_ID)

_msg() {
    echo -e "\nBUILD: $1"
}

_clean_all() {
    rm -rf ./html
}

_copy_static() {
    rm -rf ./html/static
    mkdir -p ./html
    cp -R ./doc/static ./html/
}

_org_html() {
    _msg 'Generate from Org files'
    rm -rf ./html
    _copy_static
    emacs --batch -Q -l .orgen/orgen.el -f orgen-noninteractive-publish
}

_push_github() {
    _msg 'Push to Github'
    (cd ./html && git add -A && git commit -m Render && git push github master)
}

_push_firebase() {
    _msg 'Push to Firebase'
    if [[ -z "$FIREBASE_TOKEN" ]]
    then
        firebase deploy --token "$FIREBASE_TOKEN"
    else
        firebase deploy
    fi
}

_push() {
    _push_firebase
}

_caddy() {
    _msg 'Serve with Caddy'
    (cd ./html && exec caddy -port 8000)
}

_help() {
    echo 'COMMANDS:'
    echo '  copy-static    copy static files to output'
    echo '  make           generate output from org files'
    echo '  push           default push (push-gist && push-firebase)'
    echo '  push-github    push site to github'
    echo '  push-firebase  push site to firebase including src archives'
    echo '  serve          serve generated HTML using Caddy'
    echo '  clean-all      remove all generated files'
    echo '  help           this message'
}

_dispatch() {
    case "$1" in
        copy-static)
            _copy_static || exit 1
            ;;
        make)
            _org_html || exit 1
            ;;
        push-github)
            _push_github || exit 1
            ;;
        push-firebase)
            _push_firebase || exit 1
            ;;
        push)
            _push || exit 1
            ;;
        serve)
            _caddy
            ;;
        clean-all)
            _clean_all || exit 1
            ;;
        help)
            _help
            ;;
    esac
}

_go() {
    [[ -z "$cmds" ]] && cmds='make-html'
    for cmd in $cmds
    do
        _dispatch "$cmd"
    done
}

_go
