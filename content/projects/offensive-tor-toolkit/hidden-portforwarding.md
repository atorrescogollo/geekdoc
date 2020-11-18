---
title: "hidden-portforwarding"
geekdocDescription: Local Port Forwarding over Hidden Service.
weight: 50
geekDocHidden: false
geekDocHiddenTocTree: false
---
This tool allows the **victim to set up a new Hidden Service that forwards TCP traffic to a TCP port**. Then, the attacker can access the Hidden Service to access the target.

> If the target is a **SOCKS proxy**, the attacker can pivot easily through the victim to internal networks.

Some parameters need to be set:
```
$ ./hidden-portforwarding -h
Usage of hidden-portforwarding:

  -data-dir string
        Where Tor data is stored. If not defined, a directory is created
  -forward string
        Where the hidden service should forward packets (local port forwarding). Format: <FW_IP>:<FW_PORT>. This parameter is required
  -hidden-port int
        Port for onion service (default 80)
  -timeout int
        Timeout in seconds for Tor setup (default 180)
```

See [**Pivoting with hidden-portforwarding and Chisel**](../../../posts/offensive-tor-toolkit/#pivoting-with-hidden-portforwarding-and-chisel) for a real usage example.
