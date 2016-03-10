---
title: Designing Stratum
date: 2016-03-09
author: ryan
author_full: Ryan Rich
author_alt:
tags: UI, product, product development, product design
---
### Introduction to Stratum

On February 25th 2016 Catalyze officially launched [Stratum](https://catalyze.io/stratum), our Platform as a Service offering completely rebuilt from the ground up (more on that [here](https://engineering.catalyze.io/stratum-2.0.0-launch.html)). We've spent the last 8 months redesigning the user interface, rebuilding the CLI, and drastically improving our backend performance. This post is dedicated to outlining the changes we made to the dashboard, why we made those changes, and to illustrate some of the process we used along the way.

![Stratum Product](/assets/img/posts/designing-stratum/catalyze_stratum_product.png)

### Major Changes

#### Managing SLL Certificates

One of the larger benefits of Stratum over our former PaaS dashboard is the abstraction of features away from the UI and into the CLI. In the previous dashboard we would continually see users struggling to add SSL certificates to their environments. We first attempted to fix this issues by implementing better inline documentation (a feature we're planning on adding back into Stratum at some point) and improving validation. This did alleviate the issue for some users. However we still saw a steady flow of SLL related support requests.

For the design team this was rather frustrating. We wanted to help these users, but without a major change to the way the backend worked we didn't quite know how to solve the issue. What we did know was that the UI was not the place for managing SSL certificates. Fortunately with the planned Stratum release we were able to work SSL management into the CLI and in the short two week period that the product has been launched we've seen greater user success.

![Stratum CLI SSL Certs](/assets/img/posts/designing-stratum/catalyze_stratum_cli_ssl.png)

#### Managing SSH Keys

Handling SSH keys within the old dashboard was another point of contention for users. Our initial decision to place SSH keys inside of the UI instead of the CLI was mostly based around other tools that the design team had used in the past (notably Github). With the new Stratum release we really wanted to stick to a certain philosophy:

`CLI = actions` and `UI = viewing`

So with that in mind we moved SSH keys to the CLI and simply placed a note inside the dashboard notifying users of the change.

#### Managing Environment Variables

Environment variable management was another UI oddity that felt like it belonged in the CLI (you can start to see a pattern here). Across the board all tangentially related tools pushed users to the CLI over the UI for configuring environment variables. As users of Stratum ourselves this new method felt like a much stronger experience, and certainly one that aligned with our new philosophy.

#### Viewing Services

Environments are built of services. These services can be anything from your application framework to your particular database. With the new Stratum dashboard users can view their environment variables, services information, running jobs, and life time metrics all from within a single view.

![Stratum Stratum Metrics](/assets/img/posts/designing-stratum/catalyze_stratum_metrics.png)

#### Environment Configuration

Perhaps the largest change from the previous dashboard is environment configuration. Users no longer need to tediously input information about the type of environment they want to provision. All configuration is now managed completely by Catalyze. New customers will work with Catalyze sales on finalizing their environment configurations. That contract is then passed off to engineering where a new environment and organization is automatically created for you. To make changes to existing environments users can quickly file a support ticket, or reach out to sales staff.

#### Organization Management

Current users of Stratum might have noticed that organization management has completely changed. The big improvement here was giving users the ability to easily add other users to their organization. This was a tremendous support burden in the past and we're excited to finally give users this new level of autonomy. In the following image you can see the new layout depicting the current list of users, their role, and on the right hand side a list of currently pending invites.

![Stratum Organization View](/assets/img/posts/designing-stratum/catalyze_orgs.png)

#### Personal Account Management

As part of the Stratum release we pulled account management out of the dashboard for one main reason, ease of supporting current and new products. We're also working towards single sign on and multi-factor authentication, both of which will tie directly into account management. Users can now change their email and password as well as see which organizations they belong to from within the [Catalyze Account Manager](https://account.catalyze.io).

![Stratum Organization View](/assets/img/posts/designing-stratum/catalyze_account.png)

### The Design Process

![Stratum Organization View](/assets/img/posts/designing-stratum/catalyze_sketches.png)
