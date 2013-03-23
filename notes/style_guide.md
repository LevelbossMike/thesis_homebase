# Ironfan + Chef Style Guide

------------------------------------------------------------------------

### System+Component define Names

Name things uniformly for their system and component. For the ganglia master,

* attributes:  `node[:ganglia][:master]`
* recipe:      `ganglia::master`
* role:        `ganglia_master` 
* directories: `ganglia/master` (if specific to component), `ganglia` (if not).
  - for example: `/var/log/ganglia/master`

### Component names

* `agent.rb`
* `worker.rb`
* `datanode.rb`
* `webnode.rb`


### Recipes

Recipes partition these things:

* shared functionality between components
* proper event order
* optional or platform-specific functionality

* Within the foo cookbook, name your recipes like this:
  - `default.rb`      -- information shared by anyone using foo, including support packages, users and directories.
  - `user.rb`         -- define daemon users. Called 'user' even if there is more than one. It's OK to move this into the default cookbook.
  - `install_from_X.rb` -- install packages (`install_from_package`), versioned tarballs (`install_from_release`). It's OK to move this into `default.rb`.
  - `deploy.rb`       -- use this when doing sha-versioned deploys.
  - `plugins.rb`      -- install additional plugins or support code. If you have separate plugins, name them `git_plugin`, `rspec_plugin`, etc. 
  - `server.rb`       -- define the foo server process. Similarly, `agent`, `worker`, etc -- see component naming above.
  - `client.rb`       -- install libraries to *use* the foo service.
  - `config_files.rb` -- discover other components, write final configuration to disk
  - `finalize.rb`     -- final cleanup

* Do not repeat the cookbook name in a recipe title: `ganglia::master`, not `ganglia::ganglia_master`.
* Use only `[a-z0-9_]` for cookbook and component names. Do not use capital letters or hyphens.
* Keep names short and descriptive (preferably 15 characters or less, or it jacks with the Chef webui).

* Always include a `default.rb` recipe, even if it is blank. 
* *DO NOT* use the default cookbook to install daemons or do anything interesting at all, even if that's currently the only thing the recipe does. I want to be able to refer to the attributes in the apache cookbook without launching the apache service. Think of it like a C header file.

A `client` is also passive -- it lets me *use* the system without requiring that I run it. This means the client recipe should *never* launch a process (chef_client` and `nfs_client` components are allowed exceptions). 

### Cookbook Dependencies

* Dependencies should be announced in metadata.rb, of course.
* Explicitly `include_recipe` for system resources -- `runit`, `java`, `silverware`, `thrift` and `apt`.
  - never 
* *DO NOT* use `include_recipe` unless putting it in the role would be utterly un-interesting. You *want* the run to break unless it's explicitly included in the role. 
  - *yes*: `java`, `ruby`, `announces`, etc.
  - *no*:  `zookeeper::client`, `nfs::server`, or anything that will start a daemon
  Remember: ordinary cookbooks describe systems, roles and integration cookbooks coordinate them.
* `include_recipe` statements should only appear in recipes that are entry points. Recipes that are not meant to be called directly should assume their dependencies have been met.
* If a recipe is meant to be the primary entrypoint, it *should* include default, and it should do so explicitly: `include_recipe 'foo::default'` (not just 'foo'). 

Crisply separate cookbook-wide concerns from component concerns. 
  
Separate system configuration from multi-system integration. Cookbooks should provide hooks that are neighborly but not exhibitionist, and otherwise mind their own business. 

### Templates

*DO NOT* refer to attributes directly on the node (`node[:foo]`). This prevents people from using those templates outside the cookbook. Instead:

```ruby
    # in recipe
    template 'fooconf.yml' do 
      variables :foo => node[:foo]
    end
    
    # in template
    @node[:log_dir]
```    

### Attributes
 
* Scope concerns by *cookbook* or *cookbook and component*. `node[:hadoop]` holds cookbook-wide concerns, `node[:hadoop][:namenode]` holds component-specific concerns.
* Attributes shared by all components sit at cookbook level, and are always named for the cookbook: `node[:hadoop][:log_dir]` (since it is shared by all its components).
* Component-specific attributes sit at component level (`node[:cookbook_name][:component_name]`): eg `node[:hadoop][:namenode][:service_state]`. Do not use a prefix (NO: `node[:hadoop][:namenode_handler_count]`)

* Refer to node attributes by symbol, never by method:
  - `node[:ganglia][:log_dir]`, not `node.ganglia.log_dir` or `node['ganglia']['log_dir']

#### Attribute Files

* The main attribute file should be named `attributes/default.rb`. Do not name the file after the cookbook, or anything else.
* If there are a sizeable number of tunable attributes (hadoop, cassandra), place them in `attributes/tuneables.rb`.

## Name Attributes for their aspects

Attributes should be named for their aspect: `port`, `log`, etc. Use generic names if there is only one attribute for an aspect, prefixed names if there are many:
  - For a component that only opens one port: `node[:foo][:server][:port]`
  - More than one port, use a prefix: `node[:foo][:server][:dash_port]` and `node[:foo][:server][:rpc_port]`.

Sometimes the conventions below are inappropriate. All we ask is in those cases that you *not* use the special magic name. For example, don't use `:port` and give it a comma-separated string; name it something else, like `:port_list`.

Here are specific conventions:

### File and Dir Aspects

A *file* is the full directory and basename for a file. A *dir* is a directory whose contents correspond to a single concern. A *prefix* not intended to be used directly -- it will be decorated with suffixes to form dirs and files. A *basename* is only the leaf part of a file reference. Don't use the terms 'path' or 'filename'.

Ignore the temptation to make a one-true-home-for-my-system, or to fight the package maintainer's choices. (FIXME: Rewrite to encourage OS-correct naming schemas.)
- a sandbox holding dir, pid, log, ...

#### Application

* **prefix**: A container with directories bin, lib, share, src, to use according to convention
  - default: `/usr/local`.
* **home_dir**: Logical location for the cookbook's system code.
  - default: typically, leave it up to the package maintainer. Otherwise, `:prefix/share/:cookbook` should be a symlink to the `install_dir` (see below).
  - instead of:         `xx_home` / `dir` alone / `install_dir`
* **install_dir**: The cookbook's system code, in case the home dir is a pointer to potential alternates.
  - default: `:prefix/share/:cookbook-:version` ( you don't need the directory after the cookbook runs, use `:prefix/share/:cookbook-:version` instead, eg `/usr/local/src/tokyo_tyrant-xx.xx`)
  - Make `home_dir` a symlink to this directory (eg home_dir `/usr/local/share/elasticsearch` links to install_dir `/usr/local/share/elasticsearch-0.17.8`).
* **src_dir**: holds the compressed tarball, its expanded contents, and the compiled files when installing from source. Use this when you will run `make install` or equivalent and use the files elsewhere.
  - default:            `:prefix/src/:system_name-:version`, eg `/usr/local/src/pig-0.9.tar.gz`
  - do not:             expand the tarball to `:prefix/src/(whatever)` if it will actually be used from there; instead, use the `install_dir` convention described above. (As a guideline, I should be able to blow away `/usr/local/src` and everything still works).
* **deploy_dir**: deployed code that follows the capistrano convention. See more about deploy variables below.
  - the `:deploy_dir/shared` directory holds common files
  - releases are checked out to `:deploy_dir/releases/{sha}`
  - the operational release is a symlink to the right release: `:deploy_dir/current -> :deploy_dir/releases/xxx`.
  - do not:             use this when you mean `home_dir`.

* **scratch_roots**, **persistent_roots**: an array of directories spread across volumes, with expectations on persistence
  - `scratch_root`s have no guarantee of persistence -- for example, stop/start'ing a machine on EC2 destroys the contents of its local (ephemeral) drives. `persistent_root`s have the *best available* promise of persistance: if permanent (eg EBS) volumes are available, they will exclusively populate the `persistent_root`s; but if not, the ephemeral drives are used instead.
  - these attributes are provided by the `mountable_volume` meta-cookbook and its appropriate integration recipe. Ordinary cookbooks should always trust the integration cookbook's choices (or visit the integration cookbook to correct them).
  - each element in `persistent_roots` is by contract on a separate volume, and similarly each of the `scratch_roots` is on a separate volume. A volume *may* be in both scratch and persistent (for example, there may be only one volume!).
  - the singular forms  **scratch_root** and **persistent_root** are provided for your convenience and always correspond to `scratch_roots.first` and `persistent_roots.first`. This means lots the first named volume is picked on the heaviest -- if you don't like that, choose explicitly (but not randomly, or you won't be idempotent).


* **log_file**, **log_dir**, **xx_log_file**, **xx_log_dir**:
  - default:        
    - if the log files will always be trivial in size, put them in `/var/log/:cookbook.log` or `/var/log/:cookbook/(whatever)`.
    - if it's a runit-managed service, leave them in `/etc/sv/:cookbook-:component/log/main/current`, and make a symlink from `/var/log/:cookbook-component` to `/etc/sv/:cookbook-:component/log/main/`.
    - If the log files are non-trivial in size, set log dir `/:scratch_root/:cookbook/log/`, and symlink `/var/log/:cookbook/` to it. 
    - If the log files should be persisted, place them in `/:persistent_root/:cookbook/log`, and symlink `/var/log/:cookbook/` to it. 
    - in all cases, the directory is named `.../log`, not `.../logs`. Never put things in `/tmp`.
    - Use the physical location for the `log_dir` attribute, not the /var/log symlink.
* **tmp_dir**:   
  - default:            `/:scratch_root/:cookbook/tmp/`
  - Do not put a symlink or directory in `/tmp` -- something else blows it away, the app recreates it as a physical directory, `/tmp` overflows, pagers go off, sadness spreads throughout the land.
* **conf_dir**: 
  - default:            `/etc/:cookbook`
* **bin_dir**:
  - default:            `/:home_dir/bin`
* **pid_file**, **pid_dir**: 
  - default:            pid_file: `/var/run/:cookbook.pid` or `/var/run/:cookbook/:component.pid`; pid_dir: `/var/run/:cookbook/`
  - instead of:         `job_dir`, `job_file`, `pidfile`, `run_dir`.
* **cache_dir**: 
  - default:            `/var/cache/:cookbook`.

* **data_dir**:
  - default:            `:persistent_root/:cookbook/:component/data`
  - instead of:         `datadir, `dbfile`, `dbdir`
* **journal_dir**: high-speed local storage for commitlogs and so forth. Can be deleted, though you may rather it wasn't.
  - default:            `:scratch_root/:cookbook/:component/scratch`
  - instead of:         `commitlog_dir`  

### Daemon Aspects

* **daemon_name**:      daemon's actual service name, if it differs from the component. For example, the `hadoop-namenode` component's daemon is `hadoop-0.20-namenode` as installed by apt.
* **daemon_states**:    an array of the verbs acceptable to the Chef `service` resource: `:enable`, `:start`, etc.
* **num_xx_processes**, **num_xx_threads** the number of separate top-level processes (distinct PIDs) or internal threads to run
  - instead of          `num_workers`, `num_servers`, `worker_processes`, `foo_threads`.
* **log_level**
  - application-specific; often takes values info, debug, warn
  - instead of          `verbose`, `verbosity`, `loglevel`
* **user**, **group**, **uid**, **gid** -- `user` is the user name.  The `user` and `group` should be strings, even the `uid` and `gid` should be integers.
  - instead of          username, group_name, using uid for user name or vice versa.
  - if there are multiple users, use a prefix: `launcher_user` and `observer_user`.

### Install / Deploy Aspects

* **release_url**:      URL for the release.
  - instead of:         install_url, package_url, being careless about partial vs whole URLs
* **release_file**:     Where to put the release.
  - default:            `:prefix/src/system_name-version.ext`, eg `/usr/local/src/elasticsearch-0.17.8.tar.bz2`. 
  - do not use `/tmp` -- let me decide when to blow it away (and make it easy to be idempotent).
  - do not use a non-versioned URL or file name.
* **release_file_sha** or **release_file_md5** fingerprint
  - instead of:         `whatever_checksum`, `whatever_fingerprint`
* **version**:          if it's a simply-versioned resource that uses the `major.minor.patch-cruft` convention. Do not use unless this is true, and do not use the source control revision ID.

* **plugins**:          array of system-specific plugins

use `deploy_{}` for anything that would be true whatever SCM you're using; use `git_{}` (and so forth) where specific to that repo.

* **deploy_env**        production / staging / etc
* **deploy_strategy**   
* **deploy_user**       user to run as
* **deploy_dir**:       Only use `deploy_dir` if you are following the capistrano convention: see above.

* **git_repo**:  url for the repo, eg `git@github.com:infochimps-labs/ironfan.git` or `http://github.com/infochimps-labs/ironfan.git`
  - instead of:         `deploy_repo`, `git_url`
* **git_revision**:  SHA or branch
  - instead of:         `deploy_revision`

* **apt/(repo_name)**   Options for adding a cookbook's apt repo.
  - Note that this is filed under *apt*, not the cookbook.
  - Use the best name for the repo, which is not necessarily the cookbook's name: eg `apt/cloudera/{...}`, which is shared by hadoop, flume, pig, and so on.
  - `apt/{repo_name}/url` -- eg `http://archive.cloudera.com/debian`
  - `apt/{repo_name}/key` -- GPG key
  - `apt/{repo_name}/force_distro` -- forces the distro (eg, you are on natty but the apt repo only has maverick)

### Ports 

* **xx_port**:
  - *do not* use 'port' on its own.
  - examples: `thrift_port`, `webui_port`, `zookeeper_port`, `carbon_port` and `whisper_port`.
  - xx_port: `default[:foo][:server][:port] =  5000`
  - xx_ports, if an array: `default[:foo][:server][:ports] = [5000, 5001, 5002]` 

* **addr**, **xx_addr**
  - if all ports bind to the same interface, use `addr`. Otherwise, do *not* use `addr`, and use a unique `foo_addr` for each `foo_port`.
  - instead of:         `hostname`, `binding`, `address`

* Want some way to announce my port is http or https.
* Need to distinguish client ports from service ports. You should be using cluster service discovery anyway though.

### Application Integration

* **jmx_port**

### Tunables

* **XX_heap_max**, **xx_heap_min**, **java_heap_eden**
* **java_home** 
* AVOID batch declaration of options (e.g. **java_opts**) if possible: assemble it in your recipe from intelligible attribute names.

### Nitpicks

* Always put file modes in quote marks: `mode "0664"` not `mode 0664`.

## Announcing Aspects 

If your app does any of the following, 

* **services**    -- Any interesting long-running process.
* **ports**       -- Any reserved open application port
  - *http*:          HTTP application port
  - *https*:         HTTPS application port
  - *internal*:      port is on private IP, should *not* be visible through public IP
  - *external*:      port *is* available through public IP
* metric_ports:
  - **jmx_ports** -- JMX diagnostic port (announced by many Java apps)
* **dashboards**  -- Web interface to look inside a system; typically internal-facing only, and probably not performance-monitored by default.
* **logs**        -- um, logs. You can also announce the logs' flavor: `:apache`, `log4j`, etc.
* **scheduleds**  -- regularly-occurring events that leave a trace
* **exports**     -- jars or libs that other programs may wish to incorporate
* **consumes**    -- placed there by any call to `discover`.

## Clusters

* Describe physical configuration:
  - machine size, number of instances per facet, etc
  - external assets (elastic IP, ebs volumes)
* Describe high-level assembly of systems via roles: `hadoop_namenode`, `nfs_client`, `ganglia_agent`, etc.
* Describe important modifications, such as `ironfan::system_internals`, mounts ebs volumes, etc
* Describe override attributes:
  - `heap size`, rvm versions, etc.

* roles and recipes 
  - remove `cluster_role` and `facet_role` if empty
  - are not in `run_list`, but populated by the `role` and `recipe` directives
* remove big_package unless it's a dev machine (sandbox, etc)

## Roles

Roles define the high-level assembly of recipes into systems

* override attributes go into the cluster.
currently, those files are typically empty and are badly cluttering the roles/ directory.
the cluster and facet override attributes should be together, not scattered in different files.
roles shouldn't assemble systems. The contents of the infochimps_chef/roles/plato_truth.rb file belong in a facet.

* Deprecated: 
  - Cluster and facet roles (`roles/gibbon_cluster.rb`, `roles/gibbon_namenode.rb`, etc) go away
  - Roles should be service-oriented: `hadoop_master` considered harmful, you should explicitly enumerate the services


### Facets should be (nearly) identical

Within a facet, keep your servers almost entirely identical. For example, servers in a MySQL facet would their index to set shard order and to claim the right attached volumes. However, it would be a mistake to have one server within a facet be a master process and the rest be worker processes -- just define different facets for each. 

### Pedantic Distinctions:

Separate the following terms:

* A *machine* is a concrete thing that runs your code -- it might be a VM or raw metal, but it has CPUs and fans and a finite lifetime. It has a unique name tied to its physical presence -- something like 'i-123abcd' or 'rack 4 server 7'.
* A *chef node* is the code object that, together with the chef-client process, configures a machine. In ironfan, the chef node is strictly slave to the server description and the measured attributes of the machine.
* A *server description* gives the high-level specification the machine should acheive. This includes the roles, recipes and attributes given to the chef node; the physical characteristics of the machine ('8 cores, 7GB ram, AWS cloud'); and its relation to the rest of the system (george cluster, webnode facet, index 3).

In particular, we try to be careful to always call a Chef node a 'chef node' (never just 'node'). Try processing graph nodes in a flume node feeding a node.js decorator on a cloud node define by a chef node. No(de) way.
