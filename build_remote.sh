#!/bin/sh

TARGET_USER=$1 # user
TARGET_ADDRESS=$2 # machine
TARGET_PATH=$3 # where is the flash file?
HOST_PATH=$4 # where is the NEW file?
TMP_DIR=$(mktemp -d)
SSH_CFG=$TMP_DIR/ssh-cfg
SSH_SOCKET=$TMP_DIR/ssh-socket

# Create a temporary SSH config file:
cat > "$SSH_CFG" <<ENDCFG
Host *
        ControlMaster auto
        ControlPath $SSH_SOCKET
ENDCFG

# Open a SSH tunnel:
ssh -F "$SSH_CFG" -f -N -l $TARGET_USER $TARGET_ADDRESS

while true; do
	ssh -F "$SSH_CFG" $TARGET_USER@$TARGET_ADDRESS "echo \"$TARGET_PATH\" | entr -npz sleep 1 && echo 'reflashing'"
	scp -F "$SSH_CFG" $TARGET_USER@$TARGET_ADDRESS:"$TARGET_PATH" "$HOST_PATH"
	cargo make run
done
