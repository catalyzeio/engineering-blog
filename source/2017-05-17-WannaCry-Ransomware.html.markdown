---
title: WannaCry Ransomware
date: 2017-05-17
author: brandon
author_full: Brandon Maxwell
tags: security, WannaCry, ransomware
---

On Friday, May 12, 2017, a new ransomware cryptoworm attack started targeting Microsoft Windows. WannaCry encrypts 176 different file types with a Bitcoin ransom demand to decrypt files. It was initially thought the WannaCry outbreak started as a phishing attack, but [Sophos has reported](https://nakedsecurity.sophos.com/2017/05/17/wannacry-the-ransomware-worm-that-didnt-arrive-on-a-phishing-hook/) that this looks like a worm from the beginning. The ransomware takes advantage of an SMB vulnerability to propagate, which Microsoft patched in March with MS17-010. All Datica Windows systems received this patch in our March patch cycle. 

In addition to our security patching policies to reduce the risk of any infection, Datica's security architecture requires isolation from the public Internet and between environments, intrusion detection system (IDS), and updated anti-virus software. Attacks such as this drive home the importance of practicing and keeping Disaster Recovery, Backups, and Incident Response plans current.
