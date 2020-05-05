#!/bin/bash

services=(at-server http_mgr service_mgr ws_mgr agt-server)

usage() {
	#    echo "usage: $0 startme|stopme|configureme" >&2
	echo "usage: $0 startme|stopme" >&2
}

startme() {
	echo "starting ..."
	screen -d -m -S service bash -c 'cd server/server-core  && go build && mkdir logs && ./server-core &>  ./logs/servercore-log.txt'
	sleep 5s
	screen -d -m -S serviceMgr bash -c 'cd server/servicemgr && go build service_mgr.go && mkdir logs && ./service_mgr &> ./logs/service-mgr-log.txt'
	screen -d -m -S wsMgr bash -c 'cd server/wsmgr && go build ws_mgr.go && mkdir logs && ./ws_mgr &> ./logs/ws-mgr-log.txt'
	screen -d -m -S httpMgr bash -c 'cd server/httpmgr && go build http_mgr.go && mkdir logs && ./http_mgr &> ./logs/http-mgr-log.txt'
	screen -d -m -S agtServer bash -c 'cd client/client-1.0/Go && go build agt-server.go && mkdir logs && ./agt-server &> ./logs/agtserver-log.txt'
	screen -d -m -S atServer bash -c 'cd server/atserver && go build at-server.go && mkdir logs && ./at-server &> ./logs/atserver-log.txt'
	screen -list
}

stopme() {
	screen -X -S atServer quit
	screen -X -S agtServer quit
	screen -X -S httpMgr quit
	screen -X -S wsMgr quit
	screen -X -S serviceMgr quit
	screen -X -S serverCore quit
	for service in ${services[@]}; do
		killall -9 $service	
	done
	screen -wipe
}

#configureme() {
#ln -s <absolute-path-to-dir-of-git-root>/W3C_VehicleSignalInterfaceImpl/server/Go/server-1.0/vendor/utils $GOPATH/src/utils
#}

if [ $# -ne 1 ]
then
	usage $0
	exit 1
	fi

	case "$1" in 
		startme)
			stopme
			startme ;;
		stopme)
			stopme
			;;
		#configureme)
		#	configureme
		#	;; 
		*)
			usage
			exit 1
			;;
esac
