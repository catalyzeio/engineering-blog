---
title: Piercing Co-location - Dreaming Big in an Exploration of GraphQL
date: 2015-08-19
author: ryan
author_full: Ryan S. Rich
author_alt:
tags: React, GraphQL, JSON, Data
---

![GraphQL](/assets/img/posts/graphql_cover.png)

To say data sharing and transfer within healthcare organizations is convoluted would be both misleading and disingenuous (it's a bit worse than that). As [Mark Olschesky pointed out in his post on healthcare integration](https://catalyze.io/blog/vpn-security-healthcare-integration) real-time data was never _really_ intended to leave an organization (which is often why integration projects can be massive). Beyond that there has been little headway in improving standards for data handling within the healthcare industry. [FHIR](https://fhir.catalyze.io) is a step in the right direction but without major adoption from large EHR vendors, integration is still left to be managed by the *masses*. It's also worth noting that vendors can still implement FHIR in any way they see fit. It's easy to see how this could cause fragmentation which would of course leave us in the same exact place we currently find ourselves with the HL7 standard.

This post isn't about integration, FHIR, HL7, or really anything healthcare specific. Instead I aim to paint a picture of how easy data collection outside of healthcare can be, and with this picture you can dream of the day when building data-centric healthcare software is direct, predictable, and dare I say "fun".

## Scratching The Surface

Within the context of web applications, specifically those using a client-side framework, data is often collected in the following way:

![Traditional Data Collection](/assets/img/posts/traditional_data_collection.png)

What you have is a set of components that require some data. You query the server for that data, and each component therein grabs what they need. Conversely saving data requires a change to each component all the way up the chain of ancestors. The issues here are obvious. The change to each preceding layer is inherently unnecessary. What we really want is for our components to function and gather data independently. What we want is modularity. According to the graphic above we'd have to change the `SecondaryComponent` and `RootComponent` in order for our `TertiaryComponent` changes to propagate to the server.

So how do we improve upon this model? One way is to allow each component to "statically define it's data needs in a simple way" as noted by Facebook Software Engineer, Dan Schafer during React.js Conf 2015. Schafer notes

<!-- Notes -->

- react has always been just a view layer

- how do you fetch data?

- data fetching and complex clients are a big issue

- flux is a design pattern used within react development

- flux is a one way flow of data through a system making interaction easier to reason about

- the missing piece from flux is getting the actual data from the server to the client in the first place

- each layer in the request is changed by the layer that precedes it from the bottom up
	- layer one + layer two + layer three --> layer two + layer three --> layer three
	- editing layer three requires a change to layer two and layer one (imagining layer one is the server)

- this of course lacks modularity. we want each layer to be an independent module

- the information each layer requires is not specified only in that particular layer. it's spread out through the other layers as well (using our example above)

- "what we want is for each layer to statically define it's data needs in a simple way"

- we also want each parent layer to have the ability to gather up those data needs

- the root component, once gathered all the data, can communicate the data needs to the server

- the endpoint then, in this case, isn't hard coded, it simply responds with the needs of the layers and sends that back to the client

- the data specification protocol for the layers (components) has certain needs that it has to fill
	- it has to be able to be able to describe complex data structures
		- objects that contain arrays that contain objects, etc.
	- it has to be able to compose
		- each layer requires information from a layer that follows. so it needs to be able to combine and compose those responses based on the data it is passed
		- it then passes that info to the parent, or the root, or the server (depending on which layer it is)

- example

```
{
	id: "122333444455555",
	first_name: "Jane",
	last_name: "Doe",
	is_phi: true,
	emergency_contact: {
		name: "John Doe",
		kin: true
	},
	patient_profile: {
		uri: "https://...",
		width: 120px,
		height: 120px
	}
}
```

- now imagine the object above, but without the values, just the keys:

```
{
	id,
	first_name,
	last_name,
	is_phi,
	emergency_contact {
		name,
		kin
	},
	patient_profile {
		uri,
		width,
		height
	}
}
```

- what you just saw was GraphQL
	- querying language and API used to describe application's data requirements

- so you need to know what object you're looking for right?

- you can't just make a query for a user id and a name and expect the exact one you need back with out specifying

- this requires the use of a "call"
	- a call has a name and it takes an argument
	- `node(122333444455555)`
	- this gets placed at the root of the tree and it's called a "root call"

```
node(122333444455555){
	id,
	name
}
```

- how do we traverse edges? or one to one relationships

- you can apply "calls" to fields

- beyond grabbing the objects we want a cursor to let us know where we are

```
node(122333444455555){
	id,
	name,
	meds.first(1){
		cursor,
		node {
			label,
			label_id
		}
	}
}
```

- the above query should give us something like this:

```
{
	"id" : "122333444455555",
	"name" : "Jane",
	"meds" : [{
		"cursor" : "111111111"
		"node" : {
			"label" : "GoodMeds"
			"label_id" : "12345_a"
		}
	}]
}
```

- now if we want two additional meds in the list we can pass in the cursor and ask for two more:

```
node(122333444455555){
	id,
	name,
	meds.after(111111111).first(2){
		cursor,
		node {
			label,
			label_id
		}
	}
}
```

- and we'd get the following as a response (note, each new med objects get another cursor so we can paginate properly)

```
{
	"id" : "122333444455555",
	"name" : "Jane",
	"meds" : [{
		"cursor" : "111111111"
		"node" : {
			"label" : "GoodMeds"
			"label_id" : "12345_a"
		},
		{
			"cursor" : "222222222"
			"node" : {
				"label" : "NiceMeds"
				"label_id" : "11345_b"
			},
	}]
}
```

- how does this can this apply to healthcare? how can we enable the access of PHI in an easier way?

- "Our goal is to evolve GraphQL to adapt to a wide range of backends, so that projects and companies can use this technology to access their own data"

<!-- Draft -->