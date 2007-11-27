<cfset accessKeyId = "*** YOUR_ACCESS_KEY_ID ***"> 
<cfset secretAccessKey = "*** YOUR_SECRET_ACCESS_KEY ***"> 

<cfset s3 = createObject("component","s3").init(accessKeyId,secretAccessKey)>

<cfparam name="url.b" default="">

<cfif isDefined("form.createBucket")>
	<cfif compare(url.b,'')>
		<cfset form.bucketName = url.b & "/" & form.bucketName>
	</cfif>
	<cfset s3.putBucket(form.bucketName)>
<cfelseif isDefined("form.uploadFile")>
	<cffile action="upload" filefield="objectName" destination= "#ExpandPath('.')#" nameconflict="makeunique" mode="666">
	<cfset s3.putObject(url.b,file.serverFile,file.contentType)>
	<cffile action="delete" file="#ExpandPath("./#file.serverFile#")#">
<cfelseif isDefined("url.db")>
	<cfset s3.deleteBucket(url.db)>
<cfelseif isDefined("url.do")>
	<cfset s3.deleteObject(url.b,url.do)>
<cfelseif isDefined("url.vo")>
	<cfset timedLink = s3.getObject(url.b,url.vo)>
	<cfoutput><a href="#timedLink#">#timedLink#</a></cfoutput>
</cfif>

<cfif compare(url.b,'')>
	<cfset allContents = s3.getBucket(url.b)>
	<cfoutput>
	<h1>Get Bucket</h1>
	<table cellpadding="2" cellspacing="0" border="1">
	<cfloop from="1" to="#arrayLen(allContents)#" index="i">
	<tr><td>#allContents[i].Key#</td><td>#allContents[i].LastModified#</td><td>#NumberFormat(allContents[i].Size)#</td><td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&vo=#URLEncodedFormat(allContents[i].Key)#">Get Link</a></td><td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&do=#URLEncodedFormat(allContents[i].Key)#">Delete</a></td></tr>
	</cfloop>
	</table><br />
	<form action="#cgi.script_name#?b=#url.b#" method="post" enctype="multipart/form-data">
	<input type="file" name="objectName" size="30" />
	<input type="submit" name="uploadFile" value="Upload File" />
	</form>	
	<a href="#cgi.script_name#">List All Buckets</a>
	</cfoutput>	
<cfelse>
	<!--- get all buckets --->
	<cfset allBuckets = s3.getBuckets()>
	<cfoutput>
	<h1>List All Buckets</h1>
	<table cellpadding="2" cellspacing="0" border="1">
	<cfloop from="1" to="#arrayLen(allBuckets)#" index="i">
	<tr><td>#allBuckets[i].Name#</td><td>#allBuckets[i].CreationDate#</td><td><a href="#cgi.script_name#?b=#URLEncodedFormat(allBuckets[i].Name)#">View</a></td><td><a href="#cgi.script_name#?db=#URLEncodedFormat(allBuckets[i].Name)#">Delete</a></td></tr>
	</cfloop>
	</table><br />
	<form action="#cgi.script_name#?b=#url.b#" method="post">
	<input type="text" name="bucketName" size="30" />
	<input type="submit" name="createBucket" value="Create Bucket" />
	</form>
	</cfoutput>
</cfif>
