---
title: "tcp2tor-proxy"
geekdocDescription: From TCP to Hidden Service.
weight: 60
geekDocHidden: false
geekDocHiddenTocTree: false
---
This tool allows the victim to set up a **service that forwards TCP traffic to a Hidden Service**. Then, an victim inside an internal network can access a Hidden Service pivoting over the victim that executes this tool.

Some parameters need to be set:
```
$ ./tcp2tor-proxy -h
Usage of tcp2tor-proxy:

  -listen string
        TCP Socket to listen on. Format: [<IP>]:<PORT> (default "127.0.0.1:60101")
  -onion-forward string
        Hidden service to proxy. Format: <ONION>:<PORT>. This parameter is required
  -timeout int
        Timeout in seconds for Tor setup (default 180)
```

See [**Remote port forwarding through Tor**](../../../posts/offensive-tor-toolkit/#remote-port-forwarding-through-tor) for a real usage example.
