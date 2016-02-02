---
title: How We Onboard Engineers At Catalyze
date: 2016-01-26
author: nathan
author_full: Nathan Sweet
tags: Onboarding,Engineering,Support
---

I've been working at Catalyze for a little over a month now, and I cannot believe what I have learned and accomplished in such a short amount of time. I have to give credit to how we onboard engineers, because it is quite ingenious.

When I first started interviewing with Catalyze I was told that the way engineers are onboarded is that they answer support tickets for a few weeks to learn the system. I didn't have anything against this, but I was skeptical that it could be better than digging through source code and sitting one-on-one with people to have them explain the architecture to me. I figured it was a kind of obligatory hazing ritual, and thought nothing of it.

Man, was I wrong! Answering support tickets turns out to be one of the most effective techniques for onboarding an engineer that I have encountered. Not only is it an effective onboarding mechanism, it is an experience that I am excited to continue (engineers rotate through support, which is part of what makes our support so exceptional).

Answering support tickets wasn't nearly as coma-inducing as I thought it would be. We are a cloud provider, so a good chunk of the support tickets we receive involve helping people with their deployments. Most of our customers are intelligent and creative individuals and helping them solve their problems actually turns out to be quite interesting. For example, we have a uniform logging system that we provide to all of our customers. We do this as part of helping them maintain HIPAA compliance. One of our customers was running a Ruby-On-Rails application and the Ruby library he was using to integrate with our logging system wasn't working, so I had to teach myself a little Ruby (having never programmed with it before) and dive into the library's source code to find the problem for him. 

I don't want to paint a false picture, answering support tickets isn't always the most interesting work. There are monotonous tasks, problem users, and instances when our own system isn't running as it should be. However, this is where the real beauty of answering support tickets shines. All of these pain points are incredibly clarifying experiences. Monotonous tasks are clear signals as to which tasks should be automated. Problem users often point to holes in our documentation, and what information might be missing or how something might not be explained the very well. Instances where our own system isn't running as expected is obviously a great way to find bugs, but it also helps us to see if a piece of architecture has too many moving parts or could be simplified.

Answering support tickets helped me to understand our architecture much better than I though it would. As I was answering support tickets I would have to read our documentation, sift through our source code, and talk to the other engineers to understand how to solve a customer's problem. In the process of answering support tickets I got to know the most common code paths of our architecture very well in a very short amount of time.

So often when an engineer gets onboarded at an organization they get a brain dump of the architecture, but with very little context. It takes them a long time to figure out what pieces of architecture they should prioritize learning, or are most integral to understanding the overall system. Working with customers made this process much clearer to me, because I got immediate insight into how exactly our product is getting used.

Finally, answering support tickets made it abundantly clear to me what we needed to build next. It's incredible to me how highly aligned the engineers at Catalyze are behind the next steps we are taking as a company, and it's not too difficult to figure out why. We all spend time with the customers so we actually know what their problems are and what they need from us. This makes working support worth its weight in gold, in my opinion. When your engineers are aligned organizationally and they actually know what your customers want, it's a lot more likely that they will build what the customer actually needs. Engineers that are disconnected from their customer base are a lot more likely to build  a multi-directional monstrosity that automates things no one needs automated, leaves out key documentation, and doesn't automate the things people actually needed automated.

Answering support tickets is something I'm looking forward to doing again and again. It's a nice break from having my head in the clouds, and lets me actually dealing with my customers' real problems. It is an incredbily clarifying experience and helps clear out the mental clutter and make it clear to me what I actually need to be working on.

#Notes:

1. ruby-on-rails run on sentance in fourth graph
2. Explore language around engineers that don't build the right thing. Consider cutting?
3. Language comparing and contrasting "head in clouds" vs "real needs". Better language.
4. Much better language for very last sentance.
