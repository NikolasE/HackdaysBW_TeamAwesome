#/bin/bash

# starts the server, then, if there are new commits on the remote, kills the server, pull, restarts the server

set -eux

trap "exit" INT TERM ERR
trap "kill 0" EXIT

sudo -v

export GOOGLE_APPLICATION_CREDENTIALS="/home/ubuntu/key"

sudo -H -E bash -c './main.py &'

while true; do
    git fetch
    NUM_COMMITS_AVAILABLE=$(git rev-list HEAD...origin/master --count)

    if [[ $NUM_COMMITS_AVAILABLE > 0 ]]; then

        git stash
        git pull --rebase
        git stash pop

        sudo killall python3  # lol
        sudo -H -E bash -c './main.py &'
        SERVER_PID=$!
    fi

    sleep 5
    sudo -v
done
