---
title: Getting Started
geekdocDescription: First Steps in using Offensive Tor Toolkit
weight: 10
geekDocHidden: false
geekDocHiddenTocTree: false
---

[**Offensive Tor Toolkit**](https://github.com/atorrescogollo/offensive-tor-toolkit) is written in [Golang](https://golang.org), a language that stands out for its good performance. [Offensive Tor Toolkit](https://github.com/atorrescogollo/offensive-tor-toolkit) makes use of the following libraries:
* **[`ipsn/go-libtor`](https://github.com/ipsn/go-libtor)**: Self-contained Tor from Go.
* **[`cretz/bine`](https://github.com/cretz/bine)**: Go API for using and controlling Tor.

# Preparation
In order to make the compilation, you can **build a docker image** as follows:
```
$ docker build -t offensive-tor-toolkit .
$ docker run -v $(pwd)/dist/:/dist/ -it --rm offensive-tor-toolkit
```
At this moment, [Offensive Tor Toolkit](https://github.com/atorrescogollo/offensive-tor-toolkit) tools are available in your **`dist/`** directory.

> You can notice that every single tool has its base64 associated file. This can be useful when transferring the file in text format.

Once [**Offensive Tor Toolkit**](https://github.com/atorrescogollo/offensive-tor-toolkit) tools are compiled, you can **upload the needed file to the victim**.

> In order to preserve your anonymity, you can use a temporary file upload service such as [Uguu](https://uguu.se/), [file.io](https://www.file.io/) or [FILE.re](https://file.re/).

Here are the main tools:
* [**`reverse-shell-over-tor`**](../reverse-shell-over-tor): Victim sends a [Reverse Shell](https://www.hackingtutorials.org/networking/hacking-netcat-part-2-bind-reverse-shells/) to a Hidden Service.
* [**`hidden-bind-shell`**](../hidden-bind-shell): Victim starts up a Hidden Service with a [Bind Shell](https://www.hackingtutorials.org/networking/hacking-netcat-part-2-bind-reverse-shells/).
* [**`hidden-portforwarding`**](../hidden-portforwarding): Victim starts a Hidden Service that forwards traffic. Useful for pivoting.
* [**`tcp2tor-proxy`**](../tcp2tor-proxy): Victim allows another victim to access a Hidden Service through it. Useful to gaining access to victims in isolated networks.
