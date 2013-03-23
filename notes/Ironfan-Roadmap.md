#  Ironfan Roadmap

##  Summary

- I. Ironfan-ci
- II. DSL Undercarriage / OpenStack
- III. Cookbook Updates
- IV. Keys Handling
- V. Silverware Update
- VI. Ironfan Knife
- VII. Orchestration

## Detailed Roadmap

###  Ironfan-CI (I)
Jenkins on laptop (Done) 
Jenkins runs VM sees output of test 
Translate announcement to cucumber lines 
Implement as necessary new Cuken tests 

### Openstack / Multi-cloud (II)
* Learn Openstack
* (get accts @ a couple providers + eucalytus) 
* Fog (library we use, ec2 only?) compatibility with some tear-out
* Depends on DSL Object above
* Move stuff in Fog_layer to be methods on Cloud Object 
* cloud(:ec2, ‘us_east’) do
* cores 1
* end
* Cloud Statement is just a layer, not its own object 
* (Cloud loses to everything else, we think)

### Ironfanize Rest of Cookbooks (III)
* Debugging and updating exercise. 
* Ironfan-ci accelerates
* Zabbix
* MySql
* Map to order of operations
* Clean Separation of tight-bound services
* Resque’s Redis
* Flume’s Zookeeper

### DSL Object / Librarification (Mix)
* New DSL Object (II)
* Unify Models in Silverware/lib & Ironfan/lib (Birth of the Ironfan API Interface) (II)
* Birth of the Ironfan API Interface (V)
* Clean up Announcment Interface (framework) (V)
* Merge Volume (VIII)
* Actual Model for a dummy node (VIII)
* Refactor deploy code across cookbooks (III)
*  Discovers component is an aspect endowed upon a component when it discovers another component to find out what depends on a service  (V)
* Key Databag Rollout (IV)

### Ironfan-knife (VI)
* Separate SSH user as “Machine” or “Me”
* Better Error Messages 
* Verbose vs. Sustained
* Clearout Issues
* Refactor Cluster into definitions - “Stacks” (Roles that are smarter)
* Role Replacement
* (Design doc forthcoming)

### Orchestration (VI/VII)
* System diagram /reporting (VII)
* Ticketed Worker Queue to run steps (bring up a Hadoop cluster, for instance) (VII)
* Rundeck? Juju? (VII)
* Activity stream (VII)
* Helpers (VII)
* API Frontend (VII)
* Richer Slice Queries (VI)