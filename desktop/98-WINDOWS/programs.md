# Installation

# WSL2

```
wsl --install
```

# Microsoft Store

1. Windows Terminal
2. Microsoft PowerToys
3. Visual Studio Code

# Programs

1. [Python3](https://www.python.org/downloads/)
2. [winXcorners](https://github.com/vhanla/winxcorners/releases)
3. [WinDirStart](https://windirstat.net/download.html)
4. [Flameshot](https://github.com/flameshot-org/flameshot/releases/latest)
5. [Robo3t](https://robomongo.org/download)
6. [DBeaver](https://dbeaver.io/download/)
7. [pgAdmin](https://www.pgadmin.org/download/pgadmin-4-windows/)
8. [Lens](https://k8slens.dev)
9. [Wireshark](https://www.wireshark.org/#download)
10. [OBS Studio](https://obsproject.com/download)
11. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
12. [Vivaldi](https://vivaldi.com)
13. [Patchmypc](https://patchmypc.com/home-updater)
14. [Postman](https://www.postman.com/downloads/)
15. [AHK](https://www.autohotkey.com)


## Ninite

[Ninite](https://ninite.com)

- Chrome
- VLC
- K-Lite Codecs
- Java
- .NET
- Foxit Reader
- FileZilla
- Notepad++
- PuTTY
- 7-Zip

# Developer Tools

1. [Docker](https://www.docker.com/products/docker-desktop)
2. [Chocolatey](https://chocolatey.org/install)
   1. Open PowerShell as Admin
   2. Run **Set-ExecutionPolicy AllSigned**
   3. ``` Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) ```
   
3. [AWS CLI](https://awscli.amazonaws.com/AWSCLIV2.msi)
4. [Git for Windows](https://gitforwindows.org)


## Choco

1. choco install -y openssh
2. choco install -y aws-iam-authenticator

## Kubernetes

1. kubectl
   1. Create new folder under **C:\bin**
   2. Download binary inside the folder 
      1. curl -o kubectl.exe https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/windows/amd64/kubectl.exe
   3. Add **C:\bin** on Windows PATH
      1.  System > Advanced system settings > Advanced > Environment Variables > Path > Edit > New > C:\bin > > Ok

## Sandbox

Add windows sandbox environment

1. Control Panel
2. Programs and Features
   1. Turn Windows features on or off
   2. Enable sandbox and restart computer

![picture 1](../../images/65067858b45866139a2ef25b3c10aea2a9b10509965acc7f8bb8816964fe9072.png)




## Windows11

1. Start11

## Enhance virtual desktops

### Enable app navigation via keyboard

[Copy this](./scripts/window-virtual-desktop-changer.ahk) and [this script](./scripts/super-key-menu-changer.ahk) to `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` or `shell:startup`


