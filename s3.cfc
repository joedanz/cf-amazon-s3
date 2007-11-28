<cfcomponent name="s3" displayname="Amazon S3 REST Wrapper v1.3">

<!---
Amazon S3 REST Wrapper

Written by Joe Danziger (joe@ajaxcf.com) with much help from
dorioo on the Amazon S3 Forums.  See the readme for more
details on usage and methods.

Version 1.3 - Released: November 28, 2007
--->

	<cfset variables.accessKeyId = "">
	<cfset variables.secretAccessKey = "">

	<cffunction name="init" access="public" returnType="s3" output="false"
				hint="Returns an instance of the CFC initialized.">
		<cfargument name="accessKeyId" type="string" required="true" hint="Amazon S3 Access Key ID.">
		<cfargument name="secretAccessKey" type="string" required="true" hint="Amazon S3 Secret Access Key.">
		
		<cfset variables.accessKeyId = arguments.accessKeyId>
		<cfset variables.secretAccessKey = arguments.secretAccessKey>
	
		<cfreturn this>
	</cffunction>
	
	<cffunction name="Hex2Bin" returntype="any" hint="Converts a Hex string to binary">
		<cfargument name="inputString" type="string" required="true" hint="The hexadecimal string to be written.">
	
		<cfset var outStream = CreateObject("java", "java.io.ByteArrayOutputStream").init()>
		<cfset var inputLength = Len(arguments.inputString)>
		<cfset var outputString = "">
		<cfset var i = 0>
		<cfset var ch = "">
	
		<cfif inputLength mod 2 neq 0>
			<cfset arguments.inputString = "0" & inputString>
		</cfif>
	
		<cfloop from="1" to="#inputLength#" index="i" step="2">
			<cfset ch = Mid(inputString, i, 2)>
			<cfset outStream.write(javacast("int", InputBaseN(ch, 16)))>
		</cfloop>
	
		<cfset outStream.flush()>
		<cfset outStream.close()>
	
		<cfreturn outStream.toByteArray()>
	</cffunction>

	<cffunction name="getBuckets" access="public" output="false" returntype="array" 
				description="List all available buckets.">
		
		<cfset var signature = "">
		<cfset var data = "">
		<cfset var bucket = "">
		<cfset var buckets = "">
		<cfset var thisBucket = "">
		<cfset var allBuckets = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/">
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>

		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin("#digest#"))>
		
		<!--- get all buckets via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset buckets = xmlSearch(data, "//:Bucket")>

		<!--- create array and insert values from XML --->
		<cfset allBuckets = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(buckets)#">
		   <cfset bucket = buckets[x]>
		   <cfset thisBucket = structNew()>
		   <cfset thisBucket.Name = bucket.Name.xmlText>
		   <cfset thisBucket.CreationDate = bucket.CreationDate.xmlText>
		   <cfset arrayAppend(allBuckets, thisBucket)>   
		</cfloop>
		
		<cfreturn allBuckets>		
	</cffunction>
	
	<cffunction name="putBucket" access="public" output="false" returntype="boolean" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="true">
		<cfargument name="acl" type="string" required="false" default="public-read">
		<cfargument name="storageLocation" type="string" required="false" default="">
		
		<cfset var signature = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\ntext/html\n#dateTimeString#\nx-amz-acl:#arguments.acl#\n/#arguments.bucketName#">

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")> 

		<!--- Calculate the hash of the information ---> 
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin("#digest#"))>

		<cfif arguments.storageLocation eq "EU">
			<cfsavecontent variable="strXML">
				<CreateBucketConfiguration><LocationConstraint>EU</LocationConstraint></CreateBucketConfiguration>
			</cfsavecontent>
		<cfelse>
			<cfset strXML = "">
		</cfif>

		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="body" value="#trim(variables.strXML)#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getBucket" access="public" output="false" returntype="array" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="prefix" type="string" required="false" default="">
		<cfargument name="marker" type="string" required="false" default="">
		<cfargument name="maxKeys" type="string" required="false" default="">
		
		<cfset var signature = "">
		<cfset var data = "">
		<cfset var content = "">
		<cfset var contents = "">
		<cfset var thisContent = "">
		<cfset var allContents = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/#arguments.bucketName#">

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>

		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin("#digest#"))>

		<!--- get the bucket via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfif compare(arguments.prefix,'')>
				<cfhttpparam type="URL" name="prefix" value="#arguments.prefix#"> 
			</cfif>
			<cfif compare(arguments.marker,'')>
				<cfhttpparam type="URL" name="marker" value="#arguments.marker#"> 
			</cfif>
			<cfif isNumeric(arguments.maxKeys)>
				<cfhttpparam type="URL" name="max-keys" value="#arguments.maxKeys#"> 
			</cfif>
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset contents = xmlSearch(data, "//:Contents")>

		<!--- create array and insert values from XML --->
		<cfset allContents = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(contents)#">
			<cfset content = contents[x]>
			<cfset thisContent = structNew()>
			<cfset thisContent.Key = content.Key.xmlText>
			<cfset thisContent.LastModified = content.LastModified.xmlText>
			<cfset thisContent.Size = content.Size.xmlText>
			<cfset arrayAppend(allContents, thisContent)>   
		</cfloop>

		<cfreturn allContents>
	</cffunction>
	
	<cffunction name="deleteBucket" access="public" output="false" returntype="boolean" 
				description="Deletes a bucket.">
		<cfargument name="bucketName" type="string" required="yes">	
		
		<cfset var signature = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#"> 
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")> 
		
		<!--- Calculate the hash of the information ---> 
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin("#digest#"))>
		
		<!--- delete the bucket via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="putObject" access="public" output="false" returntype="boolean" 
				description="Puts an object into a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="contentType" type="string" required="yes">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		
		<cfset var signature = "">
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:public-read\n/#arguments.bucketName#/#arguments.fileKey#">
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>
		
		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin("#digest#"))>
		
		<!--- Read the image data into a variable --->
		<cffile action="readBinary" file="#ExpandPath("./#arguments.fileKey#")#" variable="binaryFileData">
		
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#" timeout="#arguments.HTTPtimeout#">
			  <cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			  <cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			  <cfhttpparam type="header" name="Date" value="#dateTimeString#">
			  <cfhttpparam type="header" name="x-amz-acl" value="public-read">
			  <cfhttpparam type="body" value="#binaryFileData#">
		</cfhttp> 		
		
		<cfreturn true>
	</cffunction>

	<cffunction name="getObject" access="public" output="false" returntype="string" 
				description="Returns a link to an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="minutesValid" type="string" required="false" default="60">
		
		<cfset var signature = "">
		<cfset var timedAmazonLink = "">
		<cfset var epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60)>

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#epochTime#\n/#arguments.bucketName#/#arguments.fileKey#">

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>

		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = URLEncodedFormat(ToBase64(Hex2Bin("#digest#")))>

		<!--- Create the timed link for the image --->
		<cfset timedAmazonLink = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#?AWSAccessKeyId=#variables.accessKeyId#&Expires=#epochTime#&Signature=#signature#">

		<cfreturn timedAmazonLink>
	</cffunction>

	<cffunction name="deleteObject" access="public" output="false" returntype="boolean" 
				description="Deletes an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">

		<cfset var signature = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#/#arguments.fileKey#"> 

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")> 

		<!--- Calculate the hash of the information ---> 
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		
		<cfset signature = ToBase64(Hex2Bin("#digest#"))>

		<!--- delete the object via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>

		<cfreturn true>
	</cffunction>
	
</cfcomponent>