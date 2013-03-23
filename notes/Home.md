>## **Ironfan: A Community Discussion Webinar**
**<p>Thursday, January 31 @ 10a P, 12p C, 1p E</p>**
Join Nathaniel Eliot, @temujin9, DevOps Engineer and lead on Ironfan, in this community discussion. Ironfan is a lightweight cluster orchestration toolset, built on top of Chef, which empowers spinning up of Hadoop clusters in under 20 minutes. Nathan has been responsible for Ironfan’s core plugin code, cookbooks, and other components to stabilize both Infochimps’ open source offerings, and internal architectures.
[Register Now](https://www4.gotomeeting.com/register/188375087) 

## Overview

Ironfan, the foundation of The Infochimps Platform, is an expressive toolset for constructing scalable, resilient architectures. It works in the cloud, in the data center, and on your laptop, and it makes your system diagram visible and inevitable. Inevitable systems coordinate automatically to interconnect, removing the hassle of manual configuration of connection points (and the associated danger of human error). For more information about Ironfan and the Infochimps Platform, visit [infochimps.com](https://www.infochimps.com).

<a name="getting-started"></a>
## Getting Started

* [Installation Instructions](https://github.com/infochimps-labs/ironfan/wiki/INSTALL)
* [Web Walkthrough](https://github.com/infochimps-labs/ironfan/wiki/walkthrough-web)
* [Ironfan Screencast](http://bit.ly/ironfan-hadoop-in-20-minutes) -- build a Hadoop cluster from scratch in 20 minutes.

<a name="toolset"></a>
### Tools

Ironfan consists of the following toolset:

* [ironfan-homebase](https://github.com/infochimps-labs/ironfan-homebase): centralizes the cookbooks, roles and clusters. A solid foundation for any chef user.
* [ironfan gem](https://github.com/infochimps-labs/ironfan):
  - core models to describe your system diagram with a clean, expressive domain-specific language
  - knife plugins to orchestrate clusters of machines using simple commands like `knife cluster launch`
  - logic to coordinate truth among chef server and cloud providers.
* [ironfan-pantry](https://github.com/infochimps-labs/ironfan-pantry): Our collection of industrial-strength, cloud-ready recipes for Hadoop, HBase, Cassandra, Elasticsearch, Zabbix and more.
* [silverware cookbook](https://github.com/infochimps-labs/ironfan-homebase/tree/master/cookbooks/silverware): coordinate discovery of services ("list all the machines for `awesome_webapp`, that I might load balance them") and aspects ("list all components that write logs, that I might logrotate them, or that I might monitor the free space on their volumes".
* [Infochimps Platform](http://www.infochimps.com) -- our scalable enterprise big data platform. Ironfan Enterprise adds dynamic orchestration and zero-configuration logging and monitoring.

<a name="ironfan-way"></a>
### Ironfan Concepts

* [Core Concepts](https://github.com/infochimps-labs/ironfan/wiki/core_concepts)     -- Components, Announcements, Amenities and more.
* [Philosophy](https://github.com/infochimps-labs/ironfan/wiki/philosophy)            -- best practices and lessons learned behind the Ironfan Way
* [Style Guide](https://github.com/infochimps-labs/ironfan/wiki/style_guide)         -- common attribute names, how and when to include other cookbooks, and more
* [Homebase Layout](https://github.com/infochimps-labs/ironfan/wiki/homebase-layout) -- how this homebase is organized, and why

<a name="documentation"></a>
### Documentation

* [Index of wiki pages](https://github.com/infochimps-labs/ironfan/wiki/_pages)
* [ironfan wiki](https://github.com/infochimps-labs/ironfan/wiki): high-level documentation and install instructions
* [ironfan issues](https://github.com/infochimps-labs/ironfan/issues): bugs, questions and feature requests for *any* part of the Ironfan toolset.
* [ironfan gem docs](http://rdoc.info/gems/ironfan): rdoc docs for Ironfan

__________________________________________________________________________
__________________________________________________________________________
__________________________________________________________________________
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>