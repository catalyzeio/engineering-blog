---
title: Stratum Lifetime Metrics
date: 2016-03-21
author: kgrieger
author_full: Kyle Grieger
author_alt: Co-Authors - Thomas Malcolm
tags: metrics, docker, PaaS, new features, Stratum, open source
---

##Docker Container Metrics. So Easy an Intern Can Do it?
Our recently released product, Stratum, is built on top of [Docker](https://www.docker.com/). Each job is essentially a Docker container that is performing a task of sorts. As an infrastructure company, it is essential to monitor these containers in order to determine if a user’s environment is stable or possibly experiencing complications. It is also important for users to have access to their environment’s performance metrics in order for them to get the most out of the Stratum product.  This raises the question for the engineers at Catalyze, what is the best way to accurately and efficiently monitor Docker container performance? So the Catalyze interns set out for the answer, prototyping several Docker monitoring configurations including:

* [Collectd](https://collectd.org/) and [Graphite](http://graphite.readthedocs.org/en/latest/dashboard.html),
* [Docker stats](https://docs.docker.com/engine/reference/commandline/stats/) and [Splunk](http://www.splunk.com/),
* [Cadvisor](https://github.com/google/cadvisor), [Influxdb](https://docs.influxdata.com/influxdb/v0.9/), [Grafana](http://grafana.org/),

and several more.

Initially looking to Cadvisor, which does most of the heavy lifting in terms of collecting and aggregating metrics by container, we ran into some performance issues. Newer versions of the [docker remote api](https://docs.docker.com/engine/reference/api/docker_remote_api/) expose container performance metrics, eliminating the need for Cadvisor, but older versions of the docker remote api do not. 

##Metrics for days
The [first iteration](https://engineering.catalyze.io/Import-Export-Console-Metrics-Announcement.html) of environment metrics allowed users to view their environment’s performance data for 24 hours. By choosing redis as a backend, the storage size utilized for storing performance metrics was limited. Initially, this worked out well until Catalyze customers wanted to know about the long-term growth of their environments. With that in mind, the switch was made to [Influxdb](https://influxdata.com/). Influxdb allows for the collection of Docker container performance metrics over the lifetime of environments while simultaneously minimizing storage space (an estimated 10 MB per environment per year). With constant improvements being made to the the Influxdb [storage engine](https://docs.influxdata.com/influxdb/v0.9/concepts/storage_engine/), an even greater reduction in space used to store environment metrics can be expected in the future.

##Under the Hood
There are many examples that exist for collecting Docker container metrics. However, something was needed that would permit the freedom to add metadata to container metrics in order to segment data for each customer. Each docker host runs a sender container, essentially a cron job that runs every minute, and collects metrics from either Cadvisor or Docker stats, which is dependent on the version of Docker that is running. The sender will then hand this data off to the collector, attaching metadata to the container metrics and storing everything to Influxdb. The collector is a [Falcon](http://falconframework.org/) app that also allows metrics to be queried by our various api’s. 
![enter image description here](https://lh3.googleusercontent.com/61KDs6Ynnw4uu6xZfEPO3UajBeZuElBs5_wtBsEPbLC_SkljT9TFhSlqbVxgvCoIBF4=s0 "Docker Metrics Diagram.jpg")

An open source version of our Docker container metrics collection software is available on github.

##Seeing is Believing
There are several front end frameworks that work well with Influxdb to graph and help visualize container performance metrics, such as Granfana, Influga, and Facette. However, in order to integrate visualizations into the dashboard, [Nvd3](http://nvd3.org/) is the clear choice. The switch to the Nvd3 charting library is a significant improvement over our previous charting library. Namely, we are now able to chart and aggregate more efficiently by timestamp which provides greater granularity and detail into the graphs. Some other improvements include interactive tooltips and the ability to toggle the visibility of data. The increasing variety of nvd3 visualizations will allow us to create even more awesome charts, graphs and interactive graphics to display metrics in the future.

![enter image description here](https://lh3.googleusercontent.com/-_HQS3uI0hmw/Vu_6LO6SE0I/AAAAAAAAAA8/bd0_w_mon90Bp7ZGuNy6LpKCoy404nvvA/s0/screencapture-stratum-sandbox-catalyzeapps-com-service-1457047590783+copy.png "screencapture-stratum-sandbox-catalyzeapps-com-service-1457047590783 copy.png")

##So. Much. Data. What does it mean?
Environment performance metrics are not particularly useful unless meaning can be derived from them. This is why we have developed various scripts and tools to analyze, aggregate, and organize container metrics data. Some of these scripts and tools have been built into the Stratum CLI which now allows users to export metrics data to csv, json or [spark](http://spark.apache.org/) via and perform their own analysis.  This new Stratum lifetime metrics infrastructure will also allow users to identify trends in the lifecycle of their environments and better understand the seasonal traffic of their applications.  With this information, users can make more informed adjustments to their infrastructure as they scale and optimize their apps for the best performance.  Also, this metrics data will allow Catalyze to provide superior support and an enhanced user experience for our customers in the future. 
