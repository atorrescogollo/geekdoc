---
title: "hidden-bind-shell"
geekdocDescription: Bind Shell as a Hidden Service.
weight: 40
geekDocHidden: false
geekDocHiddenTocTree: false
---
This tool allows the **victim to set up a new Hidden Service that offers shells to new connections**. Then, the attacker can connect to the Hidden Service to receive a shell session.

Some parameters need to be set:
```
$ ./hidden-bind-shell -h
Usage of hidden-bind-shell:

  -bind-shell-program string
        Program to execute on bind-shell (default "/bin/sh")
  -data-dir string
        Where Tor data is stored. If not defined, a directory is created
  -hiddensrvport int
        Tor hidden service port where bind-shell will be started (default 80)
  -timeout int
        Timeout in seconds for Tor setup (default 180)
```

See [**Multi-shell access with bind shell**](../../../posts/offensive-tor-toolkit/#multi-shell-access-with-bind-shell) for a real usage example.
