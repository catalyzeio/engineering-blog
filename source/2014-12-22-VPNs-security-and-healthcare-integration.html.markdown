---
title: VPNs, Security and Healthcare Integration
date: 2014-12-22
author: mark
author_full: Mark Olschesky
author_alt:
tags: VPN,HL7 Integration
---

If you're used to a world of OAuth handshakes, Pub/Sub and HTTPS for authorization and enabling data transfer, you'll find yourself somewhat disoriented with healthcare data integration. While outdated it has worked up to this point and helped healthcare organizations keep the "bad guys" out while letting the business associates in. We'll talk about what's common and how we help our customers setup secure, redundant integration with clients.

## Let's talk about networking

(image: zdt7agj.gif)

The OSI 7 Layer Model outlines a standard format for data transfer from the wires and cables to the data a user sees in an application. When you take a look at the [HHS Data Breaches for 2014](http://www.hhs.gov/ocr/privacy/hipaa/administrative/breachnotificationrule/breachtool.html) you mostly see three types of electronic data breaches. 

1. Theft of a physical device like a hard drive or computer where data wasn't encrypted (Layer 1)
2. Data gained from phishing or inappropriate application access (Layer 7)
3. Users downloading PHI and then losing/inappropriately using said PHI (Layer 7)

Most of your traditional networking attacks—most notably attacks on SSL like the Heartbleed exploit (Mostly layer 5), SYN Flood attacks (Layer 4), Volumetric DDoS attacks (Layer 3), Packet Sniffing (Layer 3) or MAC Attacks (Layer 2)—are uncommon in healthcare [1], mostly because healthcare data flowing from devices to application services are kept behind a firewall or some other layer of security extraction. Exposing any data entry point to the public leaves the organization open to attack no matter how well protected. Firewalls prevent this. There is a tradeoff in usability, but most organizations believe it's worth it.

## HL7 in 2014 and beyond

The beginning of the HL7 2.7 guide's introduction has this statement: 

> **HL7 Version 2.7 serves as a way for inherently disparate applications and data architectures operating in a heterogeneous system environment to communicate with each other.**

That's correct. What drives most real-time data sharing within healthcare organizations was never designed to share data outside of the organization. Not to say integration currently isn't functional. But security is not designed as a first class citizen. Most data sent between hospital systems within the firewall is sent through plain-old TCP, sometimes wrapped in Minimum Lower Level Protocol (MLLP), an HL7 specific standard which ensures complete message transmission. HL7 can be sent via HTTP or HTTPS, but it's not as common as TCP connections. Part of this is due to the nature of many HL7 feeds (messages are sent per second, so it makes sense to keep a long running connection). Hospitals are also afraid data will leak if they do anything else. Data is usually kept behind VPNs and users access applications across VDIs for that reason.

## How we setup the VPN

VPN setup is a first class citizen in our architecture setup. After you engage with an organization and discuss data integration, we work with you to complete security documentation. We lean heavily on our [policies](https://policy.catalyze.io/) and [audits](https://catalyze.io/compliance) to speed up the paperwork. We're also happy to provide information to you and your potential customers through the sales process. Once we've completed the paperwork, we have a standard questionnaire for our customers that discusses our standard VPN setup and begins the process to exchange the necessary data to setup the VPN connection. Once this is done, we setup our VPN for the customer, exchange keys and secret data and our VPN connection should be up and running. As we need to connect to new IPs and new ports, we continue the process and spin these up. Usually, it takes us about an hour to make a change to your setup and to test something out. 

Each hospital handles VPNs slightly differently, so it's great to work with a team with experience setting up secure networks. With a certified CCNA and a pedigree managing large systems at Rackspace, we have the sophistication and expertise to setup a secure, redundant integration engine in days instead of weeks or months. Need help with integration? [We've got you covered from HL7 to CCDAs to FHIR.](/hl7)