---
title: Offensive Tor Toolkit
geekdocDescription: Pentesting Tor utilities
weight: 10
---
[**Offensive Tor Toolkit**](https://github.com/atorrescogollo/offensive-tor-toolkit) is a series of tools that **simplify the use of Tor for typical exploitation and post-exploitation tasks**.

In exploitation and post-exploitation phases, the victim needs to access Tor. All of this tools have an **embedded instance of Tor** and they are completely separated from each other. In this way, you only need to upload one file to the victim in order to run the required action.

Some of this actions are described below. Click on them to see how it works:
* **Reverse Shell**: The victim connects to a Hidden Service hosted by the attacker.
* **Bind Shell**: The victim sets up a Hidden Service that offers a shell session.
* **Local Port Forwarding**: The victim routes TCP traffic from a Hidden Service to a port. Useful for accessing internal networks.
* **Remote Port Forwarding**: The victim routes TCP traffic from a port to a Hidden Service. Useful for accessing Tor from victims without internet access.
* **Others**.

## Table of Contents:
{{< toc-tree >}}