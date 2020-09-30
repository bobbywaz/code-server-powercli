# Microsoft VS Code Server running in a browser with support for Powershell and PowerCLI
#
# To build this image, run:
#
#   docker login
#   docker build . -t {docker_username}/{tag_key}:{tag_value}
#   docker push {docker_username}/{tag_key}:{tag_value}
#
# For example:
#
#   docker login
#       If you receieve error `Cannot autolaunch D-Bus without X11 $DISPLAY`, it is trying to use a GUI credential helper, install "pass" using "sudo apt-get install pass gnupg2".
#   docker build . -t bobbywaz/vscode-pwsh:stable
#   docker push bobbywaz/vscode-pwsh:stable
#   Download base image for LinuxServer vscode
FROM linuxserver/code-server
#   LABEL
LABEL maintainer="bobbyw@gmail.com"
LABEL version="0.1"
LABEL description="This is a custom image for running vscode with PowerShell and PowerCLI installed"
#   Set Working directory
WORKDIR /root
#   Update repos and install wget
RUN apt update && apt install wget -y
#   Upgrade all software
RUN sudo apt-get upgrade -y
#   Install requirement that won't install automatically
RUN sudo apt-get install -y liblttng-ust0 libicu60
#   Get powershell installation
RUN wget -O /root/powershell.deb https://github.com/PowerShell/PowerShell/releases/download/v7.0.3/powershell_7.0.3-1.ubuntu.18.04_amd64.deb
#   Install Powershell and exit with code 0 due to missing dependencies && Force Powershell installation after dkpg errors
RUN sudo dpkg -i /root/powershell.deb
#   Install curl
# RUN sudo apt-get install curl -y
#   Start Powershell
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
#   Install PowerCLI
RUN Install-Module -Name VMware.PowerCLI -force
#   Configure PoweCLI settings
RUN Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DefaultVIServerMode Multiple -DisplayDeprecationWarnings $false -Confirm:$false
#   Entry point
 ENTRYPOINT ["/init"]