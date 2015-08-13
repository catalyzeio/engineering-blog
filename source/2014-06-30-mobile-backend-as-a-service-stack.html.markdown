---
title: Mobile Backend as a Service Stack
date: 2014-06-30
author: ben
author_full: Ben Uphoff, PhD
author_alt:
tags: HIPAA, API, backend, BaaS, REST
---

Welcome to our engineering blog. We intend for this section to cover in-depth technical content that is of interest to developers and ops folks. For a first post we are covering our Mobile Backend as a Service's stack. Future posts will drill down into the specifics of some of the more interesting pieces.

## REST API

Our REST API is written in Java using the [Dropwizard](https://dropwizard.github.io/dropwizard/) framework. Dropwizard bundles - among other things - strong [gradle](http://www.gradle.org/) support, [Jersey](https://jersey.java.net/), [Jackson](http://jackson.codehaus.org/) for JSON processing and a bunch of handy features like integrated metrics and YML configuration files.

Currently our API is divided into two parts: the core, public API and a private API for managing authentication and authorization (AuthN and AuthZ). We have also built out standalone endpoints for add-on functionality like UMLS lookups and messaging.

## Data Stores

We have several data stores in the mix to power the API. We have MySQL ([Percona](http://www.percona.com/software/percona-server) specifically), [Riak](http://basho.com/riak/) and [Redis](http://redis.io/) in various places. MySQL and Riak primarily store application and user data. Redis is used as a cache in a few places. We also have Graphite for storing and querying API metrics. Our internal logging infrastructure makes use of [LogStash](http://logstash.net/), [ElasticSearch](http://www.elasticsearch.org/) and [Kibana](http://www.elasticsearch.org/overview/kibana/).

## Testing

We have two main test capabilities: traditional unit tests via [TestNG](http://testng.org/doc/index.html) and end-to-end tests written in python. The end-to-end tests are an interesting component and provide us with a lot of guards against introducing regressions during development cycles and deployments.

To make the end-to-end tests easy to run, we have built out a development environment that makes use of Vagrant and Docker. Essentially we expose MySQL, Riak and Redis via Docker containers with custom Dropwizard YML configurations for this setup. This environment can be quickly brought up on a development machine in a few minutes with just a couple of simple commands.

## CI/CD

We use [Jenkins](http://jenkins-ci.org/) and [Artifactory](http://www.jfrog.com/home/v_artifactory_opensource_overview) as our primary CI/CD tools. All commits to mainline branches trigger a build which will run through the test suite. Successful builds from release branches are packaged and shipped to Artifactory to be deployed.