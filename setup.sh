#!/bin/bash

GIT_REPO="captainci-gitlog"
GIT_OWNER="captainci-org"
TMP_DIR="/tmp/${GIT_REPO}"
INST_DIR="/opt/captainci"

echo "${GIT_REPO}: start ... "
echo

# redhat
if [ -f "/etc/redhat-release" ]; then
	DISTNAME="redhat";
	DISTFILE="/etc/redhat-release";

# centos
elif [ -f "/etc/centos-release" ]; then
	DISTNAME="centos";
	DISTFILE="/etc/redhat-release";

# fedora
elif [ -f "/etc/fedora-release" ]; then
	DISTNAME="fedora";
	DISTFILE="/etc/redhat-release";

# debian
elif [ -f "/etc/debian_version" ]; then
	DISTNAME="debian";
	DISTFILE="/etc/debian_version";

# other
elif [ -f "/etc/os-release" ]; then
	DISTNAME=$(cat /etc/os-release  | grep -v "_ID=" | grep "ID=" | cut -d"=" -f2);
	DISTFILE="/etc/os-release";
	
else
	echo "unsupported linux distribution. exit";
	exit;
fi

echo "${GIT_REPO}: distribution ... "
echo "* name: $DISTNAME ";
echo -n "* version: "
cat $DISTFILE 

# install apt for rhel os
if [ "$DISTNAME" = "redhat" ] || [ "$DISTNAME" = "centos" ] || [ "$DISTNAME" = "fedora" ]; then
	echo "* $DISTNAME install apt"
	yum install apt;
fi;

# test if sudo install
if [ ! -f "/usr/bin/sudo" ]; then
	echo "* sudo install"
	apt install sudo
fi;

# test if git install
if [ ! -f "/usr/bin/git" ]; then
	echo "* sudo git"
	sudo apt install git
fi;

echo
cd /tmp/

echo "${GIT_REPO} ... "

echo -n "* clean ... "
sudo rm -rf $TMP_DIR
sudo rm -f /usr/bin/$GIT_REPO
echo " done."

echo -n "* git clone ... "
git clone -q https://github.com/${GIT_OWNER}/${GIT_REPO}.git
echo " done."

echo -n "* create dirs ... "
sudo mkdir -p $INST_DIR/bin/
echo " done."

echo -n "* script install ... "
sudo cp -v $TMP_DIR/*.py $INST_DIR/bin/. | tr -d '\n'
sudo chmod 755 $INST_DIR/bin/*.py
echo " done."

echo -n "* symlink install ... "
sudo rm -f /usr/bin/$GIT_REPO
sudo ln -s $INST_DIR/bin/captainci_gitlog.py /usr/bin/$GIT_REPO
echo " done."

echo -n "${GIT_REPO}: * clean ... "
sudo rm -rf $TMP_DIR
echo " done."

echo
echo "${GIT_REPO}: finish."
