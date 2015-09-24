---
title: Docker *is* sort of ready for production, at least for a PaaS
date: 2015-09-25
author: adam
author_full: Adam Leko
author_alt: Mohan Balachandran
tags: Docker,security,PaaS,Platform as a service,
---

A little while ago, there was a [post](http://sirupsen.com/production-docker/) on [hackernews][hn_link] about the readiness of Docker for use in production. At Catalyze, we have been running Docker in production for almost a year now (10 months to be precise) and have run into the challenges that the author mentions in the article over and over again. We have also figured out solutions to some of these problems and felt that it would be worthwhile to share our thoughts on each of the points that he raises. Additionally, we hope to give you an overview of how we address some of those challenges either using tools which already exist or tools that we have created and hope to share soon.

We've written earlier about the design of the Catalyze PaaS [earlier][design_link] and also about its [implementation][impl_link].

Basically, at Catalyze, we've found workarounds or solutions to all the pain points he writes about. Let's take each of them in turn.

- **Building**: As discussed in the earlier posts around the [design][design_link] and [implementation][impl_link] of the Catalyze PaaS, we currently leverage [buildstep][buildstep_link] to build the docker images. This does have the restriction that you have to work with buildpacks and not the Dockerfiles directly. But thus far, this has been an acceptable tradeoff. So currently, for our customers, buildstep handles most of those pain points. For internal images, we have our own internal base image and inject config changes right before deploys, so they don't need to be built from scratch on _every_ build. *We expect to shortly allow customers to work with Dockerfiles directly. [What's the design approach that we have taken? How will it be implemented? How will it be made available to end users?]. The approach was meant to initially allow end users to manage their nginx config files as an example by themselves. The approach also lends itself to direct Dockerfile management.* 

- **Garbage collection**: We started off using Spotify's garbage collection [script][gc_link] which is a few hundred lines of bash. We wrote a Python GC script that is even smaller that met our specific use cases and deployment model. It's not really that difficult to put something together based on your needs, especially in the context of all the other things you have to have in place to deploy distributed Docker jobs to begin with. We'll open source this shortly as soon as we clean up the bits that are specific to us and also some general code clean up to make it more presentable. *[we shoud do this right away along with this post as perhaps a gistfile]*

- **Iteration speed**: This hasn't been a major issue for us since we've put together internal tooling which addresses those shortcomings *[such as ?]*. The article mentioned the plugin stuff in that section (volumes, networking, etc). We get around that by using an agent that deploys Docker jobs, as opposed to something like swarm (which would require the plugins to be in place in order to do any interesting stuff while bringing up the container). *[is a bit condensed here. bit more detail would be nice.]*

- **Logging**: We also managed this internally ourselves before logging got improved upstream. As explained in an earlier [blog post][impl_link], every one of our customers gets their own ELK instance. We centrally log and monitor containers as well. If you want to do things in a more Docker-centric way there's always [Logspout][logspout_link].

- **Secrets**: We use a private registry and avoid publishing secrets by 1) controlling behavior with environment variables where possible, and 2) injecting secret data into the container image just before running where that is not possible.

- **Filesystems**: Amen!! We agree with most of the points the author raises. We wrote about the challenges [earlier][impl_link] as well. We're making do with btrfs right now. Things are certainly much better if you go out of your way to keep your images small, image layer count low, and do periodic cleanup/GC maintenance on your Docker hosts. This is currently the weakest area of Docker that is very difficult to work around, but we're optimistic about either OverlayFS or ZFS on Linux. 

- **"Edgy" kernel features**: We've run into a few stability issues that were likely caused by cgroups and/or network namespaces. They tend to happen more with misbehaving applications (CPU/disk/memory thrashing), so this can be mostly mitigated by setting appropriate limits using more traditional means inside the container. The PID 1/zombie cleanup issue _really_ needs to be address by Docker, but in the meantime using supervisord or runit is not hard.

- **Security**: We weren't quite sure what the point here is. Kernel-level namespacing and cgroups have a decent track record, but like anything, security needs to be managed in layers and a security focus must be omnipresent throughout your infrastructure. All the usual suspects (least-privilege, mandatory access controls where possible, etc) still apply in a container-driven world.

- **Image layers**: These are good points. we agree that imaging could be drastically improved in terms of flexibility and performance (especially push/pull speed), but what Docker provides is way better than manually shipping around gigantic tarballs. We think the open container format will encourage innovation here; the field is wide open.

In his final point, he mentions that most companies are "shooting for the stars of a PaaS," which is actually a very good analogy. By itself Docker requires a lot of extra infrastructure to actually use in deployment, and key pieces of that infrastructure have been missing or immature up until now. For typical use cases, nearly all of these limitations can be worked around with a little bit of effort, but that effort is probably not justified unless you absolutely require the functionality Docker provides. At the moment I think most users would be better served by using a managed PaaS solution (Catalyze, Amazon ECS, etc.), unless they have extreme scale or finicky deployment needs.

This is no different than days of IaaS yore - nowadays it is generally accepted that it is almost always preferable to leverage AWS or Rackspace hosting rather than going through the pain of hosting your own hardware and VMware/Xen instances. Perhaps efforts like Kubernetes will make it more common for users to manage their own platform infrastructure, but I think that will end up going the way of OpenStack and most users will settle on hosted services (on-prem or off-prem). In that world having standardized container formats and tooling is a huge win, and that is exactly what Docker gives you.

[hn_link]: https://news.ycombinator.com/item?id=9961537
[design_link]: https://engineering.catalyze.io/Building-a-secure-multi-tenant-Docker-based-Platform-as-a-Service-Part-1-Design-Considerations.html
[impl_link]: https://engineering.catalyze.io/Building-a-secure-multi-tenant-Docker-based-Platform-as-a-Service-Part-2-Implementation.html
[logspout_link]: https://github.com/gliderlabs/logspout
[gc_link]: https://github.com/spotify/docker-gc
[buildstep_link]: https://github.com/progrium/buildstep