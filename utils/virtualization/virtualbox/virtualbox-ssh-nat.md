VBoxManage modifyvm "kali" --natpf1 "SSH,tcp,127.0.0.1,2522,10.0.2.15,22"

ssh -p 2522 rtm@localhost
