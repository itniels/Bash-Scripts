#!/bin/bash
#####################################################################
# LetsEncryptProxmox For proxmox VE 4
# created by Niels Schmidt - 2016
# it.niels@gmail.com
# Read more here: 
#
# I take no resposibility what so ever for any damages or dataloss
# that may occur using this script, it is your own resosibility.
#####################################################################

_clustername=$1
_hostname=$2
_sslbackupdir="/etc/pve/sslbackup"
# Lets Encrypt cert paths
_certKey="/etc/letsencrypt/live/$_hostname/privkey.pem"
_certFullChain="/etc/letsencrypt/live/$_hostname/fullchain.pem"
_certChain="/etc/letsencrypt/live/$_hostname/chain.pem"
# To be replaced paths
_proxNodeKey="/etc/pve/nodes/$_clustername/pve-ssl.key"
_proxNodePem="/etc/pve/nodes/$_clustername/pve-ssl.pem"
_proxLocalKey="/etc/pve/local/pve-ssl.key"
_proxLocalPem="/etc/pve/local/pve-ssl.pem"
_proxChainPem="/etc/pve/pve-root-ca.pem"

# Exit if Node not setup
if [ $_clustername == "" ]; then
	echo "LetsEncryptProxmox.sh <srv> <srv.example.com>"
	exit 1
fi

# Exit if Hostname name not setup
if [ $_hostname == "" ]; then
	echo "LetsEncryptProxmox.sh <srv> <srv.example.com>"
	exit 1
fi

# Check if we need to take a backup of proxmox first
if [ ! -d $_sslbackupdir ]; then
	echo "Backing up proxmox"
	mkdir -p $_sslbackupdir/local
	mkdir -p $_sslbackupdir/node
	
	cp $_proxChainPem $_sslbackupdir/pve-root-ca.pem
	cp $_proxNodeKey $_sslbackupdir/node/pve-ssl.key
	cp $_proxLocalKey $_sslbackupdir/local/pve-ssl.key
	cp $_proxNodePem $_sslbackupdir/node/pve-ssl.pem
	cp $_proxLocalPem $_sslbackupdir/local/pve-ssl.pem
fi

# Update certificate
echo "Updating certificate"
certbot certonly --standalone -d $_hostname

# Copy certs
echo "Writting certificates to proxmox"
cat $_certChain > $_proxChainPem
cat $_certKey > $_proxNodeKey
cat $_certKey > $_proxLocalKey
cat $_certFullChain > $_proxNodePem
cat $_certFullChain > $_proxLocalPem

# restart proxmox
echo "Restarting proxmox service"
service pveproxy restart && service pvedaemon restart

# Exit
echo "All done! :-)"
exit 0