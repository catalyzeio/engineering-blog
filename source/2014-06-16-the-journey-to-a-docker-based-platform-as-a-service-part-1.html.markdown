---
title: The journey to a Docker based Platform as a Service - Part 1
date: 2014-06-16
author: mohan
author_full: Mohan Balachandran
author_alt:
tags: docker, PaaS, platform, hosting, compliance, HIPAA
---

The idea came to us around October of last year. What if we could provide a platform such that we ourselves had no access to our customers data? The more we thought about it, the more sense it made. One of the primary business reasons was that such an approach would limit any additional liability that we would incur. This wouldn't obviate the need for a BAA of course. From an overall security and privacy perspective, such an approach would almost guarantee that the core encryption requirements imposed by HIPAA and the segregation requirements imposed by enterprises and the needs of private clouds would be easily addressed.The main challenge was how to go about doing this from a technical perspective. The service we most wanted to emulate was [Heroku](http://www.heroku.com).

The biggest [value](http://www.quora.com/In-lay-man-terms-what-is-the-value-that-Heroku-brings-to-the-user-I-presume-that-anyone-can-install-and-host-Ruby-on-any-servers-Then-what-makes-Heroku-so-special) Heroku provided was to simplify the developers life to allow them to focus on their application rather than the nuances and complexities of deployment and server configurations. Add to that all the additional requirements around complying with regulations, mandates and certifications (HIPAA, HITRUST etc.) in healthcare and you'll understand our motivation completely. We want to make it as easy for a developer to build a compliant healthcare application on Catalyze as it is to deploy an app on Heroku. With this goal in mind, we set out to design and build out the platform.

##Step 1: Technology choices

The two technologies we looked at really closed at were virtualization and containerization. These aren't mutually exclusive because you could run containers inside VMs but that path loses a lot of the benefits of containerization.

VMs have a lot of advantages but doesn't address the dependency hell problem. Additionally, since each VM is meant to operate independently, even if two VMs were on the same host, they wouldn't share anything (kernel etc.). Thus, the key disadvantages of VMs are:

- Running a whole separate operating system to get a resource and security isolation i.e. an OS per application. The OS often consumes more memory and more disk than the actual application it hosts

- Slow startup time while waiting for the OS to boot.

Containers on the other hand have several advantages here. I'm not going to list them here - great overviews are provided [elsewhere](http://bodenr.blogspot.com/2014/05/kvm-and-docker-lxc-benchmarking-with.html). But the key ones are:

- Shared OS across multiple applications

- Rapid startup times (few seconds)

Heroku runs on LinXContainers (LXCs). Other large scale PaaS providers like OpenShift, CloudFoundry are also container based. The advantages that containers provide in terms of speed, weight etc. were what drove us towards diving deeper into the world of containers.  Which is when we re-discovered [Docker](http://www.docker.io). A quick summary of Docker and its capabilities is available [here](http://www.slideshare.net/dotCloud/why-docker2bisv4). Although docker then was still very young, it made a lot of sense to us and its roadmap and then current capabilities were very appealing to us. We knew we'd have to do some / a lot of work on our end to isolate the containers but we knew a couple of approaches to solve the problem. The biggest challenges would be:

- Orchestrating deployment of containers across multiple hosts

- Wiring them all up

- Security and isolation and

- Having a core set of compliance related capabilities (namely logging, monitoring and backup / DR) built and deployed for every customer

So within a couple of weeks, we knew the stack that we were going to build the Catalyze PaaS on - Docker, Go, and Python. Now came the design.


##Step 2: The Catalyze PaaS Design

I'll lay out our design as a to-do list which will also act as a listing of topics that we will cover in this and subsequent blog posts. A lot of this is completed and we have pilot clients live on the platform. We won't necessarily go into a lot of detail on each but this should serve as the basis for you to understand how the platform works. Key pieces of this will be detailed out as much as feasible. We're also exploring how we can open source a lot of what we have done.

We looked at requirements from a customer perspective and then a backend perspective to enable those requirements. We then layered on security and compliance requirements.

### Customer requirements

- Application definition

- Git Push

- Run scripts - import data, rake tasks (in case of Ruby) etc.

- Status and metrics of application

- Update the application

- Scale the application

- Uptime assurances


###Backend requirements (including compliance and security)

- Container definitions

    - Base including encryption etc.

- Container build and registry

    - Leveraging Heroku Buildpacks

- Container deployment and orchestration

    - Choice of hosts

    - Wiring up containers

- Container management

- Scaling

- Environment management: encryption, isolation, key mgmt. etc.

- Management APIs

- Customer APIs

We've been keeping up with docker related posts from various sources and everyone seemed to be making strides forward. When Docker 1.0 came out and all the press surrounding it also made us realize that all the demos that people were showcasing were steps in the right direction and that what we were doing was something that was needed. However, none of the demos seemed to focus on the really big problems or perhaps they were keeping it a secret as well. It was heartening to read [this article](https://devopsu.com/blog/docker-misconceptions/) that reinforced for us that what we were trying to solve were hard problems.

We look forward to sharing more of our work with you and general availability of our PaaS by the end of June.

As always, comments and feedback are welcome.