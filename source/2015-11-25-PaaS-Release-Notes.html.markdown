---
title: Catalyze PaaS Release Notes
date: 2015-11-25
author: adam
author_full: Adam Leko
author_alt: Co-Authors - Mohan Balachandran
tags: PaaS, docker, maintenance, release, new features
---

# Release Notes

At Catalyze, we are continually working to improve our PaaS offering. We are ultimately here to serve our customers, and our customers are a significant source of suggestions that help make our product better. Rather than setting a rigid pre-defined roadmap of functionality that we strictly adhere to, we instead take as much feedback as possible and try to work it into our product release schedules.

[Earlier last week](http://status.catalyze.io/) we scheduled a maintenance window to address some necessary VPN hardware/software and other security upgrades. Given our overall platform improvement strategy above, we decided to take advantage of this downtime to roll out a few significant feature enhancements that have been requested by customers. As these features have been live for a few days now we decided it would be a good idea to put together a few quick notes on how to best make use of them.

*Note:* The build-related improvements described below are only available to customers running on our Amazon AWS pod. If your environment's temporary URL beings with `pod02` you will have access to these features. Unfortunately we're not able to offer these improvements to customers running in our older pod (`pod01`) at this time.

## Faster Builds

[As we've previously written](https://engineering.catalyze.io/Building-a-secure-multi-tenant-Docker-based-Platform-as-a-Service-Part-2-Implementation.html), we currently provide a `git push` model for customers to build and deploy their applications via Heroku buildpacks. This process allows us to support a wide variety of application types at the expense of being a bit "heavyweight" in terms of overall deployment times. While some of the build and deploy delays are [not](https://github.com/docker/docker/issues/7291) [easily](https://github.com/docker/docker/issues/10269) [worked](https://github.com/docker/docker/issues/14018) [around](https://github.com/docker/docker/issues/13250), we received several requests to speed up the overall build process, so we analyzed our build logs to determine what could be improved.

After looking through statistics for quite a few builds we discovered that the longer builds spent an inordinate amount of time downloading dependencies and generating static assets, activities that can (and should) be retained across builds. We ended up completely revamping our build process to make it more general -- incidentally, working around another set of [Docker limitations](https://github.com/docker/docker/issues/14080) -- and added support for retaining the `/tmp/cache` directory across subsequent builds on the same build host.

This cached directory is separate for each application service in an environment. Internal testing has shown _significant_ improvements in overall times for the dependency downloading and asset generation phases of the build, in one case resulting in a 50% reduction in overall deployment time.

Currently the build cache is not shared across build hosts. Since build jobs are distributed across build hosts based on demand, it may take a few tries to seed all the caches. Once the cache has been primed subsequent builds on that build host should be must faster.

This feature has been rolled out across all customers on our Amazon AWS `pod02` pod. We hope you enjoy the reduced build times -- our build servers certainly have!

## Pre- and Post-Build Hooks

As a general rule we err on the side of caution, especially when it comes to issues related to security and privacy. For that reason we have been very conservative when it comes to the environment in which we build customer containers, keeping them completely isolated from production environments. However, we knew this was overly restrictive for some deployment scenarios, particularly ones that rely on a database migration (`rake db:migrate`) to successfully finish before a new code version can be safely rolled out.

With our newly-revamped build process in place we weighed the risks and decided that we could slightly relax our build environment restrictions. We now allow a **temporary** connection from builds to the dedicated encrypted network that backs your deployment environment. With this in place we added support for two extension points in the build process:

1. A pre-build hook that executes just *before* the buildpack starts executing -- `.catalyze/pre-build`.
2. A post-build hook that executes just *after* the buildpack finished executing -- `.catalyze/post-build`.

In order to take advantage of these hooks, the scripts must be in the above locations in your Git repository, and the scripts *must* be committed as executable files. A quick example using our Node.JS example app:

```
$ cd nodejs-example-app
$ cat .catalyze/pre-build
#!/bin/sh -e
echo Howdy from the pre-build script!
$ cat .catalyze/post-build
#!/bin/sh -e
echo Howdy from the post-build script!
$ chmod +x .catalyze/pre-build .catalyze/post-build
$ git add .catalyze/pre-build .catalyze/post-build
$ git commit -m "Added pre- and post-build scripts"
```

The pre-build hook script will have access to your private encrypted network, but keep in mind that since it runs before the buildpack most utilities (`rake`, `npm`, etc.) will not be available. The post-build script will have access to your private encrypted network along with any software installed as part of the build pack.

There are a few things to keep in mind when working with the build hooks:

1. The hook scripts must added under the `.catalyze` directory at the top of your Git repository, and these scripts must be committed as executable files.
2. The script runs as an unprivileged user with minimal permissions. It will be able to write to your application's working directory and run any software installed by the buildpack (e.g., `bundle exec rake db:migrate`) but not much else.
3. Overall execution times for builds are limited to a maximum of 30 minutes.

If either the pre- or post-build hook fails, the overall build will be marked as failed and your application will not be redeployed. However, any operations that were performed by your hook scripts will *not* be rolled back, so please exercise caution if you are performing database modifications during builds.

Build hook failures should be indicated in the usual non-zero exit code manner. If you are running a shell script as your hook you should strongly consider using `#!/bin/sh -e` or `set -e`.

Since this feature depends on our enhanced build process, it has only been rolled out across on our Amazon AWS `pod02` pod.

## CLI Updates

During our upgrade window we also rolled out a new version of the Catalyze PaaS CLI. The full list of changes is available at the [CLI repo](https://github.com/catalyzeio/cli/releases/tag/2.1.5). A few highlights:

- The status command now shows the most recent deploys for services, deployed workers, and the latest build for code services.
- Environment variables are now shown in sorted order.
- Backups are now triggered before an import is performed.

If you're already using the Go CLI you should have already received the update by now. If not, feel free to grab a copy from the [CLI releases page]( https://github.com/catalyzeio/cli/releases).

Thanks for taking the time to read this, and as always we're looking forward to hearing your feedback and suggestions.
