FIXME: Repurpose general structure to demonstrate a Hadoop cluster.

## Walkthrough: Hadoop Cluster

Here's a very simple cluster:

```ruby
Ironfan.cluster 'hadoop_demo' do
  cloud(:ec2) do
    flavor              't1.micro'
  end

  role                  :base_role
  role                  :chef_client
  role                  :ssh

  # The database server
  facet :dbnode do
    instances           1
    role                :mysql_server

    cloud do
      flavor           'm1.large'
      backing          'ebs'
    end
  end

  # A throwaway facet for development.
  facet :webnode do
    instances           2
    role                :nginx_server
    role                :awesome_webapp
  end
end
```

This code defines a cluster named hadoop_demo. A cluster is a group of servers united around a common purpose, in this case to serve a scalable web application.

The hadoop_demo cluster has two 'facets' -- dbnode and webnode. A facet is a subgroup of interchangeable servers that provide a logical set of systems: in this case, the systems that store the website's data and those that render it.

The dbnode facet has one server, which will be named `hadoop_demo-dbnode-0`; the webnode facet has two servers, `hadoop_demo-webnode-0` and `hadoop_demo-webnode-1`.

Each server inherits the appropriate behaviors from its facet and cluster. All the servers in this cluster have the `base_role`, `chef_client` and `ssh` roles. The dbnode machines additionally house a MySQL server, while the webnodes have an nginx reverse proxy for the custom `hadoop_demo_webapp`.

As you can see, the dbnode facet asks for a different flavor of machine (`m1.large`) than the cluster default (`t1.micro`). Settings in the facet override those in the server, and settings in the server override those of its facet. You economically describe only what's significant about each machine.

### Cluster-level tools

```
$ knife cluster show hadoop_demo

+---------------------+-------+------------+-------------+--------------+---------------+-----------------+----------+--------------+------------+------------+
| Name                | Chef? | InstanceID | State       | Public IP    | Private IP    | Created At      | Flavor   | Image        | AZ         | SSH Key    |
+---------------------+-------+------------+-------------+--------------+---------------+-----------------+----------+--------------+------------+------------+
| hadoop_demo-dbnode-0   | yes   | i-43c60e20 | running     | 107.22.6.104 | 10.88.112.201 | 20111029-204156 | t1.micro | ami-cef405a7 | us-east-1a | hadoop_demo   |
| hadoop_demo-webnode-0  | yes   | i-1233aef1 | running     | 102.99.3.123 | 10.88.112.123 | 20111029-204156 | t1.micro | ami-cef405a7 | us-east-1a | hadoop_demo   |
| hadoop_demo-webnode-1  | yes   | i-0986423b | not running |              |               |                 |          |              |            |            |
+---------------------+-------+------------+-------------+--------------+---------------+-----------------+----------+--------------+------------+------------+

```

The commands available are:

* list -- lists known clusters
* show -- show the named servers
* launch -- launch server
* bootstrap  
* sync       
* ssh        
* start/stop       
* kill       
* kick -- trigger a chef-client run on each named machine, tailing the logs until the run completes


### Advanced clusters remain simple

Let's say that app is truly awesome, and the features and demand increases. This cluster adds an [ElasticSearch server](http://elasticsearch.org) for searching, a haproxy loadbalancer, and spreads the webnodes across two availability zones.

```ruby
Ironfan.cluster 'hadoop_demo' do
  cloud(:ec2) do
    image_name          "maverick"
    flavor              "t1.micro"
    availability_zones  ['us-east-1a']
  end

  # The database server
  facet :dbnode do
    instances           1
    role                :mysql_server
    cloud do
      flavor           'm1.large'
      backing          'ebs'
    end

    volume(:data) do
      size              20
      keep              true                        
      device            '/dev/sdi'                  
      mount_point       '/data'              
      snapshot_id       'snap-a10234f'             
      attachable        :ebs
    end
  end

  facet :webnode do
    instances           6
    cloud.availability_zones  ['us-east-1a', 'us-east-1b']

    role                :nginx_server
    role                :awesome_webapp
    role                :elasticsearch_client

    volume(:server_logs) do
      size              5                           
      keep              true                        
      device            '/dev/sdi'                  
      mount_point       '/server_logs'              
      snapshot_id       'snap-d9c1edb1'             
    end
  end

  facet :esnode do
    instances           1
    role                "elasticsearch_data_esnode"
    role                "elasticsearch_http_esnode"
    cloud.flavor        "m1.large"
  end

  facet :loadbalancer do
    instances           1
    role                "haproxy"
    cloud.flavor        "m1.xlarge"
    elastic_ip          "128.69.69.23"
  end
  
  cluster_role.override_attributes({
    :elasticsearch => {
      :version => '0.17.8',
    },
  })
end
```

The facets are described and scale independently. If you'd like to add more webnodes, just increase the instance count. If a machine misbehaves, just terminate it. Running `knife cluster launch hadoop_demo webnode` will note which machines are missing, and launch and configure them appropriately.

Ironfan speaks naturally to both Chef and your cloud provider. The esnode's `cluster_role.override_attributes` statement will be synchronized to the chef server, pinning the elasticsearch version across the server and clients. Your chef roles should focus on specific subsystems; the cluster file lets you see the architecture as a whole.

With these simple settings, if you have already [set up chef's knife to launch cloud servers](http://wiki.opscode.com/display/chef/Launch+Cloud+Instances+with+Knife), typing `knife cluster launch hadoop_demo --bootstrap` will (using Amazon EC2 as an example):

* Synchronize to the chef server:
  - create chef roles on the server for the cluster and each facet.
  - apply role directives (eg the homebase's `default_attributes` declaration).
  - create a node for each machine
  - apply the runlist to each node 
* Set up security isolation:
  - uses a keypair (login ssh key) isolated to that cluster
  - Recognizes the `ssh` role, and add a security group `ssh` that by default opens port 22.
  - Recognize the `nfs_server` role, and adds security groups `nfs_server` and `nfs_client`
  - Authorizes the `nfs_server` to accept connections from all `nfs_client`s. Machines in other clusters that you mark as `nfs_client`s can connect to the NFS server, but are not automatically granted any other access to the machines in this cluster. Ironfan's opinionated behavior is about more than saving you effort -- tying this behavior to the chef role means you can't screw it up. 
* Launches the machines in parallel:
  - using the image name and the availability zone, it determines the appropriate region, image ID, and other implied behavior. 
  - passes a JSON-encoded user_data hash specifying the machine's chef `node_name` and client key. An appropriately-configured machine image will need no further bootstrapping -- it will connect to the chef server with the appropriate identity and proceed completely unattended.
* Syncronizes to the cloud provider:
  - Applies EC2 tags to the machine, making your console intelligible: ![AWS Console screenshot](https://github.com/infochimps-labs/ironfan/raw/version_3/notes/aws_console_screenshot.jpg)
  - Connects external (EBS) volumes, if any, to the correct mount point -- it uses (and applies) tags to the volumes, so they know which machine to adhere to. If you've manually added volumes, just make sure they're defined correctly in your cluster file and run `knife cluster sync {cluster_name}`; it will paint them with the correct tags.
  - Associates an elastic IP, if any, to the machine
* Bootstraps the machine using knife bootstrap
