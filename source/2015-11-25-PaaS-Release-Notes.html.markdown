---
title: Catalyze PaaS Release Notes 
date: 2015-11-25
author: adam
author_full: Adam Leko
author_alt: Mohan Balachandran
tags: PaaS, docker, maintenance, release, new features
---

# Release notes

At Catalyze, we work towards continually improving our PaaS offering. It would be presumptous of us to set a pre-defined roadmap of functionality that we scrictly adhere to. We are here ultimately to serve our customers and our customers are a significant source of suggestions to help make our product better. We take as much feedback as possible and try to work it into the product release roadmap.

We have a maintenance window [earlier this week](http://status.catalyze.io/) to address some VPN hardware and software upgrades and slotted in some significant feature enhancements during that same period. 

## Faster deployment times
For some quick background, Catayze currently follows a `git push` process based on Heroku buildpacks. Once the `git push` happens, we download the appropriate dependencies, build the appropriate Docker containers, push it up to a private registry and is then deployed on a machine that satisfies various constraints. The Docker registry process is a slow one and we were inundated with requests to figure out how to make the build process faster. We knew of an approach we could take to make that happen excluding the the registry workflow which is beyond our control (thus far).

We figured that a significant amount of time was spent downloading dependencies so that is what we focused our initial attention on. Our approach was to attach a volume (EBS) to each of our build hosts (there are multiple of them so that customer builds are rarely queued) so that caches could be retained between builds. So the build servers now retain the `/tmp/cache` directory in between builds for the same service. this isn't shared between hosts so depending on frequencies of builds this may not take effect immediately (depends on workload distribution), but internal testing shows this ​_significantly_​ cuts down on `bundler` and asset generation overhead during builds. 

We implemented and tested this approach out and were able to see a pretty significant improvement - anywhere from 30-60%. After rolling this out, we got some initial feedback from one of our customers that build times have dropped close to 50% for them. 

The only caveat here is that the cache is specific to each build host so if for some reason your build gets sent to a different host, the initial build might be a bit slower but is likely to be speeded up significantly on each successive build.

This feature has been rolled out across our entire platform and is available to all our customers. We welcome any feedback and suggestions.


## Pre and post "build" hooks
By default, we err on the side of security and caution. For that reason, the build hosts were isolated from the private internal encrypted network that we set up for each of your environments. This however, caused some issues with development processes which needed access to the database (for example to run a `rake db:migrate`). While this seems simple, there is some complexity to the task. The build "job" needs to be **temporarily** linked to the customer's environment and once the build is successful, then the link needs to be torn down. Similarly, there was a need to run tasks after the build process is complete such as asset compilations etc.  Once the networking angle was figured out, we extended the feature to support hooks that can be called **before** (`pre-build`) and **after** (`post-build`) the buildpack runs successfully. These hooks will run as an unprivileged user, and are expected to be executable files located at `.catalyze/pre-build` and `.catalyze/post-build` in your git repo. Note the two points mentioned above: 

- unprivileged user: This is to ensure continued security of your environment
- location: they have to be in the directories specified 
- executable: you might have to set the appropriate permissions to make them executable i.e. `chmod +x` for just those directories.

If either the pre-build or post-build hooks fail, the build will be marked as failed. failure should be indicated in the usual way with a non-zero exit code.

This feature is now live and available to all our customers. We welcome your feedback and suggestions.


## CLI updates

There were also a few minor improvements to the CLI that went out (sorted env vars, warning that a redeploy is necessary when changing an env var). The full list of changes is available at the [CLI repo](https://github.com/catalyzeio/cli/releases/tag/2.1.5). You might have already received this update. 
