# Cookbook event ordering


Most cookbooks have some set of the following

* base configuration
* announce component
  - before discovery so it can be found
  - currently done in converge stage -- some aspects might be incompletely defined?

* register apt repository if any
* create daemon user
  - before directories so we can set permissions
  - before package install so uid is stable
* install, as package, git deploy or install from release
  - often have to halt legacy services -- config files don't exist
* create any remaining directories 
  - after package install so it has final say
* install plugins
  - after directories, before config files
* define service
  - before config file creation so we can notify
  - can't start it yet because no config files
* discover component (own or other, same or other machines)
* write config files (notify service of changes)
  - must follow everything so info is current
* register a minidash dashboard
* trigger start (or restart) of service

## Proposal:

kill `role`s, in favor of `stack`s.

A runlist is assembled in the following phases:

* `initial` configuration
* `before_install`
  - `account`
* `install`
  - `plugin` install
  - `directories`
* `announcement`
  - `service` definition
- `discovery`
* `commit`
  - `config_files`: write config files to disk
* `finalize`
* `launch`

As you can see, most layers have semantic names (`plugin`, `user`, etc); if you name your recipe correctly, they will be assigned to the correct phase. Otherwise, you can attach them explicitly to a semantic or non-semantic phase.

    elasticsearch_datanode component:
    
    elasticsearch::default              # initial
    elasticsearch::install_from_release #install phase
    elasticsearch::plugins              # plugin phase

    elasticsearch::server               # service definition; includes announcement
    elasticsearch::config_files         # config_files; includes discovery

I'm not clear on how much the phases should be strictly broken out into one-recipe-per-phase.

It's also possible to instead define a chef resource that let you defer a block to a given phase from within a callback. It would be similar to a ruby block, but have more explicit timing. This may involve jacking around inside Chef, something we've avoided to now.

__________________________________________________________________________

Run List is 

    [role[systemwide], role[chef_client], role[ssh], role[nfs_client],
    role[volumes], role[package_set], role[org_base], role[org_users], 
    
    role[hadoop],
    role[hadoop_s3_keys], 
    role[cassandra_server], role[zookeeper_server],
    role[flume_master], role[flume_agent], 
    role[ganglia_master],
    role[ganglia_agent], role[hadoop_namenode], role[hadoop_datanode],
    role[hadoop_jobtracker], role[hadoop_secondarynn], role[hadoop_tasktracker],
    role[hbase_master], role[hbase_regionserver], role[hbase_stargate],
    role[redis_server], role[mysql_client], role[redis_client],
    role[cassandra_client], role[elasticsearch_client], role[jruby], role[pig],
    recipe[ant], recipe[bluepill], recipe[boost], recipe[build-essential],
    recipe[cron], recipe[git], recipe[hive], recipe[java::sun], recipe[jpackage],
    recipe[jruby], recipe[nodejs], recipe[ntp], recipe[openssh], recipe[openssl],
    recipe[rstats], recipe[runit], recipe[thrift], recipe[xfs], recipe[xml],
    recipe[zabbix], recipe[zlib], recipe[apache2], recipe[nginx],
    role[el_ridiculoso_cluster], role[el_ridiculoso_gordo], role[minidash],
    role[org_final], recipe[hadoop_cluster::config_files], role[tuning]]

Run List expands to 

    build-essential, motd, zsh, emacs, ntp, nfs, nfs::client, xfs,
    volumes::mount, volumes::resize, package_set, 
    
    hadoop_cluster,
    hadoop_cluster::minidash, 
    
    cassandra, cassandra::install_from_release,
    cassandra::autoconf, cassandra::server, cassandra::jna_support,
    cassandra::config_files, zookeeper::default, zookeeper::server,
    zookeeper::config_files, flume, flume::master, flume::agent,
    flume::jruby_plugin, flume::hbase_sink_plugin, ganglia, ganglia::server,
    ganglia::monitor, 
    
    hadoop_cluster::namenode, 
    hadoop_cluster::datanode,
    hadoop_cluster::jobtracker, 
    hadoop_cluster::secondarynn,
    hadoop_cluster::tasktracker, 
    
    zookeeper::client, 
    hbase::master,
    hbase::minidash, 
    
    minidash::server, 
    hbase::regionserver, 
    hbase::stargate,
    redis, redis::install_from_release, redis::server, 
    mysql, mysql::client,
    cassandra::client, elasticsearch::default,
    
    elasticsearch::install_from_release, 
    elasticsearch::plugins,
    elasticsearch::client, 
    
    jruby, jruby::gems, 
    
    pig, 
    pig::install_from_package,
    pig::piggybank, 
    pig::integration, 
    
    zookeeper, 
    ant, bluepill, boost, cron,
    git, hive, 
    java::sun, jpackage, nodejs, openssh, openssl, rstats, runit,
    thrift, xml, zabbix, zlib, apache2, nginx, hadoop_cluster::config_files,
    tuning::default
    

From an actual run of el_ridiculoso-gordo:
    
      2 nfs::client
      1 java::sun
      1 aws::default
      5 build-essential::default
      3 motd::default
      2 zsh::default
      1 emacs::default
      8 ntp::default
      1 nfs::default
      2 nfs::client
      3 xfs::default
     46 package_set::default
      4 java::sun
      8 tuning::ubuntu
      6 apt::default
      1 hadoop_cluster::add_cloudera_repo
     44 hadoop_cluster::default
      4 minidash::default
      2 /srv/chef/file_store/cookbooks/minidash/providers/dashboard.rb
      1 hadoop_cluster::minidash
      2 /srv/chef/file_store/cookbooks/minidash/providers/dashboard.rb
      1 boost::default
      2 python::package
      2 python::pip
      1 python::virtualenv
      2 install_from::default
      7 thrift::default
      9 cassandra::default
      1 cassandra::install_from_release
      6 /srv/chef/file_store/cookbooks/install_from/providers/release.rb
      3 cassandra::install_from_release
      1 cassandra::bintools
      3 runit::default
     11 cassandra::server
      2 cassandra::jna_support
      2 cassandra::config_files
      6 zookeeper::default
     15 zookeeper::server
      3 zookeeper::config_files
     18 flume::default
      2 flume::master
      3 flume::agent
      2 flume::jruby_plugin
      1 flume::hbase_sink_plugin
     21 ganglia::server
     20 ganglia::monitor
     13 hadoop_cluster::namenode
     11 hadoop_cluster::datanode
     11 hadoop_cluster::jobtracker
     11 hadoop_cluster::secondarynn
     11 hadoop_cluster::tasktracker
     14 hbase::default
     11 hbase::master
      1 hbase::minidash
      2 /srv/chef/file_store/cookbooks/minidash/providers/dashboard.rb
     13 minidash::server
     11 hbase::regionserver
     10 hbase::stargate
      2 redis::default
      2 redis::install_from_release
      2 redis::default
     16 redis::server
      3 mysql::client
      1 aws::default
      7 elasticsearch::default
      1 elasticsearch::install_from_release
      6 /srv/chef/file_store/cookbooks/install_from/providers/release.rb
      2 elasticsearch::plugins
      3 elasticsearch::client
      3 elasticsearch::config
      1 jruby::default
      9 /srv/chef/file_store/cookbooks/install_from/providers/release.rb
      7 jruby::default
     18 jruby::gems
      2 pig::install_from_package
      5 pig::piggybank
      8 pig::integration
      6 zookeeper::default
      3 ant::default
      5 bluepill::default
      2 cron::default
      1 git::default
      1 hive::default
      2 nodejs::default
      4 openssh::default
      7 rstats::default
      1 xml::default
     11 zabbix::default
      1 zlib::default
     10 apache2::default
      2 apache2::mod_status
      2 apache2::mod_alias
      1 apache2::mod_auth_basic
      1 apache2::mod_authn_file
      1 apache2::mod_authz_default
      1 apache2::mod_authz_groupfile
      1 apache2::mod_authz_host
      1 apache2::mod_authz_user
      2 apache2::mod_autoindex
      2 apache2::mod_dir
      1 apache2::mod_env
      2 apache2::mod_mime
      2 apache2::mod_negotiation
      2 apache2::mod_setenvif
      1 apache2::default
      8 nginx::default
      9 hadoop_cluster::config_files
