## Nathan
* **Clusters from JSON** - this is theoretically quite easy, given the DSL's gorillib underpinnings.

## Flip
* **standalone usable**: can use ironfan-knife as a standalone library.

* **spec coverage**: 

* **coherent data model**: 

    ComputeLayer   -- common attributes of Provider, Cluster, Facet, Server
      - overlay_stack of Cloud attributes

    Universe        -- across organizations
    Organization    -- one or many providers
    Provider        -- 
    - has_many  :clusters
    Cluster         --
    - has_many  :providers
    - overlays  :main_provider
    Facet           --
    - has_one  :cluster
    - overlays :cluster
    Server         
    - has_one  :facet
    - overlays :cluster
    - has_one chef_node
    - has_one machine
    
    
    System            Role          Cookbook
    Component                       Cookbook+Recipes
    
     

* **improved discovery**: 

* **config isolation**: 


### Nitpicks


* make bootstrap_distro and image_name follow from os_version

* minidash just publishes announcements
* silverware is always included; it subsumes volumes 

* if you add a `data_dir_for    :hadoop` to 

* volumes should name their `mount_point` after themselves by default

### Components

* components replace roles (they are auto-generated by the component, and tie strictly to it)
* 

### Clusters 

If clusters are more repeatable they won't be so bothersomely multi-provider:
    
    Ironfan.cluster :gibbon do 
      cloud(:ec2) do
        backing         'ebs' 
        permanent       false
      end
      stack             :systemwide
      stack             :devstack
      stack             :monitoring
      stack             :log_handling
      
      component         :hadoop_devstack
      component         :hadoop_dedicated
      
      discovers         :zookeeper, :realm => :zk
      discovers         :hbase,     :realm => :hbase

      facet :master do
        component		:hadoop_namenode
        component		:hadoop_secondarynn
        component		:hadoop_jobtracker
      end
      facet :worker do
        component		:hadoop_datanode
        component		:hadoop_tasktracker
      end
      
      volume :hadoop_data do
        data_dir_for    :hadoop_datanode, :hadoop_namenode, :hadoop_secondarynn
        device          '/dev/sdj1'
        size            100
        keep            true
      end
    end


Here are ideas about how to get there

    # silverware is always included; it subsumes volumes 

    organization :infochimps do
      cloud(:ec2) do
        availability_zones  ['us-east-1d']
        backing             :ebs
        image_name          'ironfan-natty'
        bootstrap_distro    'ironfan-natty'
        chef_client_script  'client.rb'
        permanent           true
      end
      
      volume(:default) do
        keep                true
        snapshot_name       :blank_xfs
        resizable           true
        create_at_launch    true
      end
      
      stack :systemwide do
        system(:chef_client) do
          run_state         :on_restart
        end
        component		    :set_hostname
        component		    :minidash
        component           :org_base
        component           :org_users
        component           :org_final
      end
      
      stack :devstack do
        component		    :ssh
        component		    :nfs_client
        component		    :package_set
      end

      stack :monitoring do
        component		:zabbix_agent
      end
      
      stack :log_handling do
        component		:log_handling
      end
    end
    
    stack :hadoop do
    end
    
    stack :hadoop_devstack do
      component         :pig
      component         :jruby
      component         :rstats
    end
    
    stack :hadoop_dedicated do
      component         :tuning
    end

    system :hadoop do
      stack :hadoop_devstack
      stack :zookeeper_client
      stack :hbase_client
    end   
        
    Ironfan.cluster :gibbon do 
      cloud(:ec2) do
        backing             'ebs' 
        permanent           false
      end
      
      system :systemwide do
        exclude_stack   :monitoring
      end
      
      # how are its components configured? distributed among machines?
      system :hadoop do 
            
        # all servers will
        # * have the `hadoop` role
        # * have run_state => false for components with a daemon aspect by default
        
        facet :master do
          # component :hadoop_namenode means
          # * this facet has the `hadoop_namenode` role
          # * it has the component's security_groups
          # * it sets node[:hadoop][:namenode][:run_state] = true
          # * it will mount the volumes that adhere to this component
          component :hadoop_namenode
        end
        
        # something gains eg zookeeper client if it discovers a zookeeper in another realm
        # zookeeper must explicitly admit it discovers zookeeper, but can do that in the component
        
        # what volumes should it use on those machines?
        # create the volumes, pair it to components
        # if a component is on a server, it adds its volumes. 
        # you can also add them explicitly.
        
        # volume tags are applied automagically from their adherance to components

        volume :hadoop_data do                            # will be assigned to servers with components it lists
          data_dir_for    :hadoop_datanode, :hadoop_namenode, :hadoop_secondarynn
        end

### Providers

I want to be able to:

* on a compute layer, modify its behavior depending on provider:
  - example:
  
      facet(:bob) do 
        cloud do
          security_group  :bob
          authorize       :from => :bobs_friends, :to => :bob
        end
        cloud(:ec2,       :flavor => 'm1.small')
        cloud(:rackspace, :flavor => '2GB')
        cloud(:vagrant,   :ram_mb =>  256 )
      end

  - Any world that understands security groups will endeavor to make a `bob` security group, and authorize the `bobs_friends` group to use it.
  - On EC2 and rackspace, the `flavor` attribute is set explicitly
  - On vagrant (which got no `flavor`), we instead specify how much ram to supply
  - On any other provider the flavor and machine ram will follow defaults.

* see all machines and clusters within an organization


### Organizations

* see the entire universe; this might get hairy, but not ridiculous
  - each org describes its providers; only those are used
  - you don't have to do much to add a provider, just say `provider(:ec2)`
  - you can configure the provider like this:
  
      organization(:infochimps_test, :doc => 'Infochimps test cloud') do
        provider(:vagrant)
        provider(:ec2) do
          access_key         '...' 
          secret_access_key  '...'
        end
        provider(:hp_cloud) do
          access_key         '...'
          secret_access_key  '...'
        end
      end
      
      organization(:demo, :doc => 'Live client demo cloud') do
        provider(:vagrant)
        provider(:ec2)       do  #... end
        provider(:hp_cloud)  do  #... end
        provider(:rackspace) do  #... end
      end

  - clusters can be declared directly or imported from other organizations:
  
      organization :infochimps_test do
        # developers' sandboxes
        cluster  :dev_sandboxes
        # all the example clusters, for development
        organization(:examples).clusters.each do |cl|
          add_cluster cl
        end
      end  

  - if just starting, should see clusters; 
    - per-org cluster dirs
