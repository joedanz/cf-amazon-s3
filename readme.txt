README
Amazon S3 REST Wrapper - Version 2.1
Joe Danziger (joe@ajaxcf.com)
Released: August 3, 2011


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
 ** putBucket(bucketName, acl, storageLocation) - create a new bucket (acl is optional 
 	and	defaults to public-read, storageLocation is optional and defaults to non-EU.
 	Use 'EU' for the European location contraint).
 ** getBucket(bucketName, prefix, marker, maxKeys, showVersions) - get contents of a bucket 
 	(prefix is optional and matches on the beginning of a key, marker is optional and results
     start from there, maxKeys is optional and restricts the number of objects returned)
 ** deleteBucket(bucketName) - delete a bucket (bucket must be empty).
 ** putObject(bucketName, fileKey, contentType, HTTPtimeout, cacheControl, cacheDays, acl, 
 	storageClass, keyName, uploadDir) - puts an object into a bucket (HTTPtimeout is in 
 	seconds - default is 300; cacheControl tells browser to cache object - default is true; 
 	cacheDays default is 30; acl = access control list; storageClass = S3 Storage Class; 
 	keyName defaults to fileKey; uploadDir defaults to current directory).
 ** getObject(bucketName, fileKey, minutesValid) - get link to an object (minutesValid
     is optional and defaults to 60).
 ** copyObject(oldBucketName, oldFileKey, newBucketName, newFileKey) - copies an object.
 ** renameObject(oldBucketName, oldFileKey, newBucketName, newFileKey) - renames an object.
 ** deleteObject(bucketName, fileKey) - delete an object from a bucket.
 ** objectExists(bucketName, fileKey) - determines if object exists in bucket.
 ** setBucketVersioning(bucketName,versioningStatus) - sets versioning on a bucket.  
    Valid values are 'Enabled' and 'Suspended'
 ** getBucketVersioning(bucketName) - gets current versioning status of bucket. 


 NOTE: You may also access your objects via:
       http://bucketname.s3.amazonaws.com/name-of-the-object


Support
-------
You can email me at joe@ajaxcf.com and I'll do my best.


Wishlist
--------
My Amazon Wishlist: http://amazon.com/gp/registry/wishlist/1X4EGLWAC43FJ/102-5824999-1765764


Release History
---------------
 09/07/06 - v1.0 - Initial Release.
 09/27/06 - v1.1 - <cf_hmac> custom tag included in distribution.
 10/04/06 - v1.2 - other required <cf_hmac> scripts now included.
 11/28/07 - v1.3 - integrated ACL & EU storage, better CF6 compatibility
 02/12/08 - v1.4 - now using Java's included HMAC_SHA1 function.
 06/13/08 - v1.5 - fixed getObject link with URLEncodedFormat().
 12/11/08 - v1.6 - added copyObject and renameObject methods.
 12/15/08 - v1.7 - added cacheControl and cacheDays to putObject.
 07/27/10 - v1.8 - added versioning, reduced redundancy, more acls.
 01/06/11 - v1.9 - added ability to use different key name and upload directory.
 02/10/11 - v2.0 - fixed bug introduced in v1.9.
 08/03/11 - v2.1 - added objectExists method to test if object is on S3.


Thanks
------
Special thanks to dorioo on the Amazon S3 Forums for your help and guidance.
Thanks to Steve Hicks for the bucket ACL updates (www.stevehicksonline.com).
Thanks to Carlos Gallupa for the EU storage location updates (www.mximize.com).
Thanks to Dmitry Yakhnov for info on Java's HMAC SHA-1 function.
Thanks to Joel Greutman for the fix on the getObject link.
Thanks to Jerad Sloan for the Cache Control headers.