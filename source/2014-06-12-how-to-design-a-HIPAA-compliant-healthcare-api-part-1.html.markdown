---
title: How to design a HIPAA Compliant Healthcare API - Part 1
date: 2014-06-12
author: mohan
author_full: Mohan Balachandran
author_alt:
tags: HIPAA, API, mhealth, healthcare data models, platform
---

When we set out to build Catalyze, the one thing that kept cropping up as we talked to potential users, a lot of whom were coming from outside healthcare, was a lack of knowledge about all the complexities of healthcare data and standards. I wrote about [this](/blog/understanding-healthcare-vocabularies-code-sets/) a while back trying to summarize all the key standards and code sets that are most relevant for a healthcare developer. What I had also mentioned in that post was that v2 of the Catalyze HIPAA compliant API, what we sometimes refer to as [backend as a service](/baas), would be released shortly and include associated healthcare data models. We went live with v2 of the API a while back and have successfully tested it with lots of customers, from independent developers building mobile apps all the way up to multi-billion dollar enterprises building multiple apps as part of large scale innovation initiatives. In this post, which is long overdue, I outline the process that we went through in coming up with the data models and the routes for those healthcare specific APIs.

##Base the data models on messaging standards

We researched healthcare data models extensively. Starting with a search on Google you get a whole bunch of proprietary content which isn't useful at all. After wasting a lot of time on those links, the realization that I came to was that we weren't trying to create a full fledged data model with a lot of relationships and dependencies. Instead, the goal from our end was to ensure that developers would have a great starting point which would / should cover most of their compliant data storage and use case needs.

Starting there, we looked across all the major existing data exchange standards and used those as the super set of data elements required. The rationale for deciding to go with messaging standards, rather than interoperability standards (yes, there is a pretty substantial difference between the two), was that any mobile app built on our compliant API would be either a consumer or generator of messages and not much more - apps will not replace EHRs.

The core messaging standards we picked as the basis for our healthcare API were 1) Consolidated Clinical Document Architecture (CCDA) / [Blue Button](http://bluebuttonplus.org/) (these are pretty closely tied together) and 2) [HL7](http://www.hl7.org). The Blue Button site is especially illuminating as it gives an example of what a typical CCDA document would look like. Some more digging led to this [Github repo](https://github.com/chb/sample_ccdas) with more examples (and growing). We signed up to HL7 as well as it doesn't allow you to share content with any of your team members (no startup discount?!) without paying for a membership.

CCDA is great - it's well documented, has great examples, and even has libraries to play around with like [BlueButton.js](https://github.com/blue-button/bluebutton.js/) and CCDA [parsers](https://github.com/chintanop/ccda-rest-api). However, any robust solution needs to also support a lot of the data elements that HL7 needs as it is *the* pre-eminent exchange standard, and it will not be going away any time soon. The challenge with HL7 is that there are a lot of versions (for more about HL7 and a quick primer on it - this [link](/learn/hl7/) might be useful). We settled on a combination of HL7 v2.7 and v3.0 - with a primary focus on v2.7.

##Organize data models

All apps that we expect to use our backend and compliant APIs are going to be consumer or provider oriented. Because of this, we opted to approach the data models in a patient-centric model.

There is "master data" associated with a patient so we need to have:

**Entities**: These would be the core entities involved in patient care - namely the patient / user, provider and institutions. Institutions being the facility / clinic or the site at which care is provided.

Next - if you step back and think about how a physician approach an encounter, you'll realize that patients come to providers with a problem / complaint. Physicians make observations on the patients condition (either through Q&A or through objective test results) and come up with a diagnosis; in a physician's head she/he is trained to develop what's called a differential diagnosis for a patient, or list of possible diagnoses for the patient, starting very broad and honing in on what is most likely, while also not missing any diagnosis that is unlikely but can't be missed because it can cause something horrible. On the basis of the likely diagnosis, and to potentially confirm the diagnosis, the physician decides upon the intervention (prescription, procedure etc.) and then tracks the progress of the patient based various metrics (such as lab results, vitals etc.); the last part, the tracking part, is particularly problematic in our healthcare system but something that is getting better with new technologies and collaborative care models.

This flow, which is what we used as we modeled out healthcare APIs, does have drawbacks in that there will be overlap among models i.e. it is not quite sequential if you want to minimize model duplication. For example, purely based on APIs, what's the difference between a patient reported complaint and a physician diagnosis - except for specificity and therefore an associated code. And a set of values from a lab result and vitals (weight, height etc.) are all metrics, after all, and the origin of such needs to be considered. Given that, we chose to organize the rest of the models into the following groups.

- **Problems**: Since the only difference between a patient reported *complaint* and a physician reported *diagnosis* is the specificity and the associated code, we chose to combine these into a single model. We differentiate between the two using a category parameter, which is like a flag.

- **Observations**: These are patient reported or physician collected data that could help in figuring out the diagnosis or the interventions to be performed. The observations group includes:
    - Allergies
    - Social history
    - Family history
    - Notes
    - Impairments
    - Advance directives
    - Discharge instructions

- **Interventions**: Based upon all the above and the metrics associated with interventions (an intervention could be a procedure such as ordering a lab test which has an associated set of metrics), physicians, and patients (if populating data as self-reported) could pick one or a combination of:
    - Medications: We also call out discharge medications as a category. There are additional nuances here in terms of OTC (over the counter) vs. prescription drugs and much more. We invite you to look through our [documentation](http://docs.catalyze.io/) to get a better understanding of our thought process here.
    - Procedures: Note that a procedure could be ordering a lab test since the Common Procedural Terminology (CPT) doesn't distinguish between a lab test ordered on a patient and a surgery performed on a patient. They are just different procedures performed.
    - Immunizations: Although a type of procedure, it is called out in our models as it has other public health and reporting implications.
    - Encounters: Encounters are when physicians interact with patients. Although, this is not quite an intervention, this model is required as it has billing implications as well as the fact that it establishes a point in time when the interventions are decided upon.
    - Care plans: These are time phased interventions which might include a combination of all of the above. This model is still under development.

- **Metrics** - These are (usually) objective measurements about the patient and would include things like:
    - Results: Lab results can be complicated and based on various examples, we've simplified these to object models that are similar in structure and therefore, easy to query and use.
    - Vitals: These are metrics such as weight, height etc.
    - Activity: This are all the metrics typically associated with the quantified self; think [Apple HealthKit](/blog/what-does-healthkit-mean-for-mobile-app-developers/). These models are still in development. It is our intention to leverage / partner with aggregators of this kind of data such as [Validic](http://www.validic.com) rather than develop another data model for you to learn.

- **Permissions** - Healthcare is all about permissions. Who has access to the data? Do they have the rights to it etc? With HIPAA in particular, are they authorized to access the data? A full permissions model needs to be in place. We've added a full permissions model to our compliant APIs. Look for a more detailed write up on this and associated design considerations shortly.

- **Messaging** - We've written about the importance of messaging in patient engagement and even more specifically about the value of SMS in enabling this. (need link to travis's chapter etc.). We have a HIPAA compliant SMS solution available for use as well.

- **File management** - Documents and images are part and parcel of healthcare. We've created a HIPAA compliant file storage API as a part of our backend, with flexible permissions and powerful search.

This should give you an idea of the thought process that went into the overall structure and architecture of the data models that are needed to build out a healthcare specific API. The next blog post will delve deeper into the data models and the design of our compliant API.

If you'd like to start playing around with what we already have, signup for a BaaS account [here](https://devportal.catalyze.io/) today, check out our documentation [here](https://docs.catalyze.io/), check out the guide we're writing on how to use the APIs [here](https://docs.catalyze.io/guides/api/latest/) (this is a work in progress) or signup for our newsletter on the right to stay informed of updates.