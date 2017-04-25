---
title: Health Checks
date: 2017-04-25
author: nathan
author_full: Nathan Sweet
tags: compliant cloud, health checks
---
With the Compliant Cloud 2.4 release customers will be able to add health checks to their services. The underlying Compliant Cloud architecture will be aware of these health checks, reflected in the current state of a service instance (a “Job” in Datica parlance). Customers may register their health checks with customer support and support will add them to the service. In the future we may allow customers to enable health checks for themselves.

So how do they work and what do they do?

A health check can be any number of things, but most commonly it will be a simple http route on an api that responds with a status code of “200”. When a service is first deployed with a health check the service’s jobs will not be put into network rotation until the underlying health check has succeeded, additionally old jobs will not be deleted until all of the new jobs’ health checks succeed. Once a service is deployed if a job health check ever fails it will be put into an “unhealthy” state. This will result in the job being pulled out of network rotation, except for any current connections that it might be servicing. When an “unhealthy” job passes a successful health check again it will be put back into a healthy state and back into network rotation.

Compliant Cloud health checks are a powerful tool, because they provide application level insight at the cloud architecture level. Please reach out to support to enable them for your code services and service proxies.