While the refactoring that lead to version 4 was intended to be as backwards compatible as possible, there have been some small but important changes to the way homebases and the DSL work.

## Bundler
Ironfan v4 uses bundler to manage its dependencies. In order to take advantage of it, the homebase's Gemfile should be updated to use ```gem 'ironfan', "~> 4.0"``` 

We highly recommend that you run all your knife commands via bundle exec. This can be accomplished with an alias:
```
knife() {
  bundle exec knife "$@"
}
```

If you are comfortable with having bundle run every knife command (e.g. - you only have one homebase, or are using a Ironfan > 3.1.6 for all homebases you do use), you can add the above snippet to your .bashrc.

## Vagrant
Vagrant support has been discontinued for the time being. One of the first targets for the multicloud capabilities of Ironfan v4 will be a Virtualbox or Vagrant extension.

## DSL Changes
### Role implications removed
In v3, certain roles could trigger further steps via role_implications.rb, which was used to add servers to corresponding EC2 Security Groups. This was deemed to be too risky and indirect, and has been removed for now. (A better mechanism for binding roles and provider-specific resources into repeatable components is being worked on.)

If you used any of the roles below, you will probably want to add the following stanzas next to them in the clusters file, to replace the removed implications. **Be aware that EC2 instances can only be added to a security group at startup; if you fail to add the security groups before launch, you will have to kill and relaunch the machines to change them.**

* `role :systemwide`
```
cloud(:ec2).security_group :systemwide
```
* `role :nfs_server`
```
cloud(:ec2).security_group(:nfs_server).authorize_group :nfs_client
```
* `role :nfs_client`
```
cloud(:ec2).security_group :nfs_client
```
* `role :ssh`
```
cloud(:ec2).security_group(:ssh).authorize_port_range 22..22
```
* `role :chef_server`
```
cloud(:ec2).security_group :chef_server do
  authorize_port_range 4000..4000  # chef-server-api
  authorize_port_range 4040..4040  # chef-server-webui
end
```
* `role :web_server`
```
cloud(:ec2).security_group("#{self.cluster_name}-web_server") do
  authorize_port_range  80..80
  authorize_port_range 443..443
end
```
* `role :redis_server`
```
cloud(:ec2).security_group("#{self.cluster_name}-redis_server") do
  authorize_group("#{self.cluster_name}-redis_client")
end
```
* `role :redis_client`
```
cloud(:ec2).security_group("#{self.cluster_name}-redis_client")
```

### Default statements removed
Defaults should not need to be selected, and have been removed as a statement from the cluster DSL (in both cluster and volume). Although this is a non-breaking change, it has been flagged to raise a halting error, to alert people to the role_implications change above (which lacks well-defined indicators of its usage).