---
title: Configuration Management (Part 1) - Catalyze Docker PaaS
date: 2014-09-22
author: mortiz
author_full: Mike Ortiz
author_alt:
tags: Docker, PaaS, platform as a service, HIPAA, configuration management, salt, puppet, chef, automation
---

The need for configuration and system management is well known. Since shortly after the dawn of time, when the first caveman got his second mainframe, managing configuration across multiple hosts has been a daunting task.

In the era of cloud computing, with ever more complex applications and infrastructure, this task is considerably more involved than it was for our caveman ancestor. Many hosts need be provisioned with all of their associated configurations. Those hosts then need to be managed.  Automation is essential.

As an example, docker may have some perceived security concerns, which has been discussed in detail in a few [posts](http://blog.docker.com/2013/08/containers-docker-how-secure-are-they/). Those concerns can be mitigated with AppArmor profiles and kernel-level tuning, making higher security and isolation [achievable](https://docs.docker.com/articles/security/). Managing and updating these kernel parameters and profiles across multiple hosts, of course, needs configuration management. That's one problem, but also as development proceeds, docker images need to evolve to contain new features and bug-fixes, and be re-deployed with them. A configuration management tool would be handy to verify and deploy the correct version of these images across the lifecycle of the software.

There are many choices out there for configuration management. Everything from our old friend CFEngine (yes, our caveman just cringed too) to [Puppet](http://puppetlabs.com/) to [Ansible](http://www.ansible.com/home) to [Chef](https://www.getchef.com/) and relative newcomer, [Salt](http://www.saltstack.com/). Evaluating and choosing the one that would best cover our use case was a difficult one, but ultimately we chose to go with Salt.

There are several reasons for choosing to use Salt in our environments. First, Salt was originally developed as a system management tool. As such, it has many modules available for system management right out of the box. It's also very good at doing management tasks, and such things aren't bolted on or a third party module. Second, the configuration management feature of Salt, which was an afterthought, is actually very good. In our tests it stood it's ground and rivaled the more mature configuration managers in that respect as well. Finally, Salt is relatively simple to use in large cloud-based environments when compared to it's rivals. As a subscriber to the operational paradigm of K.I.S.S. (keep it simple, stupid!) that is a great attribute to have. When you add in features like Salt-Cloud and built-in git and docker management, it makes Salt very appealing for these types of environments. With one command, I can have a fully functional environment stood up at any of our cloud infrastructure providers, or even multiple providers if I want super redundancy, in mere minutes.

In to addition docker/apparmor and quick deployments at our production providers like Rackspace and Amazon, some of the tasks we leverage salt to do are:

- deploy staging environments to hosting providers who do not yet sign BAAs like Digital Ocean, where we can leverage great performance and even better pricing for our environments that don't store PHI or secured code.

- on the fly at rest encryption of our hosts (even in staging!)

- automated docker image creation, deployment and lifecycle management. This one has been a *huge* timesaver and productivity booster. We no longer need to manually run build processes and wait for them to complete. In one Salt state we can build and tag images, push them to our internal docker registries and run automated tests against them.

- management of internal apt package repositories and package version pinning

When we combine all of this (and more) with the ability to trivially define entire environments in YAML with salt-cloud and validate/compare configurations on hosts to "known good" states in salt, we have a complete system management and configuration infrastructure that is extensible and easy to manage.

I'll be providing some more in-depth tutorials on configuring and managing Salt and Docker at a later date, so stay tuned!