---
title: "reverse-shell-over-tor"
geekdocDescription: Reverse Shell to a Hidden Service.
weight: 30
geekDocHidden: false
geekDocHiddenTocTree: false
---
This tool allows the **victim to connect to the Hidden Service** of the attacker. If the attacker starts a netcat handler, it will give him a **shell session**.

Some parameters need to be set:
```
$ ./reverse-shell-over-tor -h
Usage of reverse-shell-over-tor:

  -listener string
        Listener address. Format: <ONION_ADDR>:<PORT>
  -reverse-shell-program string
        Program to execute on reverse-shell (default "/bin/sh")
  -timeout int
        Timeout in seconds for Tor setup (default 180)
```
