# Named Cloud Objects

To add a new machine image, place this snippet:

    Chef::Config[:ec2_image_info] ||= {}
    Chef::Config[:ec2_image_info].merge!({
      # ... lines like this:
      # %w[ us-west-1 64-bit ebs natty ] => { :image_id => 'ami-4d580408' },
    })

in your knife.rb or whereever. ironfan will notice that it exists and add to it, rather than clobbering it.
