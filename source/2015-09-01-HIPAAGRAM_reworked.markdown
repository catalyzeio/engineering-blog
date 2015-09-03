---
title: HIPAAGRAM - A Single Custom Class
date: 2015-09-01
author: josh
author_full: Josh Ault
author_alt:
tags: HIPAAGRAM, hipaa, whatsapp, app, iOS, api, sms, messaging, hipaagram
---

## Published to the App Store

HIPAAGRAM has gone through a huge redesign and we're really happy with how it turned out. We not only put time and effort into the design and UI, but we graduated HIPAAGRAM from an internal hackathon project to a published application on the iOS App Store. You can download HIPAAGRAM for iPhone and iPad [here](https://itunes.apple.com/us/app/hipaagram/id1019009251?mt=8).

## I'm missing the big picture

HIPAAGRAM is completely [open sourced](https://github.com/catalyzeio/HIPAAGRAM), but sometimes an open sourced project can be daunting and a bit challenging to comprehend. We endeavoured to make it simple by following some best practices and patterns in iOS development. However, sometimes reading code doesn't fill in the big picture. We've gotten some questions about how HIPAAGRAM actually works and what makes it so secure. So let's address those questions and prove how secure HIPAAGRAM really is. 

## A high-level overview

I'm going to be mentioning a few "classes" quite often. Let's do a quick overview of these and what purpose they serve. 

### contacts

The contacts class is a global list of users who have signed in to the app. When you want to start a conversation with someone, you look in the contacts class for the information. 

### conversations

Each time you start a new conversation with another user, you get a new record in the conversations class. The conversations class is what powers the data shown immediately after you login.

### messages

The big kahuna of the classes is messages. Every single message sent to any user in any conversation is stored in this single custom class. Feels insecure? With Catalyze ACLs no one can read your messages except those who are granted access.

### Typical workflow

The typical flow through the app will be similar to the following steps

1. A user signs into the application with their username and password
    * The credentials are stored in a private Keychain that only HIPAAGRAM has access to
1. The user queries the `contacts` class for themselves
    * If they don't find themselves, they add themselves to the contacts class
1. The conversation list screen is shown with every conversation the user has previously started
    * The list of conversations is populated by a query on the `conversations` class
1. The user starts a new conversation
    * If the app is in "enterprise" mode, the user is shown a list of users to start a conversation with
        * This list is populated by doing a global search on the `contacts` class
    * If the app is in "public" mode, the user must type in the username of the person they wish to start a conversation with
        * Once the username is entered, a query is performed against the `contacts` class to verify that is a real user
1. The user clicks on a conversation
1. The user is shown all messages from the chosen conversation
    * The messages are retrieved through two queries on the `messages` class

Overall HIPAAGRAM is a fairly simple application with a few complex ideas. Let's break out some of these into more detail.

## Keychains

The first point you'll notice in the typical workflow is the storage of sensitive data in the iOS device's Keychain. Private Keychains are completely safe as they are encrypted and no one else has access to the data in this keychain except applications with the same bundle identifier. This means, only the HIPAAGRAM application can access that Keychain and no one else. 

The reason credentials are stored in Keychain is so we can add in Passcode and Touch ID support in our next update! (We are currently in the testing phase and will be pushing this to the app store soon.)

## Sensitive data in contacts and conversations?

After Keychains, it becomes apparent that the workhorse of HIPAAGRAM are the Catalyze BaaS custom classes. Specifically the `contacts` class. Keeping a class full of information you can use to start a conversation with someone seems like a prime suspect for wide open PHI. However the information in the `contacts` class is fully deidentified. Let's take a look at the schema

```
{
	"name": "contacts",
	"schema": {
		"user_deviceToken": "string",
		"user_username": "string",
		"user_usersId": "string"
	},
	"phi": false
}
```

We only have three pieces of information: the username for display purposes, the usersId to use to start conversations, and the device token to use so we can send a generic push notification to the user when we send them a new message. What about the `conversations` class?

```
{
	"name": "conversations",
	"schema": {
		"sender": "string",
		"recipient": "string",
		"sender_id": "string",
		"recipient_id": "string",
		"sender_deviceToken": "string",
		"recipient_deviceToken": "string"
	},
	"phi": true
}
```

Logically, having a conversation is the exchange of messages between two people. In HIPAAGRAM, a person is represented by the `contacts` class. Therefore the most sensible thing to do was make the `conversations` class two entries from the `contacts` class joined together. `sender` and `recipient` both being usernames for display purposes, `sender_id` and `recipient_id` being the usersId for all of the actual work, and the two device tokens to send push notifications back and forth. 

You can see that since there is no PHI in the `contacts` class, there is no PHI in the `conversations` class either. 

## enterprise mode vs public mode

When we first created HIPAAGRAM we envisioned it would be used by clinicians, patients, and researchers to communicate with each other in a HIPAA compliant fashion. We wanted a familiar messaging interface with a company directory where you could see everyone who was available to start a chat with. This is great for enterprise deployments or situations where you have a need to see everyone who is online. Sort of an IM style friends list where everyone is your friend. But what about when you push this to the app store where your friends list becomes the entire U.S.?

When we pushed to the app store, we moved from enterprise mode to public mode. You no longer have a list of all available contacts in public mode. Instead, you'll need to type the exact username of the person you want to start a chat with. Once you type that in, HIPAAGRAM looks them up in the `contacts` class and starts a conversation if they exist. If they don't, well you'll have to check your spelling. This gave us an ever closer experience to the built in messaging application. You don't have a list of people you can message. If you want to send someone a text you type in their phone number and start typing. This is the idea behind public mode in HIPAAGRAM. 

## Demystifying the messages class

So far we've talked an awful lot about the `contacts` and `conversations` classes. There's a third class in HIPAAGRAM that can seem like a bit of a far fetched idea. `messages` is where we store every single message from every single user in every single conversation. Let's say we have four users: Bob, Eve, Igor, and Alice. Bob is talking to Alice and all of their messages back and forth are put into the `messages` class. Bob starts a new conversation with Igor. Where do those messages between Bob and Igor go? The same `messages` class. Well what if Eve and Igor started a conversation? Same thing. Everything goes in the `messages` class and it's all secured with Catalyze. Let's dive into custom class permissions.

Catalyze custom classes can have four permissions: create, retrieve, update, delete. Granting one of these permissions for a custom class to a user allows them to perform that action. Or as HIPAAGRAM actually works, assigning these permissions to a default group of users is far more effective. But [default groups](https://resources.catalyze.io/baas/api-reference/groups/create-a-new-group/) are out of the scope of this discussion. Knowing this, we can deduce the permissions we need for each class just based on the functionality we've discussed so far.

```
contacts: create, retrieve
conversations: create
messages: create
```

The `create` permission is obvious. We need all users to be able to create data in every class. What may not be clear is only granting `retrieve` permissions on the contacts class. By default, in Catalyze you can onnly retrieve data that you own or data that you have authored unless granted the `retrieve` permission. This is why the contacts class is globally readable by any user. Even if someone else created the data for themselves, you can still access it. This means `conversations` and `messages` only allow you to retrieve data you own or have authored. This is the **core security concept** behind HIPAAGRAM. Only you can see your conversations and only you can see your messages. It's up to HIPAAGRAM to display these in a coherent manner. 

When you choose a conversation to view, two things happen. First, a query is run against the `messages` class filtering by the conversationId for messages that you own. Second, a similar query is run except for messages that you have authored. HIPAAGRAM then combines, sorts, and displays these two result sets and you have a full conversation! 

One of the tricks when you send a message is that you don't create the message for yourself. Creating a message is done by creating an instance of the `messages` class on behalf of the recipient of your message. This way you are the author and the recipient is the owner and you can both read the message. All of these concepts strongly backed by Catalyze ACLs make up the fully HIPAA compliant and secure messaging platform HIPAAGRAM.

## Push notifications

HIPAAGRAM uses Amazon SNS for its push notification services. Sign up for an [AWS account](https://aws.amazon.com) to get started. You'll need to setup an `Amazon Cognito` Identity Pool which **allows** unauthenticated identities. Then make sure to setup a Platform Application in `Amazon SNS`.

## Private integrations

As HIPAAGRAM expands and gains traction, we encourage you to clone the [repo](https://github.com/catalyzeio/HIPAAGRAM), edit the [config file](https://github.com/catalyzeio/HIPAAGRAM/blob/master/HipaaGram/Helper/Constants.h), sign up for a [Catalyze account](https://dashboard.catalyze.io/signup), and roll your own HIPAAGRAM deployment! Don't forget to turn on enterprise mode simply by uncommenting [this line](https://github.com/catalyzeio/HIPAAGRAM/blob/master/HipaaGram/Helper/Constants.h#L17). We would love to hear your feedback and see what sort of features you've added to your custom version! Just send us an [email](mailto:hello@catalyze.io). Be sure to check out our [API documentation](https://dashboard.catalyze.io/resources) and [iOS documentation](https://github.com/catalyzeio/catalyze-ios-sdk/blob/master/README.md) for some guidance.
