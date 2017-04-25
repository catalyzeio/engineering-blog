---
title: Compliant Cloud 2.4.0 Release Notes
date: 2017-04-25
author: ryan
author_full: Ryan Rich
tags: compliant cloud, release, 2.4.0
---
<div class="callout">
<p>Today we're pleased to announce the general availability of Compliant Cloud 2.4.0. We've included the details below, but before we dive in here's a quick note on product releases going forward.</p>

<p>In the past we've relied on a quarterly release schedule. While this release process can be common among software development teams, it was too restrictive for us. So we've moved to a much more timely release schedule. Now when we finish a feature we'll release it as soon as we can. If you have any questions, comments or concerns about product releases please reach out to <a href="mailto:hello@datica.com">hello@datica.com</a>.</p>
</div>

#### On to the notes!

# 2.4.0

#### Configurable Health Checks
This new feature can completely eliminate the probability of any downtime during a deployment. In short, a health check can be any number of things, but most commonly it will be a simple http route on an api that responds with a status code of “200”. We've written up a longer blog post for your perusal [here](TODO). To enable this feature customers may contact Datica support with their health checks. In the future we may allow customers to enable health checks for themselves.

#### Resolved Issues & Service Improvements
- Maintenance mode no longer shows up on service types that don't support that feature
- Improvements to garbage collection on backup rotations
- Fixed build stalling during nightly backups
- Resiliency improvements to in-place redeployments
- Added Kibana 3 logging container
- Improved targeting for `web` workers
- Added nanosecond precision to Elastic Search

# Customer Support:
- In order to tend to your support issue in a timely manner please submit your ticket through the Compliant Cloud dashboard by clicking on the “Contact Support” button located in the footer of the Environment UI. This provides valuable meta data to the support staff which allow them to triage the issue much quicker.
- **Our Support Policies:** Support is provided in English from our offices in Madison, WI.
- Support hours are Monday through Friday 9:00 a.m. to 5:00 p.m. Central time.
- After-hours support for Severity-1 failures is available on all working days, weekends and US public holidays

# Additional References:
For more information on Compliant Cloud and Datica’s offerings, please visit:

- Datica: [datica.com](//datica.com)
- Resources: [resources.catalyze.io](//resources.catalyze.io)
