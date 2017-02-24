---
title: Cloudflare Security Notification
date: 2017-02-24
author: brandon
author_full: Brandon Maxwell
tags: security
---
Cloudflare, a company that provides CDN, DNS, and DDoS protection, announced on Thursday, Feb 23, 2017 that a memory leak had been discovered by Google's Project Zero team. While Cloudflare has since remediated the vulnerability, information such as HTTP cookies, authentication tokens, HTTP POST bodies, and other sensitive data may have potentially been leaked. The leak may have been active since Sep 22, 2016, with the most severe leakage taking place between Feb 13-18. An assessed 0.00003% of requests may have been exposed. 

Datica does not use Cloudflare, however we recommend that users change their passwords and two factor authentication for websites that use Cloudflare services. Since this bug is being described as a data leak, Datica customers who used Cloudflare proxy services during this timeframe should consider following data breach reporting requirements. Customers only utilizing Cloudflare's DNS services were not affected.


**Additional links and information:**

[Datica Breach Policy](https://policy.datica.com/#breach-policy)

[TechCrunch: Major Cloudflare bug leaked sensitive data from customers’ websites](https://techcrunch.com/2017/02/23/major-cloudflare-bug-leaked-sensitive-data-from-customers-websites)

[Cloudflare: Incident report on memory leak caused by Cloudflare parser bug](https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/)

[Cloudflare: Cloudflare Reverse Proxies are Dumping Uninitialized Memory](https://bugs.chromium.org/p/project-zero/issues/detail?id=1139)
