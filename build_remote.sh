#!/bin/sh

TARGET_USER=$1 # user
TARGET_ADDRESS=$2 # machine
TARGET_PATH=$3 # where is the flash file?
HOST_PATH=$4 # where is the NEW file?
TMP_DIR=$(mktemp -d)
SSH_CFG=$TMP_DIR/ssh-cfg
SSH_SOCKET=$TMP_DIR/ssh-socket

SOCKET_NAME=esp32-build-vpc1
SOCKET_FILE=/tmp/.ssh-$SOCKET_NAME

# Create a temporary SSH config file:
cat > "$SSH_CFG" <<ENDCFG
Host *
        ControlMaster auto
        ControlPath $SSH_SOCKET
ENDCFG

# Open a SSH tunnel:
if test -f "$SOCKET_FILE"; then
	ssh -S "$SOCKET_FILE" -O exit "$SOCKET_NAME"
fi

ssh -S "$SOCKET_FILE" -M -F "$SSH_CFG" -f -N -l $TARGET_USER $TARGET_ADDRESS

echo "Waiting for build server to compile"

kill_ssh()
{
	echo "Killing ssh tunnel"
	ssh -S "$SOCKET_FILE" -O exit "$SOCKET_NAME"
	exit 0
}

trap kill_ssh SIGINT

while true; do
	ssh -S "$SOCKET_FILE" -F "$SSH_CFG" $TARGET_USER@$TARGET_ADDRESS "echo \"$TARGET_PATH\" | entr -npz sleep 1 && echo 'reflashing'"
	# the following causes a permission error but without it the tunnel dies
	scp -S "$SOCKET_FILE" -F "$SSH_CFG" $TARGET_USER@$TARGET_ADDRESS:"$TARGET_PATH" "$HOST_PATH"
	cargo make run
done
