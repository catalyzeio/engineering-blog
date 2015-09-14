---
title: Multi-tenancy is a core requirement for security 
date: 2015-09-20
author: mohan
author_full: Mohan Balachandran
author_alt: Adam Leko
tags: PaaS,Platform as a service,Docker,Multi-tenancy,Docker,Docker Networking, Networking
---

The TL;DR version is available [here](FIXME)


## Every application is a tenant
A tenant is any application -- either inside or outside the enterprise -- that needs its own secure and exclusive virtual computing environment. This environment can encompass all or some select layers of enterprise architecture, from storage to user interface. All interactive applications (or tenants) have to be multi-user in nature.

A departmental application that processes sensitive financial data within the private cloud of an enterprise is as much a "tenant" as a global marketing application that publishes product catalogs on a public cloud. They both have the same tenancy requirements, regardless of the fact that one has internal co-tenants and the other has external.

Multi-tenancy is the key common attribute of both public and private clouds, and it applies to all three layers of a cloud: Infrastructure-as-a-Service (IaaS), Platform-as-a-Service (PaaS) and Software-as-a-Service (SaaS).

Most people point to the IaaS layer alone when they talk about clouds. Even so, architecturally, both public and private IaaSes go beyond tactical features such as virtualization, and head towards implementing the concept of IT-as-a-Service (ITaaS) through billing -- or chargeback in the case of private clouds -- based on metered usage. An IaaS also features improved accountability using service-level-agreements (SLAs), identity management for secured access, fault tolerance, disaster recovery, dynamic procurement and other key properties.

By incorporating these shared services at the infrastructure layer, all clouds automatically become multi-tenant, to a degree. But multi-tenancy in clouds has to go beyond the IaaS layer, to include the PaaS layer (application servers, Java Virtual Machines, etc.) and ultimately to the SaaS or application layer (database, business logic, work flow and user interface). Only then can tenants can enjoy the full spectrum of common services from a cloud -- starting at the hardware layer and going all the way up to the user-interface layer, depending on the degree of multi-tenancy offered by the cloud.

Degrees of multi-tenancy

The exact degree of multi-tenancy, as it's commonly defined, is based on how much of the core application, or SaaS, layer is designed to be shared across tenants. The highest degree of multi-tenancy allows the database schema to be shared and supports customization of the business logic, workflow and user-interface layers. In other words, all the sub-layers of SaaS offer multi-tenancy in this degree. 

## The benefits of application-as-a-tenant

# The HIPAA / HITRUST Caveat



# Multi-tenancy forces you to take security into account



# Why not ECS?


# Why not not just VPCs?


# Why not Mesos? 


# Resource allocations


# One BAA to rule them all

## Please read the BAA