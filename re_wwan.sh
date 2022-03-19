PING_ADDRESS=9.9.9.9
ATTEMPTS=3
IFACE=wwan
MODULE=qmi_wwan
MODEM_DEVICE=/dev/ttyUSB1
BAUDRATE=115200

function at {
  echo "AT$1$2" | socat - $MODEM_DEVICE,raw,echo=0,crlf,nonblock,b$BAUDRATE | grep  "$1: " | cut -d " " -f 2
}

function quality {
  # outputs RSSI (excellent above 20) and errors (99 is unknown)
  echo `at +CSQ`
}

function funcheck {
  # FUN is the functioning mode of the modem
  # FUN 1 is normal. FUN 0 is powered off. FUN 4 is aereo mode or powersafe mode. FUN 3 means tx disabled
  # FUN 5+ is vendor specific
  # GATT and GACT must both be 1 to be online
  echo "(fun" `at +CFUN ?` "| cgreg" `at +CGREG ?` \
       "| cgatt" `at +CGATT ?` "| cgact" `at +CGACT ?`")"
}

ping -c $ATTEMPTS $PING_ADDRESS > /dev/null
if [ $? -ne 0 ] 
then
  echo "`date` OFFline. restarting interface. debug:`funcheck`"
  # ifdown $IFACE  # no need to teardown the interface
  ifup $IFACE
  sleep 5
  ping -c $ATTEMPTS $PING_ADDRESS > /dev/null
  if [ $? -ne 0 ] ; then
    echo "`date` OFFline. reloading kernel module"
    rmmod $MODULE
    sleep 1  # unnecessary sleep
    insmod $MODULE
    ifup $IFACE
  else
    echo "`date` ONLINE, it was enough. quality: `quality` debug:`funcheck`"
  fi
else
  echo "`date` ONLINE quality:`quality` debug:`funcheck`"
fi
