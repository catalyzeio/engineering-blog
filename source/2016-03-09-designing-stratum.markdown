---
title: Designing Stratum
date: 2016-03-09
author: ryan
author_full: Ryan Rich
author_alt:
tags: UI, product, product development, product design
---
### Introduction to Stratum

On February 25th 2016 Catalyze officially launched [Stratum](https://catalyze.io/stratum), our Platform as a Service offering completely rebuilt from the ground up. We've spent the last 8 months redesigning the user interface, rebuilding the CLI, and drastically improving our backend performance.

![Catalyze Product](/assets/img/posts/designing-stratum/catalyze_stratum_product.png)

One of the major benefits of Stratum over our former PaaS dashboard is the abstraction of features away from the UI and into the CLI. In the previous dashboard we would continually see users struggling to complete tasks like adding SSL certificates and managing SSH keys. We first attempted to fix these issues by implementing better inline documentation and improving validation. This did alleviate the issues for some users. However we still saw a steady flow of common support tickets.

What this told us was that the UI was not the right place for SSL certificates and possibly not even for SSH keys. So we moved those features into the CLI and tested with new users.

![Catalyze CLI SSL Certs](/assets/img/posts/designing-stratum/catalyze_stratum_cli_ssl.png)

This new CLI flow felt much more natural to users and they consistently rated it as a better experience than the dashboard. With this revelation the dashboard went though somewhat of an existential crisis. If the most powerful features of the product made the most sense in the CLI then what compelling purpose could the dashboard serve?

The answer to that question can best be seen in the image below. The dashboard is a graphical view layer into your environment. With graphs, tables and data, you can _see_ important information about your environment when it's happening.

![Catalyze Stratum Metrics](/assets/img/posts/designing-stratum/catalyze_stratum_metrics.png)

The Stratum dashboard can also be used to manage organizations, users and invites. Personal account information is now managed via an auxiliary application: [account.catalyze.io](https://account.catalyze.io).

![Catalyze Organization View](/assets/img/posts/designing-stratum/catalyze_orgs.png)

We pulled account management out of the dashboard for one main reason, ease of supporting current and new products. We're also working towards single sign on and multi-factor authentication, both of which will tie directly into account management.

![Catalyze Organization View](/assets/img/posts/designing-stratum/catalyze_account.png)
