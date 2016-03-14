---
title: Designing Stratum
date: 2016-03-14
author: ryan
author_full: Ryan Rich
author_alt:
tags: UI, product, product development, product design
---
### Introduction to Stratum

On February 25th 2016 Catalyze officially launched [Stratum](https://catalyze.io/stratum), our Platform as a Service offering, completely rebuilt from the ground up (more on that [here](https://engineering.catalyze.io/stratum-2.0.0-launch.html)). We've spent the last 8 months redesigning the dashboard user interface, rebuilding the CLI, and drastically improving our backend performance. This post is dedicated to outlining the changes made to the dashboard, why we made those changes, and illustrating the process we used along the way.

![Stratum Product](/assets/img/posts/designing-stratum/catalyze_stratum_product.png)

### Major Changes

#### Managing SSL Certificates

One of the larger benefits of Stratum over our former PaaS dashboard is the abstraction of features away from the web UI and into the CLI. In the previous dashboard, we would continually see users struggling to add SSL certificates to their environments. We first attempted to fix this issue by implementing better inline documentation (a feature we're planning on adding back into Stratum at some point) and improving validation. This did alleviate the issue for some users; however, there was still a steady flow of SSL related support requests.

This was frustrating. We wanted to help these users, but without a major change to the way the backend worked we didn't quite know how to solve the issue. What we did know was that the dashboard UI was not the place for managing SSL certificates. Fortunately with the planned Stratum release we were able to work SSL management into the CLI, and in the short two-week period that the product has been launched we've seen greater user success.

![Stratum CLI SSL Certs](/assets/img/posts/designing-stratum/catalyze_stratum_cli_ssl.png)

#### Managing SSH Keys

Handling SSH keys within the old dashboard was another point of frustration for users. Our initial decision to place SSH keys inside of the dashboard instead of the CLI was mostly based around other tools that the design team had used in the past (notably Github). With the new Stratum release we really wanted to stick to a certain philosophy:

`CLI = actions` and `Web UI = viewing`

So with that in mind we moved SSH keys to the CLI and simply placed a note inside the dashboard notifying users of the change.

#### Managing Environment Variables

Environment variable management was another dashboard oddity that we felt belonged in the CLI (you can start to see a pattern here). Across the board, all tangentially related tools pushed users to the CLI over the web UI for configuring environment variables. As users of Stratum ourselves, this new method felt like a much stronger experience, and certainly one that aligned with our new philosophy.

#### Viewing Services

Environments are comprised of services. These services can be anything from your application code to your particular database. With the new Stratum dashboard, users can view their environment variables, service information, running jobs, and lifetime metrics all from within a single view.

![Stratum Stratum Metrics](/assets/img/posts/designing-stratum/catalyze_stratum_metrics.png)

#### Organization Management

Current users of Stratum might have noticed that organization management has completely changed. The big improvement here was giving users the ability to easily add other users to their entire organization, instead to only a single environment. This was a tremendous support burden in the past, and we're excited to finally give users this new level of autonomy. In the following image you can see the new layout depicting the current list of users, their role, and on the right hand side a list of currently pending invites.

![Stratum Organization View](/assets/img/posts/designing-stratum/catalyze_orgs.png)

#### Personal Account Management

As part of the Stratum release we pulled account management out of the dashboard for one main reason, ease of supporting current and new products. We're also working towards single sign on and multi-factor authentication, both of which will tie directly into account management. Users can now change their email and password as well as see which organizations they belong to from within the [Catalyze Account Manager](https://account.catalyze.io).

![Stratum Organization View](/assets/img/posts/designing-stratum/catalyze_account.png)

### The Design Process

With Stratum being such a large release we had the opportunity to really change whatever we felt necessary to the user interface. In the past our experiences mostly relied on research. We found that user testing typically resulted in confirmation of our thoughts rather than new revelations. Because of this we wanted to get as far along in the design process as we could before user testing. That way we could take something substantial to the user and get their thoughts. Once we had that feedback we could then implement any changes before launch.

Below are early examples of sketches, wireframes, and mockups for Stratum.

![Stratum Organization View](/assets/img/posts/designing-stratum/catalyze_sketches.png)

#### Branding

In most cases a redesign of a product doesn't usually result in any rebranding efforts. However, since Stratum was so large and included a new name we wanted to align that with our other product, Redpoint. The two core components of the rebrand were color concepts and a new logo.

Previous to Stratum, PaaS had utilized a desaturated light blue. While this worked it didn't quite align with the new product and our new messaging. Redpoint was already utilizing a new red color that we really liked so we wanted to create something complementary. We eventually settled on the following palette.

![Colors Overview](/assets/img/posts/designing-stratum/catalyze_colors.png)

In terms of the new logo we needed something that could work as a small icon, a stand alone logo, and a logo with set type. We also wanted to continue playing off of the rock climbing/mountaineering theme we developed with Redpoint. The ideas below show the genesis of the Stratum icon.

![Catalyze Stratum Logo Concepts](/assets/img/posts/designing-stratum/catalyze_logo_concepts.png)

We then developed that icon into a logo with set type and added it to the family. Below you can see our Catalyze, Redpoint and Stratum logos illustrating the new brand.

![New Logos](/assets/img/posts/designing-stratum/catalyze_logos.png)

### Wrapping up

We learned a lot as a team during this release and we're excited to continue perfecting Stratum. Stay tuned to the engineering blog to hear more, and as always, don't hesitate to reach out with any questions: [hello@catalyze.io](mailto:hello@catalyze.io).
