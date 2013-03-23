# Ironfan Installation Instructions

First of all, every Chef installation needs a Chef Homebase. Chef Homebase is the place where cookbooks, roles, config files and other artifacts for managing systems with Chef will live. Store this homebase in a version control system such as Git and treat it like source code.

## Conventions

In all of the below,

* `{homebase}`: is the directory that holds your Chef cookbooks, roles and so forth. For example, this file is in `{homebase}/README.md`.
* `{username}`: identifies your personal Chef client name: the thing you use to log into the Chef WebUI.
* `{organization}`: identifies the credentials set and cloud settings to use.  If your Chef server is on the Opscode platform (Try it! It's super-easy), use your organization name (the last segment of your chef_server url). If not, use an identifier you deem sensible.

<a name="initial_install"></a>
## Install Ironfan's Gem and Homebase

_Before you begin, you may wish to fork homebase repo, as you'll be making changes to personalize it for your platform that you may want to share with teammates. If you do so, replace all references to infochimps-labs/ironfan-homebase with your fork's path._

1. Install system prerequisites (libXML and libXSLT). The following works under Debian/Ubuntu:

        sudo apt-get install libxml2-dev libxslt1-dev

1. Install the Ironfan gem (you may need to use `sudo`):

        gem install ironfan

1. Clone the repo. It will produce the directory we will call `homebase` from now on:

        git clone https://github.com/infochimps-labs/ironfan-homebase homebase
        cd homebase
        bundle install
        git submodule update --init
        git submodule foreach git checkout master

<a name="knife-configuration"></a>
## Configure Knife and Add Credentials

Ironfan expands out the traditional singular [knife.rb](http://wiki.opscode.com/display/chef/Knife#Knife-ConfiguringYourSystemForKnife) into several components. This modularity allows for better management of sensitive shared credentials, personal credentials, and organization-wide configuration.

### Set up 

_Note_: If your local username differs from your Opscode Chef username, then you should `export CHEF_USER={username}` (eg from your `.bashrc`) before you run any knife commands.

So that Knife finds its configuration files, symlink the `{homebase}/knife` directory (the one holding this file) to be your `~/.chef` folder.

        cd {homebase} 
        ln -sni $CHEF_HOMEBASE/knife ~/.chef

<a name="credentials"></a>
### Credentials Directory

All the keys and settings specific to your organization are held in a directory named `credentials/`, versioned independently of the homebase.

To set up your credentials directory, visit `{homebase}/knife` and duplicate the example, naming it `credentials`:

        cd $CHEF_HOMEBASE/knife 
        rm credentials
        cp -a example-credentials credentials
        cd credentials
        git init ; git add .
        git commit -m "New credentials universe for $CHEF_ORGANIZATION" .

You will likely want to store the credentials in another remote repository. We recommend erring on the side of caution in its hosting. Setting that up is outside the scope of this guide, but there [good external resources](http://book.git-scm.com/3_distributed_workflows.html) available to get you started.

<a name="download"></a>
### Download Cloud Credentials

You will need to obtain user keys from your cloud providers. Your AWS access keys can be obtained from [Amazon IAM](https://console.aws.amazon.com/iam/home):

![Reset AWS User Key](https://github.com/infochimps-labs/ironfan/wiki/aws_user_key.png)

__________________________________________________________________________

Your Opscode user key can be obtained from the [Opscode Password settings](https://www.opscode.com/account/password) console:

![Reset Opscode User Key](https://github.com/infochimps-labs/ironfan/wiki/opscode_user_key.png)

__________________________________________________________________________

Your Opscode organization validator key can be obtained from the [Opscode Organization management](https://manage.opscode.com/organizations) console, by choosing the `Regenerate validation key` link:

![Reset Opscode Organization Key](https://github.com/infochimps-labs/ironfan/wiki/opscode_org_key.png)

__________________________________________________________________________


<a name="org"></a>
### User / Organization-specific config

Edit the following in your new `credentials`:

* Organization-specific settings are in `knife/credentials/knife-org.rb`:
  - _organization_:          Your organization name 
  - _chef server url_:       Edit the lines for your `chef_server_url` and `validator`. _Note_: If you are an Opscode platform user, you can skip this step -- your `chef_server_url` defaults to `https://api.opscode.com/organizations/#{organization}` and your validator to `{organization}-validator.pem`.
  - Cloud-specific settings: if you are targeting a cloud provider, add account information and configuration here. 

* User-specific settings are in `knife/credentials/knife-user-{username}.rb`. (You can duplicate and rename the one in `knife/example-credentials/knife-user-example.rb`). For example, if you're using Amazon EC2 you should set your access keys:

          Chef::Config.knife[:aws_access_key_id]      = "XXXX"
          Chef::Config.knife[:aws_secret_access_key]  = "XXXX"
          Chef::Config.knife[:aws_account_id]         = "XXXX"
        
* Chef user key is in `{credentials_path}/{username}.pem`

* Organization validator key in `{credentials_path}/{organization}-validator.pem`

* If you have existing Amazon machines, place their keypairs in `{credentials_path}/ec2_keys`. Ironfan will also automatically populate this with new keys as new clusters are created. Commit the resulting keys back to the credentials repo to share them with your teammates, or they will be unable to make certain calls against the resulting architecture.

<a name="go_speed_racer"></a>
## Try it out

You should now be able to use Knife to control your clusters:

        $ knife cluster list
        +--------------------+---------------------------------------------------+ 
        | cluster            | path                                              |
        +--------------------+---------------------------------------------------+
        | burninator         | /cloud/clusters/burninator.rb                     |
        | el_ridiculoso      | /cloud/clusters/el_ridiculoso.rb                  |
        | elasticsearch_demo | /cloud/clusters/elasticsearch_demo.rb             |
        | hadoop_demo        | /cloud/clusters/hadoop_demo.rb                    |
        | sandbox            | /cloud/clusters/sandbox.rb                        |
        +--------------------+---------------------------------------------------+

Launching a cluster in the cloud should now be this easy!

        knife cluster launch sandbox-simple --bootstrap

## Next

The README file in each of the subdirectories for more information about what goes in those directories. If you are bored of reading, go customize one of the files in the 'clusters/ directory'. Or, if you're a fan of ridiculous things and have ever pondered how many things you can fit in one box, launch el_ridiculoso:. It contains every single recipe we have ever made stacked on top of one another.

        knife cluster launch el_ridiculoso-gordo --bootstrap

For more information about configuring Knife, see the [Knife documentation](http://wiki.opscode.com/display/chef/knife).