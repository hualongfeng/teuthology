#!/bin/bash

#echo $@

machine=$1

execute_command="sudo rm -rf cephtest; \
		 sudo rm -rf /var/lib/ceph; \
		 sudo rm -rf /etc/ceph; \
		 sudo rm -rf /etc/apt/sources.list.d/ceph.list; \
		 sudo rm -rf /var/log/ceph; \
                 sudo rm -rf /etc/logrotate.d/ceph; \
                 sudo rm -rf /usr/share/ceph; \
		 sudo rm -rf /var/run/ceph; \
		 sudo apt-get -yqq purge ceph > /dev/null; \
		 sudo apt-get -yqq autoremove > /dev/null; \
		 "

function wait_startup() {
	machine_name=$(echo $machine | awk -F"@" '{print $2}')
	user_name=$(echo $machine | awk -F"@" '{print $1}')
	until [ $(ping $machine_name -c 1 | grep received | awk '{print $4}') -eq 1 ]
	do
		echo -n "="
		sleep 1
	done
	status=1
	until [ $status -eq 0 ]
	do
		ssh $1 "echo SSH connection is OK" 2>>/dev/null
		status=$?
		sleep 1
	done
}

for i in $(seq 1 3)
do
#	echo $i
	ssh ${machine} $execute_command 1>>/dev/null 2>&1
	ssh ${machine} "sudo apt-get remove -yqq --purge ceph" 1>>/dev/null 2>&1
	ssh ${machine} "sudo apt-get remove -yqq --purge ceph-common" 1>>/dev/null 2>&1
	ssh ${machine} "sudo apt-get -yqq autoremove" 1>>/dev/null 2>&1
	ssh ${machine} "sudo apt-get -yqq install genisoimage qemu-system nfs-common nfs-kernel-server" 1>>/dev/null 2>&1
	ssh ${machine} "sudo apt-get -yqq upgrade" 1>>/dev/null 2>&1
	ssh ${machine} "sudo apt-get -yqq update --fix-missing" 1>>/dev/null 2>&1
	ssh ${machine} "sudo dpkg --configure -a" 1>>/dev/null 2>&1
	ssh ${machine} "sudo reboot" 1>>/dev/null 2>&1
	wait_startup $machine
	sleep 30
done
