---
title: New Catalyze CLI features - DB Import-Export, Secure Console, Environment Metrics
date: 2015-09-23
author: nate
author_full: Nate Radtke
author_alt: Co-Authors - Josh Ault
tags: PaaS, Platform as a service, Features, Database, Import, Export, Backup, Metrics, Console
---

The Catalyze Platform as a Service (PaaS) continues to evolve as we get feedback from our customers on the kinds of capabilities they'd like to see. Additionally, as we receive and resolve support tickets, we try to extract common workflows and try to automate them as well. The following are three of the features that we are making publicly available. These are all available under the github repo of the [CLI](https://github.com/catalyzeio/cli). Please do provide us with feedback and please file any issues you might run into there.

## Database Import/Export

With a recent release of the [CLI (version 2.1.0)](https://github.com/catalyzeio/cli/releases), we are bringing you a revamped database import feature. Taking what we learned from the usage of the existing functionality by our customers and feedback from them on their use cases,  we updated the CLI and the underlying APIs to fit more of those use cases. One of the use cases we are excited to incorporate into the import command is allowing you to import additional data into your database beyond any initial migrations or seed data i.e. Inserting additional data without a full wipe and replace. 

Additionally, we are releasing a export command that will allow you to download historical backups, as well as point in time snapshots of your database services. Please use this with some caution as you will now have PHI data locally on your laptop. 

## Environment Metrics

One of the longstanding requests from our customers has been for us to provide more visibility into their application's health. General questions that we're sure you wonder about are - How is my application running? What does my container CPU, memory, disk and network I/O stats look like? Is my application growing and getting closer to reaching the limits of your my current containers? What does the load on my application look like during various times throughout the day? All of these questions (and more!) can now be answered with Metrics on the Catalyze Platform. Views of your environment's metrics have been added to the Dashboard and we have exposed a metrics command available on the CLI allowing you to fetch metrics data and process it however you wish. 

## Catalyze Secure Console

Traditionally, we did not provide direct access to your database programmatically. This was done deliberately to minimize the attack surface of your environment. We had a work around in place in the form of a SSH bastion but it wasn't a scalable solution and came with its own set of issues in terms of recovery from reboots etc. This was limiting b definition so we set out to solve the problem about three months ago. The general design principles were - 

1. Allow secure on demand access to your database or rails console or other such capabilities 
1. Continue to disallow root access to ensure security of the platform as a whole 
1. We won't provide a full bash prompt (again with security considerations in mind) which leads to the concept of 
1. Whitelisted commands i.e. only specific commands can be run from the console. Any command preceded by a 'sudo' for example would not be whitelisted. 

The console command has been promoted from incubation to general availability in production environments. The console command will set you up with a secure connection and drop you right into your database shell or rails console (and much more) without fiddling with SSH keys and tunnels. If you are unable to run a particular command, it's most likely because of the whitelisting. Please drop us a support ticket at support@catalyze.io with the specific command you'd like to see whitelisted and we'll revert ASAP. 

To take advantage of these new features upgrade your Catalyze CLI and visit the Dashboard. Also, be sure checkout the documentation pages for more information. We've also been getting a lot of feedback from you on the challenges of installing our Python based CLI because of version, OS and other issues. So we've been working on and are about to release a CLI written in Go which should hopefully alleviate a lot of those problems in addition to being a very quick install. Please keep an eye on this blog or subscribe to it to be alerted when that happens. 

## FAQs, Guides, and Docs

To find out more information and to learn how to take advantage of some of these great features, be sure to check out the FAQ articles, guides, and documentation we've published below.

[Database Import/Export](//resources.catalyze.io/paas/paas-faq/import-export/)

[Environment Metrics](//resources.catalyze.io/paas/paas-faq/environment-metrics/)

[Secure Console](//resources.catalyze.io/paas/paas-faq/secure-console/)