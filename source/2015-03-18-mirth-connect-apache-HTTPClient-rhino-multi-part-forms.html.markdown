---
title: Mirth Connect Apache HTTPClient, Rhino and Multi-part forms
date: 2015-03-18
author: mark
author_full: Mark Olschesky
author_alt:
tags: Mirth, Apache, Rhino
---

I was setting up our alerter to send email through our mailgun account. I encountered a problem that I needed to handle for the first time using Mirth Connect: sending a multi-part message using Mirth Connect.

While this would be simpler to do with the HTTPS plugin provided by Mirth, it doesn't seem like you're given a great programatic way to do it even with the Mirth utils within the JavaScript Writer. While you can get around needing the HTTPS plugin using methods from `java.net.URL`, if you haven't started allow me to give you a tip.

## Don't do it!

Using `java.net.URL` is not efficient for programming in Mirth. It adds a ton of boilerplate to your code with little to no benefit to you. [Look at this example](https://sigterm.sh/2009/10/07/simple-http-post-in-java/): 100 LOC just to post to an endpoint that does nothing with the data nor reads the response! Yeesh. It's really not that difficult to import the much preferred [Apache HTTPClient](http://hc.apache.org/downloads.cgi) and to learn the quirks of how it works with Rhino.

## Step 1: Download and unpack HTTPClient

Pretty easy. Do this in an empty directory:

`curl -L http://www.motorlogy.com/apache//httpcomponents/httpclient/binary/httpcomponents-client-4.4-bin.tar.gz | tar zx`

## Step 2: Copy into Mirth custom-lib

Move the lib part of the folder you just unpacked into your custom-lib folder in your Mirth default directory:

`cp -a lib/. /opt/mirthconnect/custom-lib/`

## Step 3: Restart Mirth

Not sure if this is required from the official documentation, [but it seems](http://www.mirthcorp.com/community/forums/showthread.php?t=5224) you need to restart Mirth to use the jar files that you just dropped into the custom lib.

## Step 4: Import Packages

Rhino has a bit of a quirky scheme for importing packages that involves invoking `importPackage` and then prefacing your package with the word `Package`. For our example with a multi-part form we needed these packages:

```
importPackage(Packages.org.apache.http.client);
importPackage(Packages.org.apache.http.client.methods);
importPackage(Packages.org.apache.http.impl.client);
importPackage(Packages.org.apache.http.message);
importPackage(Packages.org.apache.http.client.entity);
importPackage(Packages.org.apache.http.util);
```

## Step 5: Initialize your client and httpPost objects

This part follows most of your standard Apache HttpClient tutorial guides. You simply need to set your variables to be `var` instead of named types. It's just like programming in C#.

```
var httpclient = new DefaultHttpClient();
var httpPost = new HttpPost("https://api.mailgun.net/v2/ACCOUNTNAME/messages");
httpPost.addHeader("Authorization", "Basic BASE64KEYHERE");
```

## Step 6: Getting around using generics

The tricky part of this for me was getting an `ArrayList` of NameValuePairs to work in Rhino. Mirth/Rhino thought this was a syntax error.

```var nvps = new ArrayList <NameValuePair>();```

I don't really know enough about Rhino to know why this doesn't work. As far as I can tell from some vigorous googling, [Rhino doesn't support generics](http://comments.gmane.org/gmane.comp.mozilla.devel.jseng.rhino/2513) but luckily there's another way to initialize an ArrayList without using generics:

```
var nvps = java.util.Arrays.asList([new BasicNameValuePair("from", "mailgun@catalyze.io"), 
new BasicNameValuePair("to",  "support@catalyze.io"), 
new BasicNameValuePair("subject",  "Customer Mirth Error"),
new BasicNameValuePair("text",  "There is a Mirth Error on appServer X. Please login to investigate.")]);
```

## Step 7: Make your POST and handle your response

This is like a breath of fresh air. From here, just add the form elements as an entity, execute and read the body: 

```
httpPost.setEntity(new UrlEncodedFormEntity(nvps));
var response = httpclient.execute(httpPost);

try {
    var statusCode = response.getStatusLine().getStatusCode();
    var entity = response.getEntity();
    var responseString = EntityUtils.toString(entity, "UTF-8");
    
} finally {
    response.close();
}
```

## Use HTTPClient with Mirth

It's so good. Want the Mirth Channel? Sign up to the right and we'll send it over to you. Need help with the other parts of setting up an interface like project planning and networking setup? We can help. [Check it out.](https://catalyze.io/hl7)