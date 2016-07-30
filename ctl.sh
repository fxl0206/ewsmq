#!/bin/sh
SERVER_NAME=ewsmq
status(){
   echo "==========status======="
}
start() {
	domake
	echo "================ start ${SERVER_NAME} ===========";
	./_rel/ewsmq/bin/ewsmq start	
	echo "==========${SERVER_NAME} start success===========";
}
domake(){
echo "==========make ${SERVER_NAME}===========";
make
echo "==========   make finish     ===========";

}
stop() {
    	./_rel/ewsmq/bin/ewsmq stop
	echo "===========${SERVER_NAME} stop success !============";
}

debug(){
	make
	./_rel/ewsmq/bin/ewsmq console
	}
restart() {
    stop;
    echo "sleeping.........";
    sleep 3;
    start;
}
case "$1" in
    'start')
        start
        ;;
    'stop')
        stop
        ;;
    'status')
        status
        ;;
	'debug')
        debug
        ;;
    'restart')
        restart
        ;;
    *)
    echo "usage: $0 {start|stop|restart|status|link}"
    exit 1
        ;;
    esac
