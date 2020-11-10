---
title: Getting Started
geekdocDescription: First Steps in using Offensive Tor Toolkit
weight: 10
geekDocHidden: true
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

**Go to [Usage section](../usage) for the next steps.**
