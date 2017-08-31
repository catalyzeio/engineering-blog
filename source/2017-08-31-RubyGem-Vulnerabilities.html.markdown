---
title: RubyGem Vulnerabilities
date: 2017-08-31
author: brandon
author_full: Brandon Maxwell
tags: security, ruby, vulnerabilities
---


Multiple vulnerabilities were recently [identified](https://www.ruby-lang.org/en/news/2017/08/29/multiple-vulnerabilities-in-rubygems/) in RubyGems bundled by Ruby. Security fixes introduced into RubyGems 2.6.13 include patches for a DNS request highjacking vulnerability, an ANSI escape sequence vulnerability, a DoS vulnerability in the query command, and a vulnerability in the gem installer that could allow a malicious gem to overwrite arbitrary files. 

Users are encouraged to patch as soon as possible. Running `gem update --system` will introduce the security patches for the RubyGems. For affected Datica users, we recommend updating via a [post-build hook](https://resources.datica.com/compliant-cloud/articles/buildpacks-custom/).

**Example post-build hook:**

```
#!/bin/bash
/app/vendor/ruby-2.3.4/bin/gem update --system
```
