Ironfan.cluster 'my_first_cluster' do
  # Chef environment that the Chef node will be placed under
  environment :dev

  # comes built into ironfan. It defines certain universal behaviours such as
  # installing ntpd, zsh, and emacs (w00t?!)
  role :systemwide

  # make it possible to ssh into this machine
  role :ssh

  # define behaviours that apply to EC2 resources anywhere in the cluster.
  # cloud(ec2) statements within each facet can be used to augment or override
  # these settings
  cloud(:ec2) do
    permanent            false
    availability_zones   ['us-east-1a', 'us-east-1d']
    flavor               't1.micro'
    backing              'ebs'
    image_name           'ironfan-natty'
    chef_client_script   'client.rb'
    security_group(:ssh).authorize_port_range(22..22)
    mount_ephemerals
  end

  facet :web do
    instances 1
    recipe :apache2

    cloud(:ec2) do
      flavor 'm1.small'

      # add a new security group called 'web'. Only servers in this facet will
      # be added to the group
      security_group(:web) do
        authorize_port_range(80..80)
        authorize_port_range(443..443)
      end
    end
  end

  facet :database do
    instances 1
    role :mysql_server
    recipe 'mysql'
    cloud(:ec2) do
      flavor 'm1.large'
    end
  end
end
