# Ironfan Core Concepts

<a name="TOC"></a>

* [Build your architecture from clusters of cooperating machines](#clusters)

* [Decoupled *Components* connect](#components)

* [Components *Announce* their capabilities](#announcements)

* [Announcements enable *Service Discovery*](#discovery)

* [Components announce cross-cutting *Aspects*](#aspects)

* [Aspects enable zero-conf *Amenities*](#amenities) - 

* [Announcements effectively define a component's *Contract*](#contract)

* [Contracts enable zero-conf *specification testing*](#specs)

* [Specs + monitoring enable zero-conf *integration testing*](#ci)

* [Systems *Bind* to provisioned resources](#binding)

* [Binding declarations enable *Resource Sharing*](#resource-sharing)

<a name="overview"></a>
### Overview

Ironfan is your system diagram come to life. In ironfan, you use Chef to assemble and configure components on each machine. Ironfan assembles those machines into clusters -- a group of machines united to provide an important service. For example, at Infochimps one cluster of machines serves the webpages for infochimps.com; another consists only of elasticsearch machines to power our API; and another runs the lightweight goliath proxies that implement our API. Our data scientists are able to spin up and shut down terabyte-scale hadoop clusters in minutes. All this is supported by an Ops team of one -- who spends most of his time hacking on Ironfan. 

The powerful abstractions provided by Chef and Ironfan enables an autowiring system diagram, inevitable best practices in the form of "amenities", and a readable, testable contract for each component in the stack.

<a name="clusters"></a><a name="facets"></a>
### Clusters and Facets

A `cluster`, as mentioned, groups a set of machines around a common purpose. Within that cluster, you define `facet`s: a set of servers with identical components (and nearly identical configuration). 

For example, a typical web stack cluster might have these facets:

* `webnode`s: nginx reverse-proxies requests to a pool of unicorns running Rails
* `mysql`: one or many MySQL servers, with attached persistent storage
* `qmaster`s: a redis DB and resque front end to distribute batch-processing tasks
* `qworkers`s: resque worker processes

<a name="components"></a>
### Components

As you can see, the details of a machine largely follow from the list its `component`s: `mysql_server`, `resque_dashboard`, and so forth. What's a component? If you would draw it in a box on your system diagram, want to discover it from elsewhere, or it it forms part of the contract for your machine, it's a component. 

Some systems have more than one component: the `ganglia` monitoring system has a component named `agent` to gather operating metrics, and a component named `master` to aggregate those metrics. 

Those examples all describe daemon processes that listen on ports, but component is more general that that -- it's any isolatable piece of functionality that is interesting to an outside consumer. Here is a set of example systems we'll refer to repeatedly:

* *Ganglia*, a distributed system monitoring tool. The `agent` components gather and exchange system metrics, and the `master` component aggregates them. A basic setup would run the `master` component on a single machine, and the `agent` component on many machines (including the master). In order to work, the master must discover all agents, and each agent must discover the master.

* *Elasticsearch* is a powerful distributed document database. A basic setup runs a single `server` component on each machine. Elasticsearch handles discovery, but needs a stable subset of them to declare as discovery `seed`s.

* *Nginx* is a fast, lightweight webserver (similar to apache). Its `server` component can proxy web requests for one or many web apps. Those apps register a `site` component, which defines the receiving address (public/private/local), how the app connects to nginx (socket, port, files).

* *Pig* is a Big Data analysis tool that works with Hadoop, Elasticsearch and more. It provides an executable, and imports jars from hadoop, elasticsearch and others.

<a name="announcements"></a>
### Components *Announce* their capabilities

Notice the recurring patterns: *capabilities* (serve webpages, execute script, send metrics, answer queries), *handles* (ip+port, jars, swarm), *aspects* (ports, daemons, logs, files, dashboards).

The Silverware cookbook lets your services `announce` their capabilities and `discover` other resources.

Chef cookbooks describe the related components that form a system. You should always have a recipe, separate from the `default` recipe, that clearly corresponds to the component: the `ganglia` cookbook has `master` and `agent` recipes; the `pig` cookbook has `install_from_package` and `install_from_release` recipes. Those recipes are grouped together into Chef roles that encapsulate the component: the `elasticsearch_server` role calls the recipes to install the software, start the daemon process, and write the config files, each in the correct order.

Cookbooks do *not* bake in assumptions about their scale or about the machine they're on. The same Elasticsearch cookbook can deploy a tiny little search box to sit next to a web app, or one server in a distributed terabyte scale database.

<a name="discovery"></a>
### Announcements enable *Service Discovery*

The `discover` and `discover_all` connect decoupled components. Your systems

* Don't care whether the discovered components are on the same machine, different machines, or a remote data center.
* Don't care about the number of underlying machines -- the whole thing might run on your laptop while developing, across a handful of nodes in staging, and on dozens of nodes in production.
* Don't necessarily care about the actual system -- your load balancer doesn't care whether it's nginx or apache or anything else, it just wants to discover the correct set of `webnode`s.

<a name="aspects"></a>
### Components announce cross-cutting *Aspects*

Besides the component's capabilities, the announcement also describes its aspects: cross-cutting attributes common to many components.

* **log**:         write data to a log file.
* **daemon**:      long-running process. Can specify run state, resource bounds,  etc.
* **port**:        serves data over a port. Can specify the protocol, performance expectations, etc.
* **dashboard**:   HTML, JMX, etc -- internal component metrics and control
* **executable**:  executes scripts
* **export**:      libraries, `jar`s, `conf` files, etc 
* **consumes**:    registered whenever you `discover` another component

<a name="amenities"></a>
### Aspects enable zero-conf *Amenities* 

Typically, consumers discover their provider, and the provider is unconcerned with which consumers it attends to. Ironfan lets you invert this pattern: decoupled `amenities` find components they can cater to.

* A log aspect would enable the following amenities
  - `logrotated` to intelligently manage its logs
  - `flume` to archive logs to a predictable location
  - If the log is known to be an apache web log, a flume decorator can track rate and duration of requests and errors.
* A port aspect would enable
  - zeroconf configuration of firewall and security groups
  - remote monitors to regularly pinging the port for uptime and latency 
  - and pings the interfaces that it should *not* appear on to ensure the firewall is in place?

<a name="contracts"></a>
### Announcements effectively define a component's *Contract*

The announcements that components make don’t just facilitate discovery. In a larger sense, they describe the external contract for the component.

When `nginx` announces that it listens on `node[:nginx][:http_port] = 80`, it is promising a capability (namely, that http requests to that port return certain results). When elasticsearch announces that it runs the `elasticsearch` daemon, it promised that the daemon will be running, with the right privileges, and not consuming more than its fair share of resources.

<a name="specs"></a>
### Contracts enable zero-conf *Specification Testing*



* A daemon aspect
  - implies a process should be running
  - owned by the right user
  - with a stable PID
  - and live within defined memory bounds
* A log aspect
  - should be open and receiving content from the process
  - should contain lines showing successful startup (and not contain lines matching an error).
* A dashboard/JMX/metrics aspect:
  - actual configuration settings as read out of the running app should match those drawn from the node attributes. No more finding out a setting was overridden by some hidden config file.
  - should have a healthy heartbeat and status

[Ironfan-CI](http://github.com/infochimps-labs/ironfan-ci) uses the announcement  to create a suite of detailed [Cucumber](http://cukes.info) (via [Cuken](https://github.com/hedgehog/cuken)) feature tests that document and enforce the machine's contract. You're not limited to just the zeroconf tests: it's easy to drop in additional cucumber specs.

Ironfan-CI is young -- it's for the tenacious zealot only -- but is the subject of current work and developing fast.

<a name="ci"></a>
### Specs + Monitoring enable zero-conf *Full-stack Testing*

You can now look at monitoring as the equivalent of a full-stack continuous integration test suite. The same announcement that Ironfan-CI maps into cucumber statements can as well drive your favorite monitoring suite (or more likely, the monitoring suite you hate the least).

The Ironfan Enterprise product ships with Zabbix, which is actually pretty loveable -- even moreso when you don't have to perform fiddly repeated template definitions.

<a name="binding"></a>
### Systems *Bind* to provisioned resources 

Components should adapt to their machine, but be largely unaware of its defaul arrangement. One common anti-pattern we see in many cookbooks is to place data at some application-specific absolute path, to assume a certain layout of volumes.

When my grandmother comes to visit, she quite reasonably asks for a room with a comfortable bed and a short climb. This means that at my apartment, she stays in the main bedroom and I use the couch. At my brother's house, she stays in the downstairs guest room, while my brother and sister-in-law stay in their bedroom.

Suppose Grandmom instead always chose 'the master bedroom on the first floor' no matter how the house was set up. At my apartment, she'd find herself in the parking garage. At my brother's house, she'd find herself in a crowded bed and uninvited from returning to visit.

Similarly, the well-mannered cookbook does not hard-code a large data directory onto the root partition. The root drive is the private domain of the operating system; typically, there's a large and comfortably-appointed volume just for it to use. On the other hand, hard-coding a location of `/mnt/external2` will end in tears if I'm testing the cookbook on my laptop, where no such drive exists.

The solution is to request for volumes by their characteristics, and defer to the machine's best effort in meeting that request.

        # Data striped across all persistent dirs
        volume_dirs('foo.datanode.data') do
          type          :persistent, :bulk, :fallback
          selects       :all
          mode          "0700"
        end

        # Scratch space for indexing, striped across all scratch dirs
        volume_dirs('foo.indexer.journal') do
          type          :fast, local, :bulk, :fallback
          selects       :first
          mode          "0755"
        end

Another example of this is binding to a network interface. Unfortunately most cookbooks choose the primary address; most of ours choose the 'private' interface if any and fall back to the primary.

The right pattern here is 
* provisioners tag resources
* cookbooks to request the best match to their purpose
* at the cookbook's option, if no good match is found use a fallback or raise an exception

<a name="resource-sharing"></a>
### Binding declarations enable *Resource Sharing*

Resource sharing is yet another place where an assertive announcement can enable best practices.

Right now, most java-based components hard-code a default JVM heap size. This can lead to a situation where a component shows up on a 16GB machine with 1GB heap allocated, or where five components show up on a 0.7GB machine each with 1GB allocated. 

We instead deserve a deft but highly predictable way to apportion resources (disks, ram, etc). Nothing that gets in the way of explicit tuning, but one which gives a reasonable result in the default case.

The Hadoop cookbook has an initial stab at this, but for the most part Resource Sharing is on the roadmap but not yet in place.


__________________________________________________________________________

### Learn More

[Aspect-Oriented Programming](http://en.wikipedia.org/wiki/Aspect-oriented_programming): The Ironfan concept of `aspects` as cross-cutting concerns is taken from AOP. Amenities don't correspond precisely to join cuts etc., so don't take the analogy too far. (Or perhaps instead help us understand how to take the analogy the rest of the way.)


Ironfan's primary models form a component-based approach to building a  [Service-Oriented Architecture](http://msdn.microsoft.com/en-us/library/aa480021.aspx). Model examples of a modern SOA include the [Netflix API](http://www.slideshare.net/danieljacobson/the-futureofnetflixapi) (see [also](http://techblog.netflix.com/2011/12/making-netflix-api-more-resilient.html)) and [Postrank](http://www.igvita.com/2011/03/08/goliath-non-blocking-ruby-19-web-server/) (see [also](http://www.igvita.com/2010/01/28/cluster-monitoring-with-ganglia-ruby/)).


