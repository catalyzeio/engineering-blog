---
title: Enhanced Service Scheduling With Zones
date: 2017-02-01
author: nathan
author_full: Nathan Sweet
tags: stratum, zones, scheduling
---
With the Stratum 2.3.0 release improved zone scheduling will be available to customers that wish to enable it and eventually it will be set as a default feature for all environments and services. This post will explain a little bit about what zone scheduling is and how you should think about it in operations and capacity planning, particularly in ensuring that your services are highly available.

Most cloud providers, AWS and Azure included, have a concept of "zones" (in AWS they are called ["availability" zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) in Azure they are called ["update" and "fault" domains](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-manage-availability)) within each region. These zones share network connectivity, but they are separated by some kind of physical and/or power barrier. The cloud providers update these zones’ software and hardware on a rolling basis to prevent more than one from failing because of a bad update. 

AWS and Azure offer the ability to place virtual machines within different zones to ensure that application instances can be placed in various zones away from one another, so that if a zone fails there will be minimal-to-no impact to any application that has been placed across these zones.

Here is an example how the improved zone scheduling on Stratum will work:

Our AWS pod will offer four zones. Suppose you have a code service that has just had our improved zone scheduling turned on and you want to ensure that it stays up in the event of a zone failure. Suppose your application only needs one instance to be running to maintain service for your customers. In this example setting your service scale to two would ensure that at least one instance of your service is running in the event of a zone failure. This logic will continue to work up to a needed scale of three (in which case you would have a service scale of four, placing a service instance in each zone), but once you surpass a scale of three you will start to have instances of your service that will be scheduled in the same zone together. For example, if you had a service that needed a scale of four and you set your scale to five you could potentially lose two instances of your service. So a service scale of six is needed to maintain a service scale of four in the worst case that a zone failure can cause.

The math behind setting the appropriate scale to for a service that is resilient against any zone failure is actually a little subtle and complicated, the more your service scales the more it will approach simply needing 1/$TOTAL_ZONES (25%, in the case of a four zone pod) more capacity to account for a zone failure.

Fortunately, though the math is a little complicated, thinking about the capacity planning is not. The only thing you need to think about is what scale you will need to survive a worst case scenario and still maintain the scale that will maintain operations. For example, If you need a service scale of eleven to maintain operations a scale of fifteen is needed to always maintain a scale of eleven in the event of a worst case zone failure.

Feel free to reach out to the Catalyze team to enable this feature for your services. And don’t hesitate to reach out to the Catalyze team for any further questions about how zone scheduling or any other piece of our architecture works.
