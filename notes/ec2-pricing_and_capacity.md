## Compute Costs


    code         	$/mo	 $/day	 $/hr	Mem/$	CPU/$	  mem 	  cpu 	cores	cpcore	storage	 disks	 bits	ebs-opt	IO
    t1.micro       	  15	  0.48	  .02	   13	   13	  0.61	  0.25	 0.25	  1   	      0	     0	   32		Low
    m1.small       	  58	  1.92	  .08	   21	   13	  1.7 	  1   	 1   	  1   	    160	     1	   32		Moderate
    m1.medium      	 116	  3.84	  .165	   13	   13	  3.75	  2   	 2   	  1   	    410	     1	   32		Moderate
    c1.medium      	 120	  3.96	  .17	   10	   30	  1.7 	  5   	 2   	  2.5 	    350	     1	   32		Moderate
    m1.large       	 232	  7.68	  .32	   23	   13	  7.5 	  4   	 2   	  2   	    850	     2	   64	  500	High
    m2.xlarge      	 327	 10.80	  .45	   38	   14	 17.1 	  6.5 	 2   	  3.25	    420	     1	   64		Moderate
    m1.xlarge      	 465	 15.36	  .64	   23	   13	 15   	  8   	 4   	  2   	   1690	     4	   64	 1000	High
    c1.xlarge      	 479	 15.84	  .66	   11	   30	  7   	 20   	 8   	  2.5 	   1690	     4	   64	 	High
    m2.2xlarge     	 653	 21.60	  .90	   38	   14	 34.2 	 13   	 4   	  3.25	    850	     2	   64		High
    cc1.4xlarge    	 944	 31.20	 1.30	   18	   26	 23   	 33.5 	 2   	 16.75	   1690	     4	   64		10GB
    m2.4xlarge     	1307	 43.20	 1.80	   38	   14	 68.4 	 26   	 8   	  3.25	   1690	     2	   64	 1000	High
    cg1.4xlarge    	1525	 50.40	 2.10	   10	   16	 22   	 33.5 	 2   	 16.75	   1690	     4	   64		10GB
    cc2.8xlarge    	1742	 57.60	 2.40	   25	   37	 60.5 	 88   	 2   	 44   	   3370	     2	   64		10GB
    hi1.4xlarge   	2265	 74.40	 3.10	    	    	 60.5	 35	16	  2.2	   2048	 ssd 2	   64		10GB

    dummy header ln	  15	  0.48	 0.02	12345	12345	  0.61	  0.25	 0.25	  1.00	6712345	 32123	32123	Low


## Storage Costs

                            $/GB..mo		$/GB.mo  	$/Mio
    EBS Volume     			$0.10
    EBS I/O       			            	         	$0.10
    EBS Snapshot S3			$0.083

                         	Std $/GB.mo		Red.Red. $/GB.mo
    S3 1st tb            	$0.125     	 	$0.093
    S3 next 49tb         	$0.110     	 	$0.083
    S3 next 450tb        	$0.095  		$0.073

### Storing 1TB data

(Cost of storage, neglecting I/O costs, and assuming the ratio of EBS volume size to snapshot size is as given)

* http://aws.amazon.com/ec2/instance-types/
* http://aws.amazon.com/ec2/#pricing

### How much does EBS cost?

The costs of EBS will be similar to the pricing structure of data storage on S3.  There are three types of costs associated with EBS.

Storage Cost + Transaction Cost + S3 Snapshot Cost = Total Cost of EBS

NOTE: For current pricing information, be sure to check Amazon EC2 Pricing.

#### Storage Costs

The cost of an EBS Volume is $0.10/GB per month.  You are responsible for paying for the amount of disk space that you reserve, not for the amount of the disk space that you actually use.  If you reserve a 1TB volume, but only use 1GB, you will be paying for 1TB.
* $0.10/GB per month of provisioned storage
* $0.10/GB per 1 million I/O requests

#### Transaction Costs

In addition to the storage cost for EBS Volumes, you will also be charged for I/O transactions. The cost is $0.10 per million I/O transactions, where one transaction is equivalent to one read or write.  This number may be smaller than the actual number of transactions performed by your application because of the Linux cache for all file systems.
$0.10 per 1 million I/O requests

#### S3 Snapshot Costs

Snapshot costs are compressed and based on altered blocks from the previous snapshot backup.  Files that have altered blocks on the disk and then been deleted will add cost to the Snapshots for example.  Remember, snapshots are at the data block level.
$0.15 per GB-month of data stored
$0.01 per 1,000 PUT requests (when saving a snapshot)
$0.01 per 10,000 GET requests (when loading a snapshot)

NOTE:  Payment charges stop the moment you delete a volume.  If you delete a volume and the status appears as "deleting" for an extended period of time, you will not be charged for the time needed to complete the deletion.
