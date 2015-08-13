---
title: How to design a HIPAA compliant healthcare API, part 2
date: 2014-07-09
author: mark
author_full: Mark Olschesky
author_alt:
tags: HIPAA, design, custom classes, data, API
---

In [part 1](/blog/how-to-design-a-hipaa-compliant-healthcare-api) we discussed why we structured our backend as its built. Now in part two we'll discuss how to get started with building out your apps.

##Step 1: Develop your application's data models##
Now that you know a bit more about the data structures that comprise standard Catalyze data models, decide which models you will need to use. Not sure where to start? Let me ask you some questions to help you hone in on what you need.

####Who are your users?####

While Catalyze only has one "User" model, it should be used as the base model for organization-side staff (Doctors, nurses, claims analyst) or for patients and members. If you were thinking about using Catalyze in an Object-oriented hierarchy, Users could be used synonymously with "Person". Since Catalyze has built particularly auditing and logging around Users, you should use Users for anyone who needs to log into application that needs data access monitored and logged.

####Who belongs to what data?####

After you've figured out how you are going to use the Users model, now start connected related data models in that your application uses.

- Providers: Credentialed users (doctors, nurses, etc.) will have Provider records and will belong to institutions.

- Patients/Members: Patients have Vitals, Medications, and Results.

- Encounters: This is where Patients/Members and Providers intersect. During an encounter, a patient is seen by a provider. Anytime that there is any interaction between a patient and a provider, you should probably document this in an Encounter. This is true even if the patient didn't present in person, e.g. a phone call or some other data entry which relates the two entities together.

You can define other relationships between Patients/Members and Providers using the "extras" fields in both records.


##Step 2: Accept that custom models will be required

While we've built plenty of standard data models to help our customers out, it should be expected that custom classes will be required to store the rest of documentation where standard data models just don't fit. Here are some examples:

- You can use custom classes to create timeslots to schedule times that providers can see patients for a telehealth app.

- Custom classes can be used to store streams of data that relate to medications/results/encounters like an inbox for a user.

- You may use custom classes to store an exam, visit notes, follow/up information or any other data which occurs during a visit that doesn't fit cleanly into any other data model.


The great thing about custom classes is that they are always extensible into the future. Let's use an encounter visit note as an example. You could support an encounter visit note with the follwing data structure:

```
//createdOn: ISO-8601 timestamp when the note was created

//updatedOn: ISO-8601 timestamp of when the note
was last updated

//author: The author of the note. Has a relation to a
user record ID.

//patient: The patient the note is written about. Has a
relation to a user record ID.

//encounter: The encounter ID this note was written on

//type: Type of note, e.g. Progress Note, Discharge Note,
etc.

//content: The content of the note in plain text

{
  "name": "EncounterNote",
  "schema":{
    "createdOn":"string",
    "updatedOn":"string",
    "author": "string",
    "patient":"string",
    "encounter":"string",
    "type":"string",
    "content":"string"
  },
  "phi": true
}
```

If you ever wanted to add a Rich Text note into the data structure in the future, you simply need to post a PUT with a new field:

```
PUT /classes/EncounterNote

{"contentRichText":"string"}

```

##Step 3: Design your data with best practices and use cases in mind##

Overall, the best piece of advice that I can give you getting started is to not create two data models where one will suffice. In healthcare, it's not uncommon to have an app that operates in various contexts with variations on use cases.  Your ED docs may want something different than Family Medicine doctors in an office, who may want something different than an attending on the Hospital floor. Just because you have three different care settings doesn't mean that you should have three different data models for each care setting for a similar object. Instead, create a custom class with a type or location modifier that allows you to differentiate functionality and usage upon querying the API for that data type. It's much harder to merge data back together in the future than it is to separate it out if you decide that that is prudent at a later date.