# What is PingLost? #
It's a batch file that logs lost packets and state changes to a text file. It automatically creates a text file according to the date and time and the hostname or IP address you're monitoring.

It's not guaranteed to be locale-independent so it may not work properly on some computer with different language (I know for sure that it works with french).

# Why do I need it? #

You probably want to monitor some distant server or computer, or just monitor your internet or wifi connection, and you don't want to sit in front of a command prompt window that shows the result of a `ping -t 192.168.1.1` so you search the interweb and find this.

## You won't have to sit in front of your PC ##

Just drop the batch file into your windows dir for example and start `pinglost` just as a normal `ping` command. Except that, in addition to giving you the usual `ping` output, it logs the lost packets and state changes so you know exactly when it happened.

## Monitor two hosts ##

Launch it in two command prompt windows with two different hostnames or IPs, and see if both were losing packets at the same moment. Keep them running over night and explore the logs the next day.

# How does it work? #

Just call `pinglost /?` to see this:

    The pinglost command sends a ping request to "hostname_or_IP" then logs the
    lost packets and state changes into a file called
    "PingLost_hostname_AAAAMMDD_HHMM.txt" with a timestamp.
    
    call: pinglost hostname_or_IP [-n count] [-l size] [-w timeout]
    
    -n count 	Specifies the number of Echo Request messages sent.
     			The default is 4.
    -l size  	Specifies the length, in bytes, of the Data field in
     			the Echo Request messages sent. The default is 32.
     			The maximum size is 65,527.
    -w timeout  Specifies the amount of time, in milliseconds, to wait
     			for the Echo Reply message that corresponds to a given
     			Echo Request message to be received. If the Echo Reply
     			message is not received within the time-out, the "Request
     			timed out" error message is displayed. The default
     			time-out is 4000 (4 seconds).
    
    The parameters following the hostname can be in any order.

## Where is the log file? ##

It is supposed to be in the working directory.