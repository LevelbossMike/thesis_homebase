### Set up Knife on your local machine, and a Chef Server in the cloud

If you already have a working chef installation you can skip this section.

To get started with knife and chef, follow the "Chef Quickstart,":http://wiki.opscode.com/display/chef/Quick+Start We use the hosted chef service and are very happy, but there are instructions on the wiki to set up a chef server too. Stop when you get to "Bootstrap the Ubuntu system" -- cluster chef is going to make that much easier.

* [Launch Cloud Instances with Knife](http://wiki.opscode.com/display/chef/Launch+Cloud+Instances+with+Knife)
* [EC2 Bootstrap Fast Start Guide](http://wiki.opscode.com/display/chef/EC2+Bootstrap+Fast+Start+Guide)

### Auto-vivifying machines (no bootstrap required!)

On EC2, you can make a machine that auto-vivifies -- no bootstrap necessary. Burn an AMI that has the `config/client.rb` file in /etc/chef/client.rb. It will use the ec2 userdata (passed in by knife) to realize its purpose in life, its identity, and the chef server to connect to; everything happens automagically from there. No parallel ssh required!

### EBS Volumes

Define a `snapshot_id` for your volumes, and set `create_at_launch` true.
