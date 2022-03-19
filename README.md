# re_wwan

simple but effective script to revive wwan modules on openwrt and laptops

## Preamble

[openwrt-lte-keep-alive](https://github.com/mchsk/openwrt-lte-keep-alive) Have been around since at least 4 years now,

I see people forking it but the idea is just stupid.

I didn't accept to just reboot the whole device,

and insisted on debugging the issue more accurately.

So I decided to write this script.

### why I like wwan

wwan modules are great under my point of view, as ISP prices are usually lower than any other technology.

they reach places where fiber and adsl are unavailable, and satellite is not worth it because you don't plan to stay in that place so long.

wwan allows you to be **nomad** enjoy it, go take a shower in the rivers.

wwan is great as fallback connection in environments meant to be reliable (and you can't just reboot the whole device!)

## Description
I'm stealing this
```
If your WAN interface using WWAN/QMI/NCM/3G protocol with your modem is working
but your connection drops from time to time, you have just found the safe heaven.
This script make sure your router is online, managing your interface or router itself.
```

### how it works

It does ping quad9 servers to know if you're online [^1]

If you're offline it tries to bring the interface up with `ifup`

pings again

if you're still offline the module is reloaded in the kernel (`rmmod` and `insmod`) [^2]

it always log link quality and other debugging informations gathered through serial interface to the modem, using at commands

[^1]: ping could also be done trhough at commands, but it didn't work for me

[^2]: through `at+cfun=` commands it should be possible to restart the modem, but it didn't work for me (BroadMobi BM806C) and reloading the module have always revived the connection until now

## installation
if installation steps looks difficult to you, then just use the scripts I linked in the first place or contact me: castix at autistci dot org

1. install socat with opkg

1. ensure serial interface is available and test it

1. copy the script. and adjust the parameters on your needs

1. edit the crontab as follows to check every minute and keep a week of logging
```
* * * * * /root/re_wwan.sh >> /tmp/re_wwan.log 2>&1
0 3 * * * echo "$(tail -n 10080 /tmp/re_wwan.log)" > /tmp/re_wwan.log
```

### example of serial interface test

first of all make sure the ttyUSB device is created.

if it isn't, do
```

root@OpenWrt:~# lsusb
Bus 002 Device 001: ID 1d6b:0001 Linux 5.4.154 ohci_hcd Generic Platform OHCI controller
Bus 001 Device 005: ID 2020:2033 Mobile Connect Mobile Connect
Bus 001 Device 001: ID 1d6b:0002 Linux 5.4.154 ehci_hcd EHCI Host Controller
root@OpenWrt:~# echo "2020 2033" > /sys/bus/usb-serial/drivers/option1/new_id
root@OpenWrt:~# dmesg | grep ttyUSB
[   25.188754] usb 1-1: GSM modem (1-port) converter now attached to ttyUSB0
[   25.215966] usb 1-1: GSM modem (1-port) converter now attached to ttyUSB1
[   25.243125] usb 1-1: GSM modem (1-port) converter now attached to ttyUSB2
[   25.270292] usb 1-1: GSM modem (1-port) converter now attached to ttyUSB3
```
it should be clear, take the id of the usb device...

in this case multiple devices have been created, I see only `1` and `2` are working with at commands
```
root@OpenWrt:~# echo "ATI" | socat - /dev/ttyUSB1,raw,echo=0,crlf,nonblock,b115200
ATI
Manufacturer: BroadMobi
Model: BM806C
Revision: M1.2.0_E1.0.1_A1.1.8
IMEI: 358289083120524
+GCAP: +CGSM

OK
root@OpenWrt:~# 
```

## Example Log
```
Sat Mar 19 02:58:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 02:59:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
ping: sendto: Network unreachable
Sat Mar 19 03:00:02 UTC 2022 OFFline. restarting interface. debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:00:11 UTC 2022 ONLINE, it was enough. quality: 18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:01:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:02:02 UTC 2022 ONLINE quality:22,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:03:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:04:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:05:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:06:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:07:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:08:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:09:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:10:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:11:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:12:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:13:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:14:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
Sat Mar 19 03:15:02 UTC 2022 ONLINE quality:17,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
ping: sendto: Network unreachable
Sat Mar 19 03:16:00 UTC 2022 OFFline. restarting interface. debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)
ping: sendto: Network unreachable
Sat Mar 19 03:16:07 UTC 2022 OFFline. reloading kernel module
Sat Mar 19 03:17:02 UTC 2022 ONLINE quality:18,99 debug:(fun 1 | cgreg 0,1 | cgatt 1 | cgact 1,1)

```

as you can see, it was offline at 3:00 I suppose due to an ISP cron. [^3]

at 3:15 instead i issued `rmmod` manually to show this log.

removing the module from the kernel doesn't interfere with the serial interface

so you can still see that the module is still saying that the link to the cell is still active.

then it backs online

[^3]: online with active link uh? seems like a bug of linux kernel module then? or just the crappy modem I have?

## Contributing
Thank you if you do

## Authors and acknowledgment
Castix.
I also would like to acknowledge rico that made me want to live where wwan is mandatory

## License
GPLv3+


## troubleshoot messing with AT

- I see lot of aaaaaaa or ATATATAT on errors and too much whitespaces on success

the baudrate you're using is wrong, try to find the manual for your modem or just try until you guess it

- after some bad command ttyUSB device became weird, doing `file /dev/ttyUSB1` gets Killed by the OOM and I can't socat anymore

just do `rmmod option1` and `insmod option1`


## markdown notes
