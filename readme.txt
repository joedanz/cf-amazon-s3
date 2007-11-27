README
Amazon S3 REST Wrapper - Version 1.2
Copyright 2006 Joe Danziger (joe@ajaxcf.com)
Released: October 4, 2006


Requirements
------------
This script should run fine on ColdFusion MX 6 and 7.


Install
-------
A simple test script is included which demonstrates the use of the CFC.
You must insert your Amazon S3 access keys in the first 2 lines in s3test.cfm,
then just pull it up in a browser.  You also need the <CF_HMAC> custom tag which
required all 5 files in the hmac directory.  Place these in your custom tagpath 
or in the same directory as the sample scripts.


Methods
-------
 ** init(accessKeyID, secretAccessKey) - initialize CFC (both parameters required).
 ** getBuckets() - list all buckets.
 ** putBucket(bucketName) - create a new bucket.
 ** getBucket(bucketName, prefix, marker, maxKeys) - get contents of a bucket (prefix
     is optional and matches on the beginning of a key, marker is optional and results
     start from there, maxKeys is optional and restricts the number of objects returned)
 ** deleteBucket(bucketName) - delete a bucket (bucket must be empty).
 ** putObject(bucketName, fileKey, contentType, HTTPtimeout) - puts an object into a
     bucket (HTTPtimeout is in seconds).
 ** getObject(bucketName, fileKey, minutesValid) - get link to an object (minutesValid
     is optional and defaults to 60).
 ** deleteObject(bucketName, fileKey) - delete an object from a bucket.


Support
-------
You can email me at joe@ajaxcf.com and I'll do my best.


Release History
---------------
 09/07/06 - v1.0 - Initial Release.
 09/27/06 - v1.1 - <cf_hmac> custom tag included in distribution.
 10/04/06 - v1.2 - other required <cf_hmac> scripts now included.


Thanks
------
Special thanks to dorioo on the Amazon S3 Forums for your help and guidance.


Future Plans
------------
 - Add support for access control lists