# Setting up a new system

## ssh access to tiny

1. `ssh-keygen -t ed25519 -C "tiny@(hostname)" -f /mnt/home/pi/.ssh/unison-tiny`
2. pub into clipboard
2. `ssh tiny; ecoh "..."  >> ~/.ssh/authorized_keys`

