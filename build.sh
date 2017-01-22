#!/bin/bash

ROOTDIR=$(cd $(dirname $0) && pwd)

GOLANG_VERSION=1.4.1
GITLAB_CE_VERSION=8.15.2-ce.0_amd64
DEBIAN_NFS_SERVER_VERSION=1.2.5-3ubuntu3_amd64

mkdir -p $ROOTDIR/.downloads

set -x

#GITLAB_CE
cd $ROOTDIR/.downloads
GITLAB_CE_TAR=gitlab-ce_${GITLAB_CE_VERSION}.deb
if [ ! -e ${GITLAB_CE_TAR} ]; then
    GITLAB_CE_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/${GITLAB_CE_TAR}/download
    wget -O ${GITLAB_CE_TAR} ${GITLAB_CE_URL} 
    cd $ROOTDIR
    bosh add blob $ROOTDIR/.downloads/${GITLAB_CE_TAR} gitlab-ce
else
    cd $ROOTDIR
fi
bosh add blob $ROOTDIR/patch/fix_gitlab_shell_path.patch gitlab-ce

#Golang
cd $ROOTDIR/.downloads
GOLANG_TAR=go${GOLANG_VERSION}.linux-amd64.tar.gz
if [ ! -e ${GOLANG_TAR} ]; then
    GOLANG_URL=http://www.golangtc.com/static/go/1.4.1/${GOLANG_TAR}
    wget ${GOLANG_URL}
    cd $ROOTDIR
    bosh add blob $ROOTDIR/.downloads/${GOLANG_TAR} go
else
    cd $ROOTDIR
fi

#NFS
cd $ROOTDIR/.downloads
NFS_TAR=nfs-kernel-server_${DEBIAN_NFS_SERVER_VERSION}.deb
if [ ! -e ${NFS_TAR} ]; then
    NFS_URL=http://ubuntu.mirrors.tds.net/ubuntu/pool/main/n/nfs-utils/${NFS_TAR}
    wget ${NFS_URL}
    cd $ROOTDIR
    bosh add blob $ROOTDIR/.downloads/${NFS_TAR} debian_nfs_server
else
    cd $ROOTDIR
fi

bosh add blob $ROOTDIR/patch/utils.sh common

bosh create release --with-tarball --force
