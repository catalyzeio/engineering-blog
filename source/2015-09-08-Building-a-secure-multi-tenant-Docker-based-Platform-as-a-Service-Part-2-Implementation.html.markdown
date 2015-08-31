---
title: Building a secure, multi-tenant Docker based Platform as a Service - Part 2: Implementation 
date: 2015-09-08
author: mohan
author_full: Mohan Balachandran
author_alt: Adam Leko, Nate Radtke, Vince Kenney
tags: PaaS,Platform as a service,Docker,Multi-tenancy,Orchestration,Docker Networking
---


Based on all the above requirements, we arrived at the following architecture and naming conventions.

### IaaS provider neutrality
We started off on Rackspace but it was always our intention to **also** provide our services on AWS, Azure and other cloud providers. We now run on both Rackspace and AWS with support for Azure coming shortly. We also managed to get two full external HIPAA audits done and achieved [HITRUST](https://hitrustalliance.net/) [certification](https://catalyze.io/hitrust).

Given the various requirements imposed by the IaaS provider BAAs (and they are all different) such as use of specific machine flavors, subset of usable services, SSL termination requirements, hardware requirements etc., we had to build in some additional capabilities into our software. Generally, however, we use the following sets of services from every IaaS provider:

- **Load Balancers**: Elastic Load Balancers - ELB (AWS), Cloud Load Balancers - CLB (RAX and Azure)
- **Compute instances**: Elastic Compute Cloud - EC2 (AWS), Cloud Servers (RAX), FIXME (Azure)
- **Block stores** (all SSD): Elastic Block Stores - EBS (AWS), Cloud Block Store - CBS (RAX), FIXME (Azure)
- **Blob stores**: Simple Storage System - S3 (AWS), CloudFiles - CF (RAX), FIXME (Azure)

### Pods

Within each IaaS provider, we use [Salt](http://saltstack.com) as our configuration management system to provision a set of hosts / VMs wth specific characteristics such as sizing, specific sets of packages, kernel versions, OS versions (Ubuntu 14.04), AppArmor profiles. Block stores are similarly provisioned on each of those hosts as well (additional blocks get added on dynamically based on customer requirements). Other things like load balancers etc. get added on as needed. We use a dedicated pair of load balancers for each of our customers. This collection of hosts is called a Pod. A Pod can have two deployment models 

- **Standalone**: This model includes not only the Docker hosts onto which all our customer and supporting containers are deployed but also contains a set of management hosts which take care of all the other things required to make Docker and our PaaS work (see next section for more details). See below of an image depicting the strucure of a Standalone pod.
- **Slave**: This model only contains a set of Docker hosts. This is a "slave" pod managed by the management infrastructure already deployed in another Standalone pod. 

![Architecture of a Standalone Pod](/assets/img/posts/standalone_pod.png)

We have also designed the Pods to be something that can go across multiple availability zones (AZs in AWS) and multiple regions. These spanning pods have been nicknamed "Super Pods". 

### Management Infrastructure

The management infrastructure required to run the Catalyze PaaS have been described earlier during the design discussions. There are several components in the management infrastructure and are shown in the diagram below. 

![Architecture of the Management Infrastructure](/assets/img/posts/management_infra.png)

The nature of each of these components have been discussed before but just as a quick summary to save you some time scrolling back and forth:

- **The git server**: This is where customers push their code to. Each customer has their own unique git url. 
- **The build server(s)**: These are where the Docker container images are built based on the code pushed by our customers. There are usually several of these so that building of Docker images can happen in parallel. 
- **The Docker registry**: This is where the docker images are sent to, stored and subsequently downloaded. This is a private registry.
- **The Orchestration layer** (a.k.a. Sauron - the all seeing eye): Consists of the scheduler, registry (and a couple of other components known internally as Legolas and Elvish). This layer takes care of receiving the bids from the individual Docker hosts, assigning deployment jobs to specific docker hosts based on various customer specific prefers/rejects rules described earlier and creating the secure, encrypted overlay network (a.k.a. Shadowfax internally and soon to be released under a different name). The orchestration layer was initially written in Python but has now been re-written in Go. Look for a more detailed post on that coming up as well.
- **The Pod API**: The Pod API is the overall coordinator between all the various components i.e. it manages things like translating the the customer requests, triggering builds and deploys / re-deploys, making the translations needed by the orchestration and other components, tracking jobs etc. 
- **Secure console**: We do not provide direct root SSH access into either the hosts or the containers. We operate very heavily on the Least-Access principle. However, customers do need direct access to their containers at times e.g. Rake tasks which is enabled via our secure console. More details are availble on this capability on [this blog](FIXME). 
- **The Customer API**: The customer API is responsible for managing aspects of contracting, communicating with the dashboard and CLI, ensuring authentication and authorization etc.
- **The Dashboard and CLI**: The dashbaord is the developer's UI into setup and management of their various environments. Since developers do prefer the command prompt, we have a CLI as well which leverages the Customer and Pod APIs to facilitate that interaction. This was initially written in Python but has now been re-written in Go and is available [here](https://github.com/catalyzeio/cli) for download.
- **Central Logging, Monitoring, Metrics, IDS, Vulnerability Scanning**: Data across all hosts flow into a central set of hosts that address various requirements such as logging etc. We will go into this in more detail in a subsequent post. 

### Docker hosts and configuration
All our configuration management is managed by Salt as described earlier which ensures that the core OS, kernel and other packages including of course, Docker are installed are common and in sync with all the other hosts. The following image shows the key components of the software installed on each Docker host:

![Docker host configuration](/assets/img/posts/docker_host.png)

The couple of extras that we add on and that would be useful to call out are:

- **The Bidding agents** (a.k.a Hobbits): These are the agents on each host that receive requests to submit bids for deployment jobs. The agents submit a score based on various metrics such as available RAM, disk capacity etc. This is a relatively simplistic bidding agent but can easily be enhanced / evolved. 
- **Recovery scripts** (a.k.a. Sceptre): We have been subjected to one too many random reboots triggered by our hosting provider at times for no apparent or known causes, because the BTRFS file system tipped the entire host over (see next section for some of our filesystem learnings), because of KVM or Xen vulnerabilities etc. All of these led us to create a first pass on an auto heal system called Sceptre. Sceptre keeps track of running containers on each host. When the VM receovers (usually in a couple of mins or less), Sceptre is always invoked as part of the startup process and that immediately restarts all the Docker containers that were on that host. We'll write up some more on this shortly.



### Filesystem
Docker's choice of file systems has been challenging to work with to say the least. Our initial choice of AUFS (in mid 2014) led to various issues such as limitations in the number of layers in the docker image. This is usually not a problem but when we had some customers with 40+ environment variables (and yes, we could concatenate them into one layer but that can also result in other challenges / speed trade-offs. We have addressed that differently and we'll also be writing about that shortly). AUFS has of course, now been "deprecated" by Docker. We chose to go with BTRFS almost a year ago. And we have run into every problem imaginable with it:

- **Its inherent challenges**: Auto-rebalancing was added only recently (VERSION # FIXME) but requires upgrading our Kernel (VERSION # FIXME). Which we are a bit loath to do (rebooting customer instances isn't something we do lightly). Comprehensive testing was done but didn't leave us much more confident. So we dediced to stick with the version (VERSION # FIXME) we had experience with. It lies to the kernel for example (```du -fs``` doesn't guranatee an accurate response).
- **Its inefficiency**: BTRFS is known for managing fragmentation poorly. This also results in significant overhead and loss of capacity. Numbers such as 50% overhead are not uncommon (some more details needed here - FIXME)
- **Its lack of stability**: Throw several jobs on a BTRFS based host at the same time and don't be surprised when the host crashed with a Kernel panic. We've seen a lot of ```@@@@@@``` and usually at 3 am.

At the end of the day, we just came to the conclusion that this was something that we'd have to live with until the next, newer, better FS comes along. OverlayFS and ZFS on Unix seem promising but will of course need more testing and tuning. With that in mind, here are a few things that we did. Hopefully, this is something that you find useful.

1. **Run garbage collection regularly** but don't be over-aggressive with the rebalance factor: We started with [Spotify's GC script](FIXME). Spotify's GC script is a few hundred lines of bash. Our developers wrote their own version in Python and that script is even smaller. It is specific to our deployment models. Another topic to write more about. 
2. **Keep your images small and your image layer count low**: This is key given BTRFS challenges around fragmentation.
3. **Create appropriate alerting**: We put in alerts that are triggered when usage hits 50% (FIXME). Yes, 50% because that's the beginnings of trouble and it's much better to catch the issue then as the disk will actually have enough space to speed up the rebalance. The rebalance is going to be slow no matter when you do it but if you try to run it when you have 10-20% of free space, resign yourself for a several hour wait during which your CPU usage will skyrocket making that host virtually unusable. And please, do not stop the rebalance once it has started.
4. **Rebalance regularly**: Do the rebalances at times of low system usage and run it as a regular cron job.


### Customer Docker container sets

As described [elsewhere](FIXME), we leverage [Heroku buildpacks](FIXME) to simplify the definition and build process of the customer applications. This also implies instant support for a [variety of languages](FIXME). From a database persepctive, we go above and beyond what Heroku provides by providing support for not only just Postgres but also for MongoDB and MySQL (we actually use [PerconaDB](FIXME) rather than the core MySQL because of licensing issues. Percona does come with additional features as well which we don't fully leverage as of yet). Additionally, we also support Redis and memcached as caches as well. 

In addition to the customer specific containers, every Catalyze customer also gets the following containers for each of their applications. Namely,

- **A dockerized ELK logging stack**: This is the ElasticSearch, Kibana, Logstash ([ELK](FIXME)) stack. Much has been written about this [elsewhere](FIXME). We felt it necessary to provide this to our customers in both their development and production environments. This was a safer bet than assuming that developers would always do the right thing and scrub their application and database logs for [PHI](FIXME) data. This also has the additional advantage of customers not having to pay extra for a logging solution which could get very expensive very quickly. Each customer can access their logging environment via an URL which looks something like this - `https://{url}/logging/`
- **A dockerized monitoring solution**: Every customer environment also gets a dedicated [Sensu](FIXME) deloyment. This is setup to automatically monitor all the customer containers and will shortly also allow the ability for customers to specify additional processes that they would like monitored **inside** their own containers. Each customer can access their monitoring environment via an URL which looks something like this - `https://{url}/monitoring/`
- **A service proxy container**: The Service Proxy container is a customized nginx container that takes care of things such as SSL termination, basic load balancing where appropriate and routing within the customer environment. 
- **A private overlay network**: This is one of our crowning achievements (a.k.a Shadowfax or ssdn). We have a overlay networking solution that boasts not only the ability for each container to get it's own IP address but also takes care of things such as wiring up the customer specific containers only to each other and only as specified (my app container only needs to to talk to my cache and database, my database however doesn't need to talk to my cache). It also, by default, encrypts all customer specific networks with the customer's TLS keys and does all this while enabling almost line rate speeds with full encryption turned on and with a minimal CPU hit. This is something we're very excited about and will be writing and sharing more about it soon. 

All of the container types - application, database and cache containers are available in a single node deployment or in Highly Available (HA) deployments. HA deployments imply different things in each of these cases. So we'll take a couple of mins to describe that:

- **HA code containers**: This implies that the application containers can be scaled out as need be. We take care of wiring them up to the database and cache containers as specified and also to the service proxy and thus to the load balancer(s) provided by the IaaS provider. Scaling out application containers both in terms of size (amount of associated RAM) and number doesn't require any downtime because of the nature of how Docker works.
- **HA database containers**: HA implies different things in the context of databases. A Postgres master-slave setup is pretty easy to set up. But requiring auto-failover also requires the use of [pgbouncer](FIXME). MongoDB HA can be achieved in various ways but we've chosen to go down the path of providing an [arbiter](FIXME). MySQL HA is the most painful of the lot to setup and has required the most effort as MySQL HA requires that the IP addresses be known in advance. This has challenges in the Docker world due to the lack of native IP address support and the fact that the containers could move across hosts during a re-deployment or migration. We'll write up more about this shortly as well.
- **HA cache containers**: For Redis we have chosen to go down the Sentinel approach where we setup a pair of Redis nodes and an associated set of sentinel containers (these sentinel containers are very small nodes). This supports auto-failover scenarios.


![Customer Docker Container Sets](/assets/img/posts/customer_containers.png)


# So What happens when a customer (you) pushes code to Catalyze

>  I got the magic in me..
>   — B.o.B, from the album "B.o.B Presents: The Adventures Of Bobby Ray" (2010)"

Upon pushing code to the Catalyze Git service, a notification is sent to orchestration to schedule a build job. Once the build job is picked up by a builder agent, the latest code is pulled down from the Git repository and packaged into a Docker container. As previously mentioned, this process uses [Buildstep](FIXME) to build and package the application utilizing buildpacks by Heroku. Once the container has successfully built, it is pushed to a private Docker registry. A "build successful" signal is received by the Platform and a new job is sent to orchestration to schedule the application deployment. Each of the eligible orchestration agents returns a bid to the scheduler indicating their availability to accept the new job. An orchestration agent may not be elegible/available to receive a job if it has a conflicting assignment such as an existing job in an HA (highly available) configuration. When an orchestration agent wins the job bid, the agent pulls down the latest service image from the Docker registry and starts up the container. At that time the network is configured with the environment's network keys and ability to talk to and discover other containers on the private overlay network.

For each Catalyze environment there are several background services working for you, the most notable is the Service Proxy. The Service Proxy is the public entry point into your Catalyze environment. The Service Proxy contains an Nginx service setup as a reverse proxy to route traffic to the appropriate destination. All traffic must pass though the Service Proxy and to comply with the current industry BAAs SSL traffic must be terminated behind (not on) the load balancer (we have chosen to terminate SSL here, within the Service Proxy). After the SSL has been terminated, requests are forwarded onto your application. Note that any traffic passing out of the Service Proxy is sent over the private, encrypted network that we have set up for you and is encrypted with your TLS keys. Data is never sent in the clear even within your environment.

Other background services include monitoring and logging services. The monitoring service runs the Sensu monitoring framework, through your environment's temporary (Catalyze) URL the service is accessible at `https://{url}/monitoring/`. The logging service contains the ELK (Elasticsearch, Logstash, Kibana) stack where all of your application, database, etc logs are aggregated and searchable. You can access the logging service through the temporary (Catalyze) URL at `https://{url}/logging/`.