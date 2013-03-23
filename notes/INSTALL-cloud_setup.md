## Credentials

* make a credentials repo
  - copy the knife/example-credentials directory
  - best to not live on github: use a private server and run
   
        ``` 
        repo=ORGANIZATION-credentials ; repodir=/gitrepos/$repo.git ; mkdir -p $repodir ; ( GIT_DIR=$repodir git init --shared=group --bare  && cd $repodir && git --bare update-server-info && chmod a+x hooks/post-update ) 
        ```
    
  - git submodule it into knife as `knife/yourorg-credentials`
  - or, if somebody has added it,
  
        ```
        git pull
        git submodule update --init
        find . -iname '*.pem' -exec chmod og-rw {} \;
        cp knife/${OLD_CHEF_ORGANIZATION}-credentials/knife-user-${CHEF_USER}.rb knife/${CHEF_ORGANIZATION}-credentials
        cp knife/${OLD_CHEF_ORGANIZATION}-credentials/${CHEF_USER}.pem knife/${CHEF_ORGANIZATION}-credentials/
        ```
    
* create AWS account
  - [sign up for AWS + credit card + password]
  - make IAM users for admins
  - add your IAM keys into your `{credentials}/knife-user`

* create opscode account
  - download org keys, put in the credentials repo

## Populate Chef Server

* create `prod` and `dev` environments by using 

  ```
  knife environment create dev
  knife environment create prod
  knife environment create stag
  knife environment from file environments/stag.json  
  knife environment from file environments/dev.json
  knife environment from file environments/prod.json
  ```

  ```
  knife cookbook upload --all
  rake roles 
  # if you have data bags, do that too
  ```

## Create Your Initial Machine Boot-Image (AMI)

* Start by launching the burninator cluster: `knife cluster launch --bootstrap --yes burninator-trogdor-0`
  - You may have to specify the template by adding this an anargument: `--template-file ${CHEF_HOMEBASE}/vendor/ironfan/lib/chef/knife/bootstrap/ubuntu10.04-ironfan.erb`
  - This template makes the machine auto-connect to the server upon launch and teleports the client-key into the machine.
  - If this fails, bootstrap separately: `knife cluster bootstrap --yes burninator-trogdor-0`

* Log into the burninator-trogdor and run the script /tmp/burn_ami_prep.sh: `sudo bash /tmp/burn_ami_prep.sh`
  - You will have to ssh as the ubuntu user and pass in the burninator.pem identity file.
  - Review the output of this script and ensure the world we have created is sane.

* Once the script has been run:
  - Exit the machine.
  - Go to AWS console.
  - DO NOT stop the machine.
  - Do "Create Image (EBS AMI)" from the burninator-trogdor instance (may take a while).

* Add the AMI id to your `{credentials}/knife-org.rb` in the `ec2_image_info.merge!` section and create a reference name for the image (e.g ironfan-natty).
  - Add that reference name to the burninator-village facet in the burninator.rb cluster definition: `cloud.image_name 'ironfan_natty'`

* Launch the burninator-village in order to test your newly created AMI.
  - The village should launch with no problems, have the correct permissions and be able to complete a chef run: `sudo chef-client`.
  
* If all has gone well so far, you may now stop the original burninator: `knife cluster kill burninator-trogdor`
  - Leave the burninator-village up and stay ssh'ed to assist with the next step.

## Create an NFS

* Make a command/control cluster definition file with an nfs facet (see clusters/demo_cnc.rb).
  - Make sure specify the `image_name` to be the AMI you've created.

* In the AWS console make yourself a 20GB drive. 
  - Make sure the availability zone matches the one specified in your cnc_cluster definition file. 
  - Don't choose a snapshot. 
  - Set the device name to `/dev/sdh`.
  - Attach to the burninator-village instance.

* ssh in to burninator-village to format the nfs drive:
```
  dev=/dev/xvdh ; name='home_drive' ; sudo umount $dev ; ls -l $dev ; sudo mkfs.xfs $dev ; sudo mkdir /mnt/$name ; sudo mount -t xfs $dev /mnt/$name ; sudo bash -c "echo 'snapshot for $name burned on `date`' > /mnt/$name/vol_info.txt "
  sudo cp -rp /home/ubuntu /mnt/$name/ubuntu
  sudo umount /dev/xvdh
  exit
```
* Back in the AWS console, snapshot the volume and name it `{org}-home_drive`. Delete the original volume as it is not needed anymore.
  - While you're in there, make `{org}-resizable_1gb` a 'Minimum-sized snapshot, resizable -- use `xfs_growfs` to resize after launch' snapshot.
  
* Paste the snapshot id into your cnc_cluster definition file. 
  - ssh into the newly launched cnc_cluster-nfs.
  - You should restart the machine via the AWS console (may or may not be necessary, do anyway).

* Manipulate security groups
  - `nfs_server` group should open all UDP ports and all TCP ports to `nfs_client` group

* Change /etc/ssh/sshd_config to be passwordful and restart the ssh service
