<cfset accessKeyId = "*** YOUR_ACCESS_KEY_ID ***"> 
<cfset secretAccessKey = "*** YOUR_SECRET_ACCESS_KEY ***">

<!doctype html>
<html lang="en" class="no-js">
<head>
  <meta charset="utf-8">
	<title>ColdFusion Amazon S3 Wrapper Test</title>
	<style>
		body { font-family:"Trebuchet MS", Arial, Helvetica; }
		th { text-align:left; }
		table { border-collapse:collapse; }
		table, th, td { border: 1px solid #ccc; padding:3px; }
	</style>
</head>
<body>
<cfif find('***',accessKeyId) or find('***',secretAccessKey)>
	<h1>You must enter your AWS credentials at top of script: <cfoutput>#cgi.script_name#</cfoutput></h1>
	<cfabort>
</cfif>

<cfset s3 = createObject("component","s3").init(accessKeyId,secretAccessKey)>

<cfparam name="url.b" default="">
<cfparam name="url.versions" default="false">

<cfif isDefined("form.createBucket")>
	<cfif compare(url.b,'')>
		<cfset form.bucketName = url.b & "/" & form.bucketName>
	</cfif>
	<cfset s3.putBucket(form.bucketName,form.acl,form.storage)>
<cfelseif isDefined("form.uploadFile")>
	<cfparam name="form.cacheControl" default="0">
	<cffile action="upload" filefield="objectName" destination="#GetTempDirectory()#" nameconflict="makeunique" mode="666">
	<cfset result = s3.putObject(url.b,file.serverFile,file.contentType,'300',form.cacheControl,'30',form.acl,form.storageClass,form.keyName,GetTempDirectory())>
	<cffile action="delete" file="#GetTempDirectory()##file.serverFile#">
<cfelseif isDefined("form.copy")>
	<cfset result = s3.copyObject(url.b,url.co,form.newBucket,form.newFile)>
	<cflocation url="#cgi.script_name#?b=#form.newBucket#" addtoken="false">
<cfelseif isDefined("form.rename")>
	<cfset result = s3.renameObject(url.b,url.ro,form.newBucket,form.newFile)>
	<cflocation url="#cgi.script_name#?b=#form.newBucket#" addtoken="false">
<cfelseif isDefined("url.db")>
	<cfset s3.deleteBucket(url.db)>
<cfelseif isDefined("url.do")>
	<cfset s3.deleteObject(url.b,url.do)>
<cfelseif isDefined("url.vo")>
	<cfset timedLink = s3.getObject(url.b,url.vo)>
	<cfoutput><a href="#timedLink#">#timedLink#</a></cfoutput>
<cfelseif isDefined("url.von")>
	<cfset s3.setBucketVersioning(url.cv,'Enabled')>
<cfelseif isDefined("url.voff")>
	<cfset s3.setBucketVersioning(url.cv,'Suspended')>
</cfif>

<cfif isDefined("url.co")>
	<cfset allBuckets = s3.getBuckets()>
	<cfoutput>
		<h1>Copy Object</h1>
		
		<h2>Copy From: /#url.b#/#url.co#</h2>
		<form action="#cgi.script_name#?#cgi.query_string#" method="post">
			<h2>Copy To:
				/<select name="newBucket">
					<cfloop from="1" to="#arrayLen(allBuckets)#" index="i">
						<option value="#allBuckets[i].Name#"<cfif not compareNoCase(url.b,allBuckets[i].Name)> selected="selected"</cfif>>#allBuckets[i].Name#</option>
					</cfloop>
				</select>
				/ <input type="text" name="newFile" value="#url.co#" size="20" />
				<input type="submit" name="copy" value="Copy" />
			</h2>
		</form>
		<a href="#cgi.script_name#?b=#url.b#">Back to &quot;#url.b#&quot; Bucket</a> // <a href="#cgi.script_name#">List All Buckets</a>
	</cfoutput>
<cfelseif isDefined("url.ro")>
	<cfset allBuckets = s3.getBuckets()>
	<cfoutput>
		<h1>Rename Object</h1>
		
		<h2>Rename From: /#url.b#/#url.ro#</h2>
		<form action="#cgi.script_name#?#cgi.query_string#" method="post">
			<h2>Rename To:
				/<select name="newBucket">
					<cfloop from="1" to="#arrayLen(allBuckets)#" index="i">
						<option value="#allBuckets[i].Name#"<cfif not compareNoCase(url.b,allBuckets[i].Name)> selected="selected"</cfif>>#allBuckets[i].Name#</option>
					</cfloop>
				</select>
				/ <input type="text" name="newFile" value="#url.ro#" size="20" />
				<input type="submit" name="rename" value="Rename" />
			</h2>
		</form>
		<a href="#cgi.script_name#?b=#url.b#">Back to &quot;#url.b#&quot; Bucket</a> // <a href="#cgi.script_name#">List All Buckets</a>
	</cfoutput>
<cfelseif isDefined("url.eo")>	
	<cfset exists = s3.objectExists(url.b,url.eo)>
	<cfoutput>
		<h1>Check if Object Exists</h1>
	
		<h2>Bucket: #url.b#<br/>
			Object: #url.eo#<br/>
			Exists: #YesNoFormat(exists)#</h2>
		
		<a href="#cgi.script_name#?b=#url.b#">Back to &quot;#url.b#&quot; Bucket</a> // <a href="#cgi.script_name#">List All Buckets</a>		
	</cfoutput>
<cfelseif compare(url.b,'')>
	<cfif url.versions>
		<cfset allContents = s3.getBucket(bucketName=url.b,showVersions=true)>
	<cfelse>
		<cfset allContents = s3.getBucket(bucketName=url.b)>
	</cfif>
	<cfoutput>
	<h1>Get Bucket</h1>
	<table cellpadding="2" cellspacing="0" border="1">
	<cfloop from="1" to="#arrayLen(allContents)#" index="i">
	<tr>
		<td>#allContents[i].Key#</td>
		<td>#allContents[i].LastModified#</td>
		<td>#NumberFormat(allContents[i].Size)#</td>
		<cfif url.versions>
			<td>#allContents[i].VersionID#</td>
			<td>#allContents[i].IsLatest#</td>
		</cfif>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&vo=#URLEncodedFormat(allContents[i].Key)#">Get Link</a></td>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&eo=#URLEncodedFormat(allContents[i].Key)#">Exists?</a></td>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&co=#URLEncodedFormat(allContents[i].Key)#">Copy</a></td>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&ro=#URLEncodedFormat(allContents[i].Key)#">Rename</a></td>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&do=#URLEncodedFormat(allContents[i].Key)#">Delete</a></td>
	</tr>
	</cfloop>
	</table>
	<cfif arrayLen(allContents)><br /></cfif>
	<form action="#cgi.script_name#?b=#url.b#" method="post" enctype="multipart/form-data">
	<table>
		<tr>
			<th>File To Upload</th>
			<th>Key Name (optional)</th>
			<th>ACL</th>
			<th>Redundancy</th>
			<th>Cache Control</th>
			<th>Upload</th>
		</tr>
		<tr>
			<td><input type="file" name="objectName" size="30" /></td>
			<td><input type="text" name="keyName" size="30" /></td>
			<td>
				<select name="acl">
					<option value="private">Private</option>
					<option value="public-read">Public-Read</option>
					<option value="public-read-write">Public-Read-Write</option>
					<option value="authenticated-read">Authenticated-Read</option>
					<option value="bucket-owner-read">Bucket-Owner-Read</option>
					<option value="bucket-owner-full-control">Bucket-Owner-Full-Control</option>
				</select>
			</td>
			<td>
				<select name="storageClass">
					<option value="STANDARD">Standard</option>
					<option value="REDUCED_REDUNDANCY">Reduced Redundancy</option>
				</select>			
			</td>
			<td>
				<input type="checkbox" name="cacheControl" value="1" id="cc" />
				<label for="cc">Cache Control</label>
			</td>
			<td><input type="submit" name="uploadFile" value="Upload File" /></td>
		</tr>
	</table>
	</form>	
	<a href="#cgi.script_name#">List All Buckets</a>
	</cfoutput>	
<cfelse>
	<!--- get all buckets --->
	<cftry>
		<cfset allBuckets = s3.getBuckets()>
		<cfcatch>
			<h1>Please check your AWS credentials at top of script: <cfoutput>#cgi.script_name#</cfoutput></h1>
			<cfabort>
		</cfcatch>
	</cftry>
	<cfoutput>
	<h1>List All Buckets</h1>
	
	<cfif isDefined("url.cv")>
		<cfset versioning = s3.getBucketVersioning(url.cv)>
		Versioning for #url.cv#: #versioning# (<cfif listFindNoCase('Disabled,Suspended',versioning)><a href="#cgi.script_name#?cv=#URLEncodedFormat(url.cv)#&amp;von=1">Enable</a><cfelse><a href="#cgi.script_name#?cv=#URLEncodedFormat(url.cv)#&amp;voff=1">Suspend</a></cfif>)<br/><br/>
	</cfif>
	
	<table cellpadding="2" cellspacing="0" border="1">
	<cfloop from="1" to="#arrayLen(allBuckets)#" index="i">
	<tr>
		<td>#allBuckets[i].Name#</td>
		<td>#allBuckets[i].CreationDate#</td>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(allBuckets[i].Name)#">View</a></td>
		<td><a href="#cgi.script_name#?b=#URLEncodedFormat(allBuckets[i].Name)#&amp;versions=true">View Versions</a></td>
		<td><a href="#cgi.script_name#?db=#URLEncodedFormat(allBuckets[i].Name)#">Delete</a></td>
		<td><a href="#cgi.script_name#?cv=#URLEncodedFormat(allBuckets[i].Name)#">Check Versioning</a></td>
	</tr>
	</cfloop>
	</table><br />
	<form action="#cgi.script_name#?b=#url.b#" method="post">
	<input type="text" name="bucketName" size="30" />
	<select name="acl">
		<option value="private">Private</option>
		<option value="public-read">Public-Read</option>
		<option value="public-read-write">Public-Read-Write</option>
		<option value="authenticated-read">Authenticated-Read</option>
		<option value="bucket-owner-read">Bucket-Owner-Read</option>
		<option value="bucket-owner-full-control">Bucket-Owner-Full-Control</option>
	</select>
	<select name="storage">
		<option value="">US Standard</option>
		<option value="us-west-1">US West (N. California)</option>
		<option value="EU">Europe (Ireland)</option>
		<option value="ap-southeast-1">Asia Pacific (Singapore)</option>
	</select>
	<input type="submit" name="createBucket" value="Create Bucket" />
	</form>
	</cfoutput>
</cfif>
</body>
</html>