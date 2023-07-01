
# TODO: Need to create user who desktop is accessible from so I no longer need to log in as root

install_vs_code () {

    sudo apt-get install wget gpg -y
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https -y
    sudo apt update
    sudo apt install code -y

}


install_docker () {

    sudo apt-get update
    sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        -y

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

}


install_terraform () {

    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install terraform

} 


install_desktop_and_remote () {

    sudo apt update 
    sudo apt upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install xfce4 -y
    sudo apt install xfce4-goodies -y
    sudo apt install xrdp -y
    sudo systemctl status xrdp
    sudo systemctl start xrdp
    echo -e "root\nroot" | (sudo passwd root)
    sudo adduser andrew --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo "andrew:andrew" | sudo chpasswd
    # Allow any user to access desktop
    sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

}


install_desktop_and_remote
install_docker
install_vs_code
install_terraform
sudo apt install firefox-esr
