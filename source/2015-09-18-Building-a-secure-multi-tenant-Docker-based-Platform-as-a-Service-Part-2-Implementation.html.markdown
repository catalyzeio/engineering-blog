---
title: Building a Secure, Multi-Tenant Docker-based Platform as a Service - Part 2 - Implementation
date: 2015-09-18
author: mohan
author_full: Mohan Balachandran
author_alt: Co-Authors - Adam Leko
tags: PaaS, Platform as a service, Docker, Multi-tenancy, Orchestration, Docker Networking
---

Based on all the requirements described [earlier](https://engineering.catalyze.io/Building-a-secure-multi-tenant-Docker-based-Platform-as-a-Service-Part-1-Design-Considerations.html), we arrived at the following architecture and design approach.

## IaaS Provider Neutrality

We started off on Rackspace but it was always our intention to **also** provide our services on AWS, Azure, and other cloud providers. We now run on both Rackspace and AWS with support for Azure coming shortly. We also managed to get two full external HIPAA audits done and achieved [HITRUST](https://hitrustalliance.net/) [certification](https://catalyze.io/hitrust).

Given the various requirements imposed by the IaaS provider BAAs (and they are all different) such as use of specific machine flavors, subset of usable services, SSL termination requirements, hardware requirements, etc., we had to build in some additional capabilities into our software. Generally we use the following sets of services from every IaaS provider:

- **Load Balancers**: Elastic Load Balancers - ELB (AWS), Cloud Load Balancers - CLB (RAX and Azure)
- **Compute instances**: Elastic Compute Cloud - EC2 (AWS), Cloud Servers (RAX), Azure VMs
- **Block stores** (all SSD): Elastic Block Stores - EBS (AWS), Cloud Block Store - CBS (RAX), Azure Storage
- **Blob stores**: Simple Storage System - S3 (AWS), CloudFiles - CF (RAX), Azure Blob Storage

## Pods

Within each IaaS provider, we use [Salt](http://saltstack.com) as our configuration management system to provision a set of hosts / VMs with specific characteristics such as sizing, specific sets of packages, kernel versions, OS versions (Ubuntu 14.04), and AppArmor profiles. Block devices are similarly provisioned on each of those hosts as well (additional block devices get added on dynamically based on customer requirements). Other things like load balancers etc. get added on as needed. We use dedicated load balancers for each of our customers. This collection of hosts is called a pod. A pod can have two deployment models:

- **Standalone**: This model includes not only the Docker hosts onto which all our customer and supporting containers are deployed but also contains a set of management hosts which take care of all the other things required to make Docker and our PaaS work (see next section for more details). See below for an image depicting the structure of a standalone pod.
- **Slave**: This model only contains a set of Docker hosts. This is a "slave" pod managed by the management infrastructure already deployed in another standalone pod.

![Architecture of a Standalone Pod](/assets/img/posts/standalone_pod.png)

We have also designed the pods to be something that can go across multiple availability zones (AZs in AWS) and multiple regions. These spanning pods have been nicknamed "super pods."

## Management Infrastructure

There are several components in the management infrastructure and are shown in the diagram below.

![Architecture of the Management Infrastructure](/assets/img/posts/management_infra.png)

The nature of these components [has been discussed before](https://engineering.catalyze.io/Building-a-secure-multi-tenant-Docker-based-Platform-as-a-Service-Part-1-Design-Considerations.html) but just as a quick summary to save you some time scrolling back and forth:

- **The git server**: This is where customers push their code. Each customer has their own unique git URL.
- **The build servers**: These are where the Docker container images are built based on the code pushed by our customers. There are usually several of these so that building of Docker images can happen in parallel.
- **The Docker registry**: This is where the docker images are sent, stored, and subsequently downloaded. This is a private registry not accessible outside of our internal infrastructure.
- **The orchestration layer**: Consists of the service registry (a.k.a. the all-seeing eye of Sauron), the scheduler (a.k.a. Elrond), and the orchestration agents (a.k.a. Strider). This layer takes care of assigning deployment jobs to specific docker hosts based on various customer-specific placement rules, tracking job/container state across all hosts in a pod, and configuring the secure encrypted overlay network used for all container-to-container communication. The orchestration layer was initially written in Python but has now been re-written in Go. Look for a more detailed post on that coming up as well.
- **Secure console**: We do not provide direct root SSH access into either the hosts or the containers. We operate very heavily on the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege). However, customers do need direct access to their environment at times (e.g., to run Rake tasks) and this functionality is available via our secure console. We'll discuss the details on our secure console in an upcoming blog post.
- **The pod API**: The pod API is the overall coordinator between the low-level interface offered by the orchestration layer and the high-level interface offered via the customer API. It manages things like configuring all services in an environment, triggering builds and deploys / re-deploys, making the translations needed by the orchestration and other components, etc.
- **The customer API**: The customer API is responsible for managing aspects of contracting, communicating with the dashboard and CLI, ensuring authentication and authorization, etc.
- **The dashboard and CLI**: The dashboard is the developer's UI into setup and management of their various environments. Since developers do prefer the command prompt, we have a CLI as well which leverages the customer API to facilitate that interaction. This was initially written in Python but has now been re-written in Go and is available [here](https://github.com/catalyzeio/cli) for download.
- **Central logging, monitoring, metrics, IDS, vulnerability scanning**: Data across all hosts flow into a central set of hosts that address various requirements such as logging, etc. We will go into this in more detail in a subsequent post.

## Docker Hosts and Configuration

All our configuration management is managed by Salt which ensures that the core OS, kernel, and other packages (including Docker of course) are installed, up to date with security patches, and in sync with all other hosts. The following image shows the key components of the software installed on each Docker host:

![Docker host configuration](/assets/img/posts/docker_host.png)

The couple of extras that we add on and that would be useful to call out are:

- **The bidding/orchestration agents** (a.k.a. Strider): These are the agents on each host that receive requests to submit bids for deployment jobs. The agents submit a score based on various metrics such as available RAM, disk capacity, etc. If the submitted bid is a winning bid, the agent then becomes responsible for the care and feeding of that job (typically a running Docker container) for the duration of that job's life cycle. These agents also take care of injecting sensitive information into containers right before those containers are started - sensitive information is distributed to agents on a "need to know" basis using a push model. Did we mention we are big fans of the least-privilege principle?
- **Recovery scripts** (a.k.a. Sceptre): Our PaaS has unfortunately been subjected to (more than) our fair share of stability issues outside of our direct control: by our hosting provider due to hardware failures or unexplained software failures, by our operating system due to bugs in the Btrfs filesystem code, by security vulnerabilities that require patches to Xen/KVM which trigger mandatory restarts, etc. These experiences led us to create a "first response" utility that takes care of detecting and correcting problems that occur during unclean shutdowns. As part of its duties, Sceptre tracks all running Docker containers on a host and ensures that these start back up after a machine reboots for any reason. We'll write up some more on this shortly.

## Filesystem

Docker's choice of file systems has been challenging to work with to say the least. Our initial choice of AUFS (in mid 2014) led to some show-stopping deployment issues. For various reasons that were not easy to immediately work around, our build process resulted in some customers having Docker images with 50+ layers; deploying these images triggered some bugs in Docker and the AUFS file system that manifested in not-so-obvious ways. Most Linux distributions have already (or will be soon) deprecated AUFS support, so in the name of future compatibility we chose to go with Btrfs. And we have run into several painful problems in a relatively short period of time:

- **Side effects from core design choices**: By default, Btrfs does some interesting things when allocating disk space and mapping file extents to this disk space. An [in-depth description of how Btrfs works](https://en.wikipedia.org/wiki/Btrfs#Design) is beyond the scope of this article; suffice it to say that when subjected to our Docker-heavy workloads, overall disk performance starts to degrade and we commonly see fragmented files and discrepancies between disk space usage as reported by `btrfs fi show` and disk space usage as reported by `du`.
- **The need to perform expensive "rebalances"**: The typical procedure to fix Btrfs fragmentation and performance degradation problems is to run a Btrfs rebalance, which walks internal Btrfs disk structures and attempts to repack data to make better use of overall disk space. The problem is that this is a *very* expensive operation to run on production machines, and if done carelessly the rebalance operations can choke a machine with incredible loads or render a machine unusable if not enough disk space is available for these operations. [The Btrfs implementation in more recent Linux kernel versions](https://btrfs.wiki.kernel.org/index.php/Changelog) supposedly does a better job of reducing the need for manually triggering balance operations, but we haven't been able to verify that with our workloads. As a workaround, we run very light rebalance operations outside of our customer's core business hours and carefully schedule more aggressive operations when the filesystem inevitably degrades.
- **Efficiency issues**: Given the design choices and the limitations of the Btrfs implementation we're currently using, it's not uncommon to see a Btrfs file system allocate up to 3x, 4x, or even 5x the amount of actual space being used. This would not be problematic if the allocations stay stable as disk usage increases - unfortunately, this is not the case, and without vigilant monitoring and manual intervention these efficiency issues quickly turn into stability problems as system calls fail with `ENOSPC` (even though a fraction of the disk is actually in use).
- **Stability issues**: The icing on the cake has been the soft- and hard-lockups and kernel panics that we've experienced, usually when the system is processing higher levels of I/O. These have often occurred at odd hours during the night, like a 3AM wakeup call from a sadistic machine that finds your nightly need to sleep "quaint." As previously mentioned, several of our problems may be addressed in more recent kernel versions, but [reading the Btrfs changelog of bugfixes](https://btrfs.wiki.kernel.org/index.php/Changelog) sometimes feels like reading a horror story of all the things that could have (or have already) gone wrong with a server in our production environment.

At the end of the day, we just came to the conclusion that this was something that we'd have to live with until the next, newer, better filesystem comes along. OverlayFS and ZFS on Unix seem promising but will of course need more testing and tuning. With that in mind, here are a few things that we did. Hopefully, this is something that you find useful.

1. **Run garbage collection regularly** but don't be over-aggressive with the rebalance factor: We started with [Spotify's GC script](https://github.com/spotify/docker-gc). Spotify's GC script is a few hundred lines of bash. Our developers wrote their own version in Python and that script is even smaller. It is specific to our deployment models. Another topic to write more about.
2. **Keep your images small and your image layer count low**: This is key given Btrfs challenges around fragmentation. This also helps speed Docker image management - the graph drivers seem to use O(n^2) algorithms in places that cause innocuous questions like "What images are present on this machine?" to take ages to complete.
3. **Create appropriate alerting**: We put in alerts that are triggered when Btrfs allocations reach 80% of available disk space. Yes, that is 80% of allocations (*not* disk usage!) because that's the beginnings of trouble and it is much better to catch this issue when you actually have enough space to run a proper rebalance rather than when it is too late and the partition is completely broken. If you haven't been keeping up with your Btrfs rebalances at that point, prepare to carefully watch the machine for a few hours to ensure that the expensive rebalance eating up precious CPU and disk bandwidth will not run into a nasty bug that causes a soft lockup or kernel panic.
4. **Rebalance regularly**: Do non-aggressive rebalances at times of low system usage and run it as a regular `cron` job.

## Docker Container Services

As described [previously](https://engineering.catalyze.io/Building-a-secure-multi-tenant-Docker-based-Platform-as-a-Service-Part-1-Design-Considerations.html), we leverage [progrium's](http://progrium.com/blog/) [buildstep](https://github.com/progrium/buildstep), which in turn leverages [Heroku's buildpacks](https://devcenter.heroku.com/articles/buildpacks), to simplify the definition and build process of customer applications. This also implies instant support for a [variety of languages](https://resources.catalyze.io/paas/paas-faq/buildpacks/).

From a database perspective, we go above and beyond what Heroku provides by providing support for not only just Postgres but also for MongoDB and MySQL. Due to licensing issues we actually use [Percona](https://www.percona.com/) rather than the vanilla MySQL; Percona also has the benefit of some additional features we plan on taking advantage of soon.

For cache and cache-like services, we also offer first-class support for Redis and memcached.

In addition to customer-specific containers, every Catalyze customer also gets the following containers for each of their applications:

- **A Docker-ized ELK logging stack**: This is the ElasticSearch, Kibana, Logstash ([ELK](https://www.elastic.co/products)) stack. We felt it necessary to provide this to our customers in both their development and production environments. This was a safer bet than assuming that developers would always do the right thing and scrub their application and database logs for [PHI](https://catalyze.io/learn/what-is-protected-health-information-or-phi) data. This also has the additional advantage of customers not having to pay extra for a logging solution which could get very expensive very quickly. Each customer can access their logging environment via an URL which looks something like this - `https://{your-Catalyze-address}/logging/`.
- **A Docker-ized monitoring solution**: Every customer environment also gets a dedicated [Sensu](https://sensuapp.org/) deployment. This is set up to automatically monitor all the customer containers and will shortly also allow the ability for customers to specify additional processes that they would like monitored **inside** their own containers. Each customer can access their monitoring environment via an URL which looks something like this - `https://{your-Catalyze-address}/monitoring/`.
- **A service proxy container**: The service proxy container is a customized [nginx](http://nginx.org/) container that takes care of things such as SSL termination, basic load balancing (where appropriate), and routing within the customer environment.
- **A private overlay network**: This is one of our platform's unique offerings. We have a overlay networking solution that boasts not only the ability for each container to get it's own IP address but also takes care of things such as completely segregating traffic from different environments, even if those containers are running on the same Docker host. It also, by default, encrypts traffic via customer-specific TLS keys and does all this while enabling 1Gbps+ throughput using minimal amounts of CPU. This is something we're very excited about and will be writing and sharing more details soon.

All of the container types - application, database, and cache containers - are available in a single node deployment or in Highly Available (HA) deployments. HA deployments imply different things in each of these cases. So we'll take a couple of minutes to describe that:

- **HA code containers**: This implies that the application containers can be scaled out as need be. We take care of wiring them up to the database and cache containers as specified and also to the service proxy and thus to the environment's load balancers provided by the IaaS provider. Scaling out application containers both in terms of size (amount of associated RAM) and number doesn't require any downtime due to the way our platform leverages Docker.
- **HA database containers**: HA implies different things in the context of databases. A Postgres master-slave setup is pretty easy to set up. But requiring auto-failover also requires the use of [pgbouncer](https://wiki.postgresql.org/wiki/PgBouncer). MongoDB HA can be achieved in various ways but we've chosen to go down the path of using [replica sets](http://docs.mongodb.org/master/reference/glossary/#term-replica-set) (with an [arbiter](http://docs.mongodb.org/master/reference/glossary/#term-arbiter) as necessary). MySQL HA is the most painful of the lot to setup and has required the most effort as MySQL HA requires that the IP addresses be known in advance. This has challenges in the Docker world due to the lack of native IP address support and the fact that the containers could move across hosts during a re-deployment or migration. We'll write up more about this shortly as well.
- **HA cache containers**: For Redis we have chosen to go with the [sentinel approach](http://redis.io/topics/sentinel) where we setup a pair of Redis nodes and an associated set of sentinel containers (these sentinel containers are very small nodes). This supports auto-failover scenarios.


![Customer Docker Container Sets](/assets/img/posts/customer_containers.png)


# So What Happens When a Customer (You) Pushes Code to Catalyze?

<blockquote>
    <p>I got the magic in me.</p>
    <p>— B.o.B, from the album "B.o.B Presents: The Adventures Of Bobby Ray" (2010)</p>
</blockquote>

After you push code to the Catalyze git server, a commit hook sends a notification that causes our orchestration layer to schedule a build job. Once the build job is picked up by a build agent, the latest code is pulled down from the Git repository and packaged into a Docker image. (As previously mentioned, this process uses [Heroku's buildpacks](https://devcenter.heroku.com/articles/buildpacks) by way of [buildstep](https://github.com/progrium/buildstep) to build and package the application.) Once the image has successfully built, it is pushed to a private Docker registry, and the subsequent "build successful" signal triggers the platform to ask the scheduler to spawn a new deployment job or set of jobs for that image. The scheduler places this job based on bids received from orchestration agents, which take into account any placement rules such as constraints for HA configurations, etc. When an orchestration agent wins the job bid, the agent pulls down the latest service image from the Docker registry, injects sensitive data into it, and configures it with the customer's requested environment variable settings. If this is the first container for a particular environment, the agent also configures the overlay network service using that environment's network keys. Finally, the agent assigns the new container a unique IP address on the overlay network and starts the container.

For each Catalyze environment there are several background services working for you. The most notable is the "service proxy", which is the public entry point into your Catalyze environment. The service proxy contains an Nginx service set up as a reverse proxy to route traffic to the appropriate destination. All traffic must pass though the service proxy, and to comply with the current industry [business associate agreements](https://catalyze.io/learn/business-associate-agreements) (BAAs), SSL traffic is terminated behind the load balancer within your dedicated service proxy. After the SSL has been terminated, requests are forwarded onto your application. Note that any traffic passing out of the service proxy is sent over the private, encrypted network that we have set up for you, and is encrypted with a TLS key specific to your environment. Data is never sent in the clear even within your environment.

Other background services include the monitoring and logging services previously described. Don't forget to check these services out at `https://{your-Catalyze-address}/logging/` and `https://{your-Catalyze-address}/monitoring/` - they will come in handy as you monitor and grow your application!
