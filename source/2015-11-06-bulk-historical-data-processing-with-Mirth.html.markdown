---
title: Bulk historical data processing with Mirth
date: 2015-11-06
author: rick
author_full: Rick Wattras
author_alt:
tags: mirth, hl7, historical data
---

A common workflow for many of our customers involves analyzing large amounts of patient information, which sometimes requires retrieving a trove of backlogged historical data from the EMR. In this post I will go over how we configure Mirth Connect to handle getting all of that data out of the EMR and into our customers' systems efficiently, reliably, and quickly.

###Mirth Connect

Here at Catalyze we manage HL7 integrations with the open-source interface engine software [Mirth](https://www.mirth.com/). Though we've built all manner of different integrations with it, we're always coming across useful features that help us take on tasks like this one.

##Source Message Queueing

Let's say a healthcare organization wants to upload 700,000 HL7 messages containing historical data to one of our customer's systems. The messages will be sent across the existing production interface used for day-to-day HL7 message traffic, which currently only sees ~5,000 messages a day. Can Mirth handle such a large increase in message load? If you're clever and have top-notch reliable infrastructure, then the answer is yes!

Part of the trick is to get the messages out of the healthcare organization's queue quickly and queue them on our side instead. Mirth helps us do this with the following channel Source Settings:

![mirth_source_settings](/assets/img/posts/mirth_source_settings.png)

* Source Queue --> _ON (Respond before processing)_
	* This allows messages to begin queueing in Mirth if they're being sent faster than it can process them. It also sends an ACK immediately upon message receipt rather than waiting until after the message has been processed (which is what happens in the default OFF setting).
* Response --> _Auto-generate (Before processing)_
	* This setting is related to the previous one and really just designates what you want the response (in this case, the ACK) to be. Since all we need is for Mirth to immediately send an ACK, we just need it to auto-generate one for us. 

With those settings in place and the channel re-deployed, Mirth can receive messages as fast as the organization can send them and will utilize the local queue if necessary. Then it can just continue to process the messages at its usual speed (see the next section for ways to optimize that part as well). Note that having message queueing enabled all the time would not be the best choice for a day-to-day production HL7 feed. Those typically require data to flow in real-time and queueing would allow for delays between the time the message is sent from the EMR and the time the vendor receives the data. If the message processing workflow is taking too long and the queue isn't shrinking fast enough, try to find where the bottlenecks are and alleviate those individually. See the Throughput and Latency section below for more details on identifying bottlenecks.

You may be wondering whether queueing messages incurred any performance hits. Even as we watched the queue grow at an astonishing rate, we did not see any significant growth in memory usage or disk consumption. Mirth chewed right through everything without a hiccup!

##Multi-threaded Message Sending

What about situations where message sending order doesn't matter? For example, when the incoming historical data is just random instead of being organized by patient or encounter. In those cases, you can take advantage of Mirth's multi-threading functionality to asynchronously process multiple messages and increase throughput. Instead of queueing on the source like above, this time we'll be queueing on the destination so the settings we need will be in the Destination Settings:

![mirth_dest_settings](/assets/img/posts/mirth_dest_settings.png)

* Queue Messages --> _Always_
	* This enables message queueing on the destination in cases where sending the data takes longer than transforming the data. Unlike the source queue where incoming messages are queued prior to processing, the destination queue is for outgoing messages prior to sending. 
* Advanced Queue Settings
	* There're a lot of options in here, but the main one that controls the multi-threading throughput is the _Queue Threads_ setting. That's where we tell the Mirth destination queue how many messages to simultaneously send so any value greater than 1 allows for asynchronous sending. Determining what that number should be is up to you; start small with something <= 5 and make sure you're not seeing any impact on performance. Play around with it and see what works best in your environment while meeting your desired throughput!
	* The other settings here are useful as well and we encourage you to read up on them. Enabling Queue Rotating will stop messages from holding up the queue if they fail, and using a Thread Assignment Variable can help if there are _some_ messages that require being sent in a certain order.

Similar to message queueing, enabling these settings for an everyday HL7 feed are not the best idea as messages are typically sent out from the EMR in a certain order and should be processed/uploaded in that order as well.

##Throughput and Latency

Regardless of whether you're using the source queue or asynchronously sending messages, the speed at which Mirth actually processes each message should be fine-tuned. Additionally, both the organization and vendor should make sure that neither sending or receiving the data is causing bottlenecks in the process. For bulk message loads like with historical data this is extra important.

A typical HL7-JSON transform only takes about 30ms, but steps like authenticating with a vendor's API or waiting for an ACK from an endpoint can each take anywhere from 500ms to a few seconds and compound the total processing time. Here are some throughput numbers to help visualize what optimizing the process could do:

* 1s to send 1 message = 86,400 messages a day
* 500ms to send 1 message = 172,800 messages a day

Shaving time off of each piece of the workflow can go a long way. Some suggestions for areas we've optimized in the past:

* Authentication = adding functionality to cache tokens locally and reuse them until they expire is much more efficient than requesting a token for every message.
* Asynchronous destinations = if you have multiple destinations that don't depend on each other (i.e., aren't passing values from one to the next), uncheck the "Wait for previous destination" option for each destination and Mirth will automatically process them simultaneously.
 
We learned a lot about Mirth in playing around with these settings and hope this is helpful to others as we all venture further down the Mirth rabbit hole.