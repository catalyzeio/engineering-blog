---
title: Intro to Secure APIs
date: 2013-11-27
author: travis
author_full: Travis Good, MD
author_alt:
tags: API, HIPAA
---

Over the weekend I had the privilege of attending a YCombinator conference in San Francisco covering best practices for web security. A number of topics were discussed including securing APIs, incident responses and responsible disclosure, proper backup techniques, how to handle customer secrets, and when to pay for pen testing. Over the next few blog posts I’ll outline these topics in detail. We’ll start off with securing APIs.

One of the most important things to remember about security is that in order to protect your APIs, you must have the mindset of an attacker. If you know how to break into your own API you can easily secure it. It’s always been said that security is easy, but easy to get wrong.

Time and time again, once a loophole or bug is found in an API a fix comes out within hours or even minutes. Fixing a problem is almost never difficult; the challenge comes when you try to fix bugs before they exist.

APIs can be broken up into two basic types: private and public. Public APIs, sometimes referred to as open APIs, are consumer facing. Private APIs, referred to as closed APIs, are for internal company use or a small set of developers. Although many suggest there are different techniques for securing the two basic types, the same security practices should be applied to both. Differing practices mean you are either risking valuable company data, or valuable customer data; neither of which should be more prone to attack than the other.

The most important part of an API is to get behind HTTPS. Seems easy enough. This will protect you from passive sniffing by encrypting requests and making them unable to be intercepted and read. First step would be to get an SSL certificate. Some big names include Verisign or Digi-Sign or you can head over to www.startcom.org for a free one. For a standard API, SSL can be terminated at the load balancer with haproxy, nginx, apache, etc. Here at Catalyze, because our APIs HIPAA compliant, we to have end to end SSL. It cannot be terminated at the load balancer but must be carried through to the application and databases as well. This isn't trivial but it's essential to being HIPAA-compliant.

After you’ve written some code and are setup with SSL, you will likely have some sort of a User model. When a user logs into your API, you, or a third party library, should be generating some sort of unique identifier for that user. This identifier should be sent with every subsequent request to identify the requesting user. It is often enough to have this identifier timeout or change upon every log in. Others will go so far to make single use identifiers that self destruct after each use.

Besides that unique identifier, there are a few other things that should be included with every request: a nonce and a timestamp. In combination, these are included to prevent replay attacks. To start things off, the server is going to have to keep track of the last X amount of minutes worth of nonces. When a request comes into the API, the timestamp should be checked first. This can be included in a header, in the body, as a query param, or however you’d like. If the request’s timestamp is beyond X amount of minutes in the past, the request is dropped. If the timestamp check passes, the nonce is checked against the list of past X minutes worth of saved nonces. These saved nonces could be stored in a memcache to improve performance. If the nonce is not found in that list, the request is dropped. Otherwise the request is accepted and the nonce is added to the list of saved nonces.

Now that a proper request has been constructed, it would be wise to canonicalize the request to protect against man-in-the-middle (MITM) attacks. Since we have a unique identifier already from our user, we can simply use that to encrypt the request. Check out keyczr for a great cryptography library for java, python, and c++.

A more common practice for protecting against MITM attacks is enabling HTTP Strict Transport Security (HSTS). In short, HSTS tells browsers to not even make requests to a certain URL over HTTP but to upgrade to HTTPS before the request hits the server.

Now we come to the question why do we have to canonicalize requests and support HSTS? Isn’t that overkill? The answer is yes and no. For browsers, yes that is a bit unnecessary. But what about mobile apps? Mobile apps don’t use browsers to make requests. Oftentimes mobile apps use a third party library to handle all the network needs; at Catalyze we use [AFNetworking](https://github.com/AFNetworking/AFNetworking) for iOS and have integrated it into our SDK. These libraries don’t have HSTS built into them and do not support it. This is where canonicalizing requests comes into play to stop request bodies from being read even if the SSL is decrypted.

Following these tips will help prevent attacks on your APIs and make your data, as well as your customer’s data, more secure. Remember press is good, but making headlines for having your entire API reverse engineered and database stolen is not anyone’s goal. A modern tech company, in a connected world, should be first and foremost a security company. At Catalyze we've taken these steps, and more, to secure our APIs. We'll be sharing more tips on security and hope you find them useful.