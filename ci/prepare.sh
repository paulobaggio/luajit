#!/bin/bash

VER=$(rpm -qf --queryformat '%{version}\n' /etc/system-release)
case $VER in
    "6")
        yum install -y epel-release
        yum update -y

    ;;
    "7")
        yum install -y epel-release
        yum update -y

    ;;
    *)
        echo "I don't know this distro. Grab me a CentOS 6 or 7 ¯\_(ツ)_/¯"
        exit 1
    ;;
esac

case $1 in
    "build")
        yum install -y  \
            gcc         \
            git         \
            make        \
            rpm-build   \
            spectool 
    ;;
    *)
        echo "What do you mean by $1? I understand only 'build'. Say 'build', please."
        exit 1
    ;;
esac

yum clean all -y

