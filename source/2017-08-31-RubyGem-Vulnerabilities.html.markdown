---
title: RubyGem Vulnerabilities
date: 2017-08-31
author: brandon
author_full: Brandon Maxwell
tags: security, ruby, vulnerabilities
---

Multiple vulnerabilities were recently [identified](https://www.ruby-lang.org/en/news/2017/08/29/multiple-vulnerabilities-in-rubygems/) in RubyGems bundled by Ruby. Security fixes introduced into RubyGems `2.6.13` include patches for a DNS request highjacking vulnerability, an ANSI escape sequence vulnerability, a DoS vulnerability in the query command, and a vulnerability in the gem installer that could allow a malicious gem to overwrite arbitrary files. 

Users are encouraged to update as soon as possible. We recommend using [Ruby `2.4.1`](https://devcenter.heroku.com/changelog-items/1251), which has the patches from RubyGems `2.6.13` included.
