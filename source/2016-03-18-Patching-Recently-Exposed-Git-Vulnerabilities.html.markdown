---
title: Patching Recently Exposed Git Vulnerabilities
date: 2016-03-18
author: brandon
author_full: Brandon Maxwell
author_alt:
tags: Security, git
---

### Background

Two [vulnerabilities](http://seclists.org/oss-sec/2016/q1/645) (CVE-2016-2315 and CVE-2016-2324), which feature a heap corruption and buffer overflow, were announced this week in all Git client/server versions before version 2.7.4. Both vulnerabilities have the potential to allow a remote authenticated attacker to perform remote code execution or Denial of Service (DoS) by pushing or cloning a repository with a large filename or large number of nested trees. 

### Technical Details

The vulnerabilities, identified by Laël Cellier, are a result of the use of the function [path_name()](https://github.com/git/git/blob/v1.7.0/revision.c#L18) to append the filename at the end of the path in a repository tree. The function makes use of two signed integers (nlen and len), which can be positive or negative, resulting in the possibility of an integer overflow. Passing a very large file name or number into strlen() will overflow nlen and len with a negative value. Finally, the usage of strcpy() will copy the large filename over the small amount of memory allocated, resulting in a heap overflow.

### Patching Systems

Security is a core value that we take very seriously to ensure the integrity of your data. As of Thursday, March 17, all affected Catalyze systems have been patched to address these vulnerabilities. We also suggest to update your personal systems to the latest [Git version (2.7.4)](https://git-scm.com/downloads).
