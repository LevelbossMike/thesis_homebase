#
# TorqueBox cluster
#
Ironfan.cluster 'torquebox' do
  environment           :dev

  role                  :systemwide
  role                  :ssh

  cloud(:ec2) do
    permanent           false
    availability_zones  ['us-east-1d', 'us-east-1a']
    flavor              'm1.large'
    backing             'ebs'
    image_name          'ironfan-natty'
    chef_client_script  'client.rb'
    security_group(:ssh).authorize_port_range(22..22)
    mount_ephemerals
  end

  facet :backend do
    instances           3

    role                :torquebox_example
  end

  facet :backup do
    instances           1

    role                :torquebox_example
    cloud(:ec2) do
      availability_zones ['us-east-1a']
    end
  end

  facet :frontend do
    instances           1

    role                :mod_cluster
    cloud(:ec2) do
      security_group(:web).authorize_port_range(80..80)
      security_group(:web).authorize_port_range(6666..6666)
      security_group(:web).authorize_port_range(443..443)
    end
  end

  cluster_role.override_attributes({})

  tb_attributes = {
    :torquebox => {
      :version => "2.3.0",
      :url => "http://torquebox.org/release/org/torquebox/torquebox-dist/2.3.0/torquebox-dist-2.3.0-bin.zip",
      :ha_server_config_template => "standalone-ha-2.0.x-incremental.xml.erb",
      :jruby => { :opts => '--1.9' },
      :bind_ip => ["cloud", "local_ipv4"],
      :clustered => true,
      :mod_cluster_mcpm_port => 6666
    }
  }

  # backend / backup servers should behave the same way
  facet(:backend).facet_role.override_attributes(tb_attributes)
  facet(:backup).facet_role.override_attributes(tb_attributes)

  facet(:frontend).facet_role.override_attributes({
    :mod_cluster => {
      :mcpm_bind_ip => ["cloud", "local_ipv4"],
      :mcpm_port => 6666,
      :clustered => true
      }
    })
end
