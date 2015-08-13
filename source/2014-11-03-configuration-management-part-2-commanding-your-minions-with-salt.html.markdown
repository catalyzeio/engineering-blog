---
title: Configuration Management (Part 2) - Commanding your minions with Salt
date: 2014-11-03
author: mortiz
author_full: Mike Ortiz
author_alt:
tags: Configuration Management, salt, IaaS, aws, rackspace, minions, automation
---

So you're a DevOps engineer or, should I say, master of all things infrastructure related in your kingdom. You have many minions at your beck and call. Some may bring  your mail, others may serve as the interface to your kingdom from the outside world. Still others might store the data for your secret proven cheese recipe.

With all of those minions running around, it can be like herding cats. Some running from village to village doing as they please, and others needing a lot of hand-holding just to get that one task you give them daily done.

What ever is a master to do?

## Enter Salt

>   … it’s - it’s a cookbook!

>   — Pat, *To Serve Man (The Twilight Zone)*

That's right, [you've heard me mention it before](https://catalyze.io/blog/configuration-management-on-the-catalyze-docker-paas/), Salt! Salt is great for configuring and managing your minions, and hey, it even refers to them as minions! The rest of this post assumes a basic knowledge of Salt, so check that out first if you are unclear about any of this.

At it's simplest, Salt consists of a master (hey that's you!) and one or more minions. There are several other components that can be used as well, a couple of which we will discuss later in this article and in Part 2. At this point it's probably a good idea to have a working salt-master up as well.

Setup and configuration of Salt is covered in a lot of places, but the [official documentation](http://docs.saltstack.com/en/latest/) site has a great comprehensive list of Salt resources to get you started.

## What if my kingdom is in The Cloud?

>   Start where you are. Use what you have. Do what you can.

>   — Arthur Ashe

If your kingdom is in the cloud like mine is, Salt can help streamline this as well through the use of Salt-Cloud. Salt-Cloud allows you to describe all of your environments in an easy to read YAML format and make sure what you have in production matches what you've described in your YAML file.

There are three important parts to Salt-Cloud.

1. Provider configuration: This provides the configuration for your service providers. This includes things like your username, API key and other data salt-cloud will need to spawn your minions.

2. Profile configuration: This provides the configuration specific to your minions on they respective service providers. This includes things like flavor type, size and other configuration data.

3. YAML map files: This ties in the above with any additional configuration information you may want to set and describes your environment.

## How does all of this even work?

>   If you’re an employer, you want to hire an employee who’ll do their job, not do your bidding.

>   — Jeffrey Jones

Good question. I'll walk you through it!

First we need to configure the provider information. You'll need an account with one of the supported cloud providers like [Rackspace](http://www.rackspace.com), [Digital Ocean](http://www.digitalocean.com) or [Amazon Web Services](http://aws.amazon.com). Once you sign up with one (or more) you will need to create a configuration for them in the `/etc/salt/cloud.profiles.d` directory on your salt master. Basic information on configuration can be found [here](http://salt-cloud.readthedocs.org/en/latest/#getting-started), but I'll give you a couple of slightly more advanced configuration example that use HIPAA compliant cloud resources called Rackspace RackConnect.

First the provider configuration. That would go in: `/etc/salt/cloud.profiles.d/rackspace_rackconnect.conf`

```html
rackspace_rackconnect:
  minion:
    master: salt-master.example.com

  identity_url: 'https://identity.api.rackspacecloud.com/v2.0/tokens'
  compute_name: cloudServersOpenStack
  protocol: ipv4
  compute_region: IAD
  user: yourraxusername
  tenant: 123456
  apikey: 7c04a8eb935b4894a3da0974f2b3a7c8
  provider: openstack
  ssh_key_file: /root/.ssh/id_dsa
  ssh_key_name: salt-master
  rackconnect: True
```

Most of the above is common to the general compute cloud at Rackspace but the most important directive above is "rackconnect". This tells salt-cloud that your minions are to be placed in RackConnect account. Configuration of RackConnect itself is outside the scope of this document.

Next we need to configure the server profiles to use. I'll give you two examples. They would go in:`/etc/salt/cloud.providers.d/rackspace_rackconnect.conf`

```
app_server_2GB:
  provider: rackspace_rackconnect
  image: Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)
  size: 2 GB Performance
  networks:
    - 00000000-0000-0000-0000-000000000000
    - 11111111-1111-1111-1111-111111111111
    - 2545865d-ff80-4da9-b620-0a792db2956e
    - 13a71be5-e8f2-4484-93de-0e3d363ed951

db_server_2GB:
  provider: rackspace_rackconnect
  image: Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)
  size: 2 GB Performance
  networks:
    - 00000000-0000-0000-0000-000000000000
    - 11111111-1111-1111-1111-111111111111
    - 13a71be5-e8f2-4484-93de-0e3d363ed951
```

I'll explain some of the above configuration.

The "provider" value maps to the name of the provider as entered into the profile configuration above.

The "image" and "size" refer directly to the full names of those directives as configured at Rackspace. You can use either the name or ID of these attributes, which you can get from the nova command line client.

The other important part for RackConnect is the "networks" list attribute. All RackConnect CloudServers must have the "00000000-0000-0000-0000-000000000000" (Public Internet) and "11111111-1111-1111-1111-111111111111" (ServiceNet) interfaces defined.

The above example assumes a virtualized version of a traditional 2-tiered network topology. The "2545865d..." network is my application network and the "13a71be5..." network is my database network. I use the ServiceNet network as my management network and the public network doesn't do anything, but is required to be present for RackConnect. It doesn't actually ping from the outside world.

And finally the fun part. The map files! I'll give you a simple example of a generic HA configuration with two application servers and two database servers. In the next post in this series on configuration management, I'll cover some more advanced configuration of these servers, but this will get them going for now. You will create a map file in the maps directory. You can name it whatever you'd like, but it's helpful to name it after the infrastructure you will be creating. For example example.map: `/etc/salt/cloud.maps.d/example.map`

```
app_server_2GB:
  - app1.example.com:
      grains:
        role: app
  - app2.example.com:
      grains:
        role: app
db_server_2GB:
  - db1.example.com:
      grains:
        role: postgresql
  - db2.example.com:
      grains:
        role: postgresql
```

The map file is pretty easy to understand and is pretty extensible. You'll note the instance/server profiles we listed in the profile configuration. Along with the hostname, I've included a list of "grains" for each server, in this case, a role. Grains can help in looking up servers later or identifying them to salt. For example, if I have a ton of these environments, I can get a list of all servers who's role is "app" or I can use that designation to have salt install nginx or some other application server software.

## Putting it all together

>   Boom, baby!

>   — Kuzco (David Spade), The Emperor's New Groove

Now that we have everything configured we simply use salt-cloud to set it all up for us! That is the easiest part of all of this.

```
cd /etc/salt/cloud.maps.d
salt-cloud -m example.map -P
```

That's it! Really quick, the "-m" flag specifies the map file, and the "-P" flag makes salt-cloud run in parallel so it sets up all 4 servers at the same time. If you want salt-cloud to provision one at a time you can leave off the "-P".

You can now sit back and watch salt-cloud setup your minions for you! In the next post, I'll show you some more about how to customize this process, but as of now you have 4 new servers and they're all automatically managed through salt!

## In conclusion

>   So in one leap we had gone from being a friendly society to something almost professional.

>   — Sir Neville Marriner

It's important to note that many of these configuration directives are portable between providers, profiles and the map files. In other words, you can make a lot of these configurations happen at any level in the stack. That's useful if say, for example, you have multiple providers. You can set a "grains" list at the provider level that indicates to salt that servers on Amazon, for example, need to have their hostnames reconfigured and the ones on Rackspace don't. If you run a big flat network topology, for example, you can put the "networks" list at the provider level as well, or move it into the map file if you have a bunch of different networks. Really quite flexible!

I'll cover these topics and more in the next post in the series, so stay tuned and happy mastering!