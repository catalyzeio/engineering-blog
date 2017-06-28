---
title: New Ransomware Outbreak
date: 2017-06-28
author: brandon
author_full: Brandon Maxwell
tags: security, Petya, ransomware
---

A new ransomware has hit as least 65 countries beginning on Tuesday, June 27, 2017. The ransomware was first attributed as a variant of the ransomware Petya, however some researchers such as [Kaspersky Labs](https://twitter.com/kaspersky/status/879749175570817024) claim this is a new ransomware that has not been seen before. 

The [initial infection appears to have originated](https://blogs.technet.microsoft.com/mmpc/2017/06/27/new-ransomware-old-techniques-petya-adds-worm-capabilities) in the update process for a Ukrainian based tax accounting software. Besides exploiting the SMB vulnerabilities used in WannaCry, which was patched in the security update MS17-010, the ransomware variant attempts to steal administrative credentials using a tool similar to Mimikatz. This would allow the ransomware to spread to patched hosts with PsExec or WMIC using the stolen credentials.

Datica's systems remain unaffected by this ransomware outbreak. We detailed our security status in our [WannaCry blog post](https://engineering.datica.com/WannaCry-Ransomware.html) in May, which included that our systems were timely patched with MS17-010 in March, 2017. Datica also requires isolation between customer environments, enforced [password rotation](https://policy.datica.com/#7.12-password-management), and regular anti-virus updates/scans.
