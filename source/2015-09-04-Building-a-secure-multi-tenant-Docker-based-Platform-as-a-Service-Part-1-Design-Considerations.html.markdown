---
title: Building a secure, multi-tenant Docker based Platform as a Service - Part 1: Design Considerations
date: 2015-09-04
author: mohan
author_full: Mohan Balachandran
author_alt: Adam Leko, Nate Radtke, Vince Kenney
tags: PaaS,Platform as a service,Docker,Multi-tenancy,Orchestration, Docker Networking
---

## Summary

>   Detailed explanations are just apologies in long form.
>   — Adam Leko

This document is intended to provide a top down introduction to the design of the Catalyze Platform as a Service (PaaS). It will additionally delve into the design of the components needed to make our vision a reality and what that means for you as a customer. This will include the design choices, tradeoffs and a quick view into the next generation of these components. Or in the more succint words of the author of the above quote - "all of the major orchestration components, how and why they were designed, and a brief history of how they managed to come into existence".

*Credits: Our lead engineer, Adam Leko wrote up chunks of this around July of 2014 (yep, that long ago). Other sections have been contributed by Nate Radtke and Vince Kenney.*


# Motivation

>   People often say that motivation doesn’t last. Well, neither does bathing - that’s why we recommend it daily.
>   — Zig Ziglar


HIPAA compliance is painful. It requires huge effort for our customers if they were to do it themselves. This is not only because of the [technical requirements][FIXME] but aso because of the [administrative][FIXME] and [policy requirements][FIXME] imposed by HIPAA. The Catalyze Backend as a Service (BaaS, or sometimes just “the API”) provides a nice, easy-to-use method for spinning up new mobile or web applications, but what about customers that have already invested in an application which uses their own code or backend? We can’t expect customers to completely rewrite their applications.

For these customers, we offer a standard platform on which to host applications. The platform takes care of all the prerequisites for HIPAA compliance while adding useful features like standardized logging and monitoring. This offering has generated a lot of client interest, which is not surprising given the features offered in combination with our core competencies.

The first few customers that signed on to the PaaS platform were migrated, deployed, and managed completely manually. This is a good way to prove out the utility of the platform but is incredibly difficult to scale to more customers.  Rather than using a brute-force approach to growing the platform (adding hordes of staff), we started working on ways to automate deploying and managing customers’ applications. The end result draws heavy inspiration from [Heroku][1] with some unique twists to satisfy the additions needed for HIPAA compliance.

[1]: <http://www.heroku.com>

# Core design considerations

> Don't think about the faster way to do it or the cheapest way to do it, think about the most amazing way to do it.

> - Richard Branson

As an obvious starting point, commoditization of software components used to build web applications has made it much easier to support arbitrary customer environments. Web frameworks such as [node.js][2] and [Ruby on Rails][3] along with storage technologies like [MySQL/Percona][4], [PostgreSQL][5], and [MongoDB][6] (among others) on top of Linux have become so common that adding support for these services enables support for a *wide* variety of user applications.

[2]: <http://nodejs.org>

[3]: <http://rubyonrails.org/>

[4]: <https://www.percona.com/>

[5]: <http://www.postgresql.org/>

[6]: <http://www.mongodb.com/>

In addition, virtualization technologies make it cost effective to run customer applications and services on a relatively small amount of hardware. Virtual machines provide a nice way of segregating customer environments but tend to be a bit heavyweight with resource usage. Containers and jails provide a lighter-weight solution but can be tricky to manage at larger scales without comprising security guarantees. [Docker][8] is an interesting take on the container approach; on the outset it appears to not provide much advantage over [Linux Containers][9], until you take a look at the additional management utilities provided by it and the ecosystem surrounding it. As it turns out, Docker solves a lot of the operational issues you would have if you attempted to build a platform for managing deployments using containers. It’s a young project but has improved very quickly, particularly in the months before its initial stable 1.0 release.

[8]: <http://www.docker.com>

[9]: <https://linuxcontainers.org/>

We made the decision to go with Docker (and all it's attendant challenges) in the Summer of 2014. Docker was at Release 0.6 then. 

Once that decision was made, it led to a whole series of design considerations for which solutions did not—and still don't—exist. So we had to develop it all. In retrospect, we regret the decision not to open source it all as that would, we believe, have benefited the broader Docker community. But hindsight is 20-20. We chose to prioritize our specific company needs and revenue targets over an open source model.

In any case, there are multiple design considerations that we had to take into account and develop towards which we will list out below. 

## Multi-tenancy

> The key to performance is elegance, not battalions of special cases.
>   — Jon Bentley and Doug McIlroy

The goal of Catalyze is to simplify compliance for its customers, which also implies that hosts will have containers belonging to different customers. This leads to the design requirement that each customer's application, data and traffic must be isolated and segregated. Isolating containers implies configuration rules around AppArmor and SELinux. Data segregation implies encryption with customer specific keys and associated block stores. Traffic isolation implies customer defined networks (what connects and talks to what) and encryption of traffic with customer specific TLS keys (https is not sufficientas that requires customers to figure out all the nuances related to wrappers around database protocols).

## Compliance & Security

> I want security, yeah. Without it I had a great loss, oh now.
> - Otis Redding, "Security" from the album "Dreams To Remember"

These are tightly coupled. Compliance defines specific security requirements. These are often not sufficient because regulatory requirements lag technology advances but they are excellent for defining the baseline capabilities. Regulatory requirements vary depending of not only industry (HIPAA, PCI...) but also geography (NIST, Safe Harbor...). Part of the reason we focused on HIPAA is because from a healthcare perspective, HIPAA (and it's more prescriptive cousin, HITRUST) is the only healthcare specific standard and is often held as the gold standard as other countries realize the value and importance of protecting healthcare data. HIPAA compliance implies administrative and technical protocols that need to be followed. From a technical perspective, it implies encryption at rest and in transit (see above section), data integrity, prevention of data loss and service (backups, disaster recovery), industry best practices around system hardening (vulnerabiity scans, IDS), logging and system monitoring.

## Building images

>   Start where you are. Use what you have. Do what you can.
>   — Arthur Ashe

This is where things got a litlle philosophical. Should we allow any custom image derived from a customer supplier dockerfile or should we be prescriptive? Prescriptiveness implies lack of flexibiity which developers aren't very comfortable with but that lack of flexibility comes with security related capbilities baked in. We chose to go with a more prescriptive approach but are working towards the dockerfile approach with some constraints based on our learnings. We chose to go with a git-push model using [progrium's](http://progrium.com/blog/) [buildstep](https://github.com/progrium/buildstep) which in turn leverages Heroku's [buildpacks](https://devcenter.heroku.com/articles/buildpacks).

## Docker Registry

>   These words are mine, those notes are mine, this song is mine...
>   — Merle Haggard

A private registry was automatically a requirement. This also led us to learn a lot about the challenges of managing and maintaining a private registry which we intend to share soon in a separate blog post.

## Service Registry & Discovery

Service discovery is a key component of most distributed systems and service oriented architectures. The problem seems simple at first: How do clients determine the IP and port for a service that exist on multiple hosts? There are two sides to the problem of locating services *viz* Service Registration and Service Discovery.

- **Service Registration**: The process of a service registering its location in a central registry. It usually register its host and port and sometimes authentication credentials, protocols, versions numbers, and/or environment details.
- **Service Discovery**: The process of a client application querying the central registry to learn of the location of services.

Any service registration and discovery solution also has other development and operational aspects to consider such as monitoring (what happens when a registered service fails?), load balancing, availability concerns etc. We chose to keep this as simple as possible to maximize uptime and maintenance. We looked at all the options described [here](http://jasonwilder.com/blog/2014/02/04/service-discovery-in-the-cloud/). The main gap that all of the existing solutions had was that they weren't designed to be multi-tenant which is why we felt it would be best for us to build our own.

## HA considerations

>   You go - Up... Up... Up... Up... Up... Up... Up... Up. 
>   — Wiz Khalifa, "Up"

It is of course, easy to spin and wire up a container. But it is also critical to offer highly available options to our customers to maximize their uptime. Healthcare services can be mission and life critical as well. We decided to approach the problem of HA services by providing redundant components and the ability to quickly restore a service component. These HA capabilities would need to extend to the [application languages](https://resources.catalyze.io/paas/getting-started/deploying-your-first-app/supported-languages-frameworks/), the [databases](https://resources.catalyze.io/paas/getting-started/deploying-your-first-app/supported-databases/) and the [cache](https://resources.catalyze.io/paas/getting-started/deploying-your-first-app/supported-add-ons/) offerings. 

## Networking

>   The problem with the Internet is that it is meant for communications among non-friends.
>   — Whitfield Diffie

This is the biggest problem that we had to overcome. Solutions that existed at the time, such as [Skydock](https://github.com/crosbymichael/skydock) and [Pipework](https://github.com/jpetazzo/pipework) provide some of the features, but lacked things like encryption, access models, and automation. We decided to tackle container-to-container encryption using an in-house solution. There are  existing ways to solve this problem, even transparently, but they have their own sets of issues. [OpenVSwitch](http://openvswitch.org/) has had a lot of success in OpenStack environments but getting it working reliably in a Docker-based environment is generally tricky and tends to be somewhat error-prone. VLAN tunneling over IPSec is arguably the easiest solution to get going if you have hardware to help you along the way but this obviously is not feasible in a cloud environment.

Rather than attempt to shoehorn existing technologies into this environment, we decided to take a radically different software-based approach. We eventually settled on a proxy approach in which all communication between containers is tunneled over TLS-encrypted connections that are set up on demand. This was our initial solution to solve the networking problem. It is also interesting to note that even now, solutions such as Weave still have issues when encryption is turned on. We also intend to showcase our next generation of networking which can achieve line rates with full encryption turned on soon. 

## Orchestration

>   Make it so
>   — Jean-Luc Picard, Captain of the USS Enterprise, Star Trek

Based on all of the above, it was obvious that we needed an orchestration layer that would manage the interactions between all these various components while ensuring the core requirements enforced by the security and compliance needs. So, at the very minimum, the orchestration layer (perhaps made up of several sub-components) would be responsible for:

- **Job distribution**: Which container goes on which host. For example, containers that are part of a specific HA (highly available) configuration cannot go on the same host whereas cache containers would prefer to be on the same host as the code container if there is available capacity. Other considerations included over-provisioning (which we avoid) and several others. Note that we do not over-provision our hosts
- **Job scheduling**: Deployment of these containers have to be scheduled. The key driver for scheduling came from our backup jobs. Turns out that the underlying filesystems supported by Docker (such as BTRFS) couldn't handle significant write loads. Scheduling became a critical need very quickly.
- **Bidding**: Required to answer the question of which host does the container get deployed on. The primary constraint to be taken care of here would be the remaining capacity on the host based on the requirements of the customer container (RAM, CPU etc.). The approach we landed on was to allow the hosts in the fleet to "bid" on the job by providing a score generated by the host. The job scheduler would then take care of deploying the container to the winning host.
- **Tracking**: A centralized record of what containers are running on which hosts and who (customer and network) they belong to. VMs / hosts die and when they do, rapid recovery is necessary. 
- **Garbage collection**: It's a dirty job but someone has to do it. The interaction between Docker and the filesystem (BTRFS) isn't clean. Combine that with the overhead of the filesystem (up to 50%), `gc` became a very critical component to the stability of the platform. This was discovered down the road once we had a significant number of customers and thus conatiners (and hosts) that we had to manage. 

## Monitoring

>    Доверяй, но проверяй (doveryai, no proveryai). In English, "Trust but verify"
>   — Russian Proverb

HIPAA and HITRUST can also be interpreted to **require** a monitoring service i.e. something that tracks running applications to ensure that they are in a running state. That is something that we would be able to utilize as a service provider as well to ensure the customer's service(s) are up and running. The aggregate feeds must be sent to a central monitoring service and customers should be able to get access to their own monitoring instance to customize as they see fit. We initially chose to go with Nagios (which we might still go back to) but ultimately ended up choosing Sensu which provides a much more modern interface but also allows reuse of various Nagios plugins.  This service that we provide to our customers goes beyond what a tradition PaaS like Heroku or even an IaaS provider like AWS provides out of the box and cost extra. Health checks are a critical feature for much of the platform's functionality: monitoring/alerting, seamless redeploys, semi- or fully-automated blue/green deploys, and auto healing. However, the problem with Sensu is that it does not expose the state of health checks in a convenient manner that can be leveraged by the rest of the platform for specific lower level capabiities. We're exploring alternatives and better solutions to this specific problem. 

## Logging

>  I carry a log - yes. Is it funny to you? It is not to me. Behind all things are reasons. Reasons can even explain the absurd. .... Watch - and see what life teaches. 
>   — The Log Lady, from the TV show Twin Peaks

Similar to monitoring but especially so, logging is a key requirement of any compliance regulation. At the same time, we need to minimize our access to our customers' application. To enable this, we needed to provide customers with their own dedicated logging environment. This is a significant value as other services like AWS CloudTrail, Papertrail, Splunk etc. can get very expensive, very quickly. We chose to go with the ELK (Elasticsearch, Logstash, Kibana) stack. To simplify access and sending of logs to this server from across all customer applications or databases, by default, any logs that get dropped into syslog will be automatically picked up and shipped over. This provides our customrs with a single, dedicated place where all of their application, database, etc logs are aggregated and searchable. Logs can get pretty large which is why we retain only 14 days of live logs (i.e. searchable). The remainder of the logs (and the indexes) are rotated out into longer term storage like S3. 
