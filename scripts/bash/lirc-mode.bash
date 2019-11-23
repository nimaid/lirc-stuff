#!/bin/bash

LIRC_TX="/dev/lirc0"
LIRC_RX="/dev/lirc1"
LIRC_OPTS="/etc/lirc/lirc_options.conf"

if grep -Fq $LIRC_TX $LIRC_OPTS
then
	IN_TX_MODE=true
else
	IN_TX_MODE=false
fi

if [ $# -eq 0 ]
then
	FORCE_MODE=false
else
	if [ $# -eq 1 ]
	then
		FORCE_MODE=true
		if [ $1 == "RX" ]
		then
			TX_MODE=false
		elif [ $1 == "TX" ]
		then
			TO_TX_MODE=true
		else
			echo Mode $1 is not TX or RX.
			exit 1
		fi
	else
		echo Too many arguments.
		exit 1
	fi
fi

tx_to_rx() {
	if $IN_TX_MODE
	then
		echo Changing mode from TX to RX...
		sudo sed -i "s:$LIRC_TX:$LIRC_RX:g" $LIRC_OPTS
	else
		echo Already in RX mode!
	fi
}

rx_to_tx() {
	if $IN_TX_MODE
	then
		echo Already in TX mode!
	else
        	echo Changing mode from RX to TX...
        	sudo sed -i "s:$LIRC_RX:$LIRC_TX:g" $LIRC_OPTS
	fi
}

toggle_mode() {
	if $IN_TX_MODE
	then
		tx_to_rx
	else
		rx_to_tx
	fi
}

if $FORCE_MODE
then
	if $TX_MODE
	then
		rx_to_tx
	else
		tx_to_rx
	fi
else
	echo No mode provided, toggling...
	toggle_mode
fi

sudo service lircd restart
