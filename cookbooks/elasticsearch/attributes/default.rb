
default[:elasticsearch][:realm]            = node[:cluster_name]

#
# Locations
#

default[:elasticsearch][:home_dir]                = "/usr/local/share/elasticsearch"
default[:elasticsearch][:conf_dir]                = "/etc/elasticsearch"
default[:elasticsearch][:log_dir]                 = "/var/log/elasticsearch"
default[:elasticsearch][:lib_dir]                 = "/var/lib/elasticsearch"
default[:elasticsearch][:pid_dir]                 = "/var/run/elasticsearch"
#
default[:elasticsearch][:data_root]               = "/mnt/elasticsearch"

#
# User
#

default[:elasticsearch ][:user]                   = 'elasticsearch'
default[:users ]['elasticsearch'][:uid]           = 61021
default[:groups]['elasticsearch'][:gid]           = 61021

#
# Install
#

default[:elasticsearch][:version]                 = "0.19.8"
default[:elasticsearch][:release_url_checksum]    = nil
default[:elasticsearch][:release_url]             = "http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-:version:.tar.gz"
default[:elasticsearch][:snapshot]                = false
default[:elasticsearch][:git_repo]                = "https://github.com/elasticsearch/elasticsearch.git"
default[:elasticsearch][:plugins]                 = ["elasticsearch/elasticsearch-cloud-aws/1.8.0"]

#
# Services
#
default[:elasticsearch][:server][:run_state]      = :start
default[:elasticsearch][:server][:start_wait]     = 60  # seconds to wait before failing on a (re)start

# set true to be a data esnode (stores, indexes data)
default[:elasticsearch][:is_datanode]             = false # set to true in elasticsearch_datanode role
# set true to be a query esnode (has http interface, dispatches/gathers queries)
default[:elasticsearch][:is_httpnode]             = false # set to true in elasticsearch_httpnode role

#
# Tunables
#

default[:elasticsearch][:java_home]               = "/usr/lib/jvm/java-6-sun/jre"     # sun java works way better for ES
default[:elasticsearch][:java_heap_size_max]      = 1000 # a NUMBER -- will be suffixed with 'm'
default[:elasticsearch][:java_heap_newgen]        = nil  # JVM MaxNewSize (expert-level) a NUMBER -- will be suffixed with 'm'
default[:elasticsearch][:ulimit_mlock]            = nil  # locked memory limit -- set to unlimited to lock heap into memory on linux machines

default[:elasticsearch][:default_replicas]        = 1    # replicas are in addition to the original, so 1 replica means 2 copies of each shard
default[:elasticsearch][:default_shards]          = 12   # 12 shards per index * 2 replicas distributes evenly across 2, 3, 4, 6, 8, 12 or 24 nodes
default[:elasticsearch][:flush_threshold]         = 5000
default[:elasticsearch][:cache_filter_size]       = "20%"  # can be a percent ("10%") or a number ("128m")
default[:elasticsearch][:index_buffer_size]       = "10%"  # can be a percent ("10%") or a number ("128m") (changed 2012-10 to default 10%, same as es default)
default[:elasticsearch][:merge_factor]            = 4
default[:elasticsearch][:max_thread_count]        = nil    # Maximum value given that max_thread_count must be < max_merge_count (changed 2012-10 to default nil)
default[:elasticsearch][:term_index_interval]     = 1024
default[:elasticsearch][:refresh_interval]        = "1s"
default[:elasticsearch][:snapshot_interval]       = "10s"
default[:elasticsearch][:snapshot_on_close]       = "true"

default[:elasticsearch][:seeds]                   = nil

default[:elasticsearch][:recovery_after_nodes]    = 2
default[:elasticsearch][:recovery_after_time]     = '5m'
default[:elasticsearch][:expected_nodes]          = 2

default[:elasticsearch][:fd_ping_interval]        = "2s"
default[:elasticsearch][:fd_ping_timeout]         = "60s"
default[:elasticsearch][:fd_ping_retries]         = 6

default[:elasticsearch][:http_ports]              = "9200-9300"
default[:elasticsearch][:api_port]                = "9300"
default[:elasticsearch][:jmx_dash_port]           = '9400-9500'
default[:elasticsearch][:proxy_port]              = "8200"
default[:elasticsearch][:proxy_hostname]          = "elasticsearch.yourdomain.com"

# For use with nginx. Block all ports except this one if using authentication.
default[:elasticsearch][:auth_port]               = "9301"

default[:tuning][:ulimit]['@elasticsearch'] = { :nofile => { :both => 32768 }, :nproc => { :both => 50000 } }

default[:elasticsearch][:gc_logging]              = false  # useful for performance monitoring, but verbose -- watch the disk space

# most of the log lines are manageable at level 'DEBUG'
# the voluminous ones are broken out separately
default[:elasticsearch][:log_level][:default]         = 'DEBUG'

default[:elasticsearch][:log_level][:index_store]     = 'INFO'
default[:elasticsearch][:log_level][:action_shard]    = 'INFO'
default[:elasticsearch][:log_level][:cluster_service] = 'INFO'
default[:elasticsearch][:log_level][:gateway]         = 'INFO' # spews information on every snapshot
