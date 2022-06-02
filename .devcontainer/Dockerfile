FROM mcr.microsoft.com/powershell:ubuntu-20.04
RUN pwsh -noprofile -noninteractive -c 'Register-PSRepository -Default -InstallationPolicy Trusted'
RUN pwsh -noprofile -noninteractive -c 'Install-Module PowershellGet -Scope AllUsers -AllowPrerelease -Force;Install-Module Pester -Scope AllUsers -Verbose'
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get install wget
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get -y update
RUN apt-get install -y apt-transport-https
RUN apt-get install -y dotnet-sdk-3.1