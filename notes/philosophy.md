## Philosophy

Some general principles of how we use Chef.

* *Chef server is never the repository of truth* -- it only mirrors the truth. A file is tangible and immediate to access.
* Specifically, we want truth to live in the git repo, and be enforced by the Chef server.  This means that everything is versioned, documented and exchangeable. *There is no truth but git, and Chef is its messenger*.
* *Systems, services and significant modifications cluster should be obvious from the `clusters` file*.  I don't want to have to bounce around nine different files to find out which thing installed a redis:server. The existence of anything that opens a port should be obvious when I look at the cluster file.
* *Roles define systems, clusters assemble systems into a machine*.
  - For example, a resque worker queue has a redis, a webserver and some config files -- your cluster should invoke a @whatever_queue@ role, and the @whatever_queue@ role should include recipes for the component services.
  - the existence of anything that opens a port _or_ runs as a service should be obvious when I look at the roles file.
* *include_recipe considered harmful* Do NOT use include_recipe for anything that a) provides a service, b) launches a daemon or c) is interesting in any way. (so: @include_recipe java@ yes; @include_recipe iptables@ no.) You should note the dependency in the metadata.rb. This seems weird, but the breaking behavior is purposeful: it makes you explicitly state all dependencies.
* It's nice when *machines are in full control of their destiny*. Their initial setup (elastic IP, attaching a drive) is often best enforced externally. However, machines should be able independently assert things like load balancer registration which may change at any point in their lifetime.
* It's even nicer, though, to have *full idempotency from the command line*: I can at any time push truth from the git repo to the Chef server and know that it will take hold.
