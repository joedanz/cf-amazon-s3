<cfset accessKeyId = "*** YOUR_ACCESS_KEY_ID ***"> 
<cfset secretAccessKey = "*** YOUR_SECRET_ACCESS_KEY ***">

<cfif find('***',accessKeyId) or find('***',secretAccessKey)>
	<cfabort showerror="You must edit the code to enter YOUR accessKeyId and secretAccessKey at the top.">
</cfif>

<cfset s3 = createObject("component","s3").init(accessKeyId,secretAccessKey)>

<cfparam name="url.b" default="">

<cfif isDefined("form.createBucket")>
	<cfif compare(url.b,'')>
		<cfset form.bucketName = url.b & "/" & form.bucketName>
	</cfif>
	<cfset s3.putBucket(form.bucketName,form.acl,form.storage)>
<cfelseif isDefined("form.uploadFile")>
	<cfparam name="form.cacheControl" default="0">
	<cffile action="upload" filefield="objectName" destination= "#ExpandPath('.')#" nameconflict="makeunique" mode="666">
	<cfset result = s3.putObject(url.b,file.serverFile,file.contentType,'300',form.cacheControl)>
	<cffile action="delete" file="#ExpandPath("./#file.serverFile#")#">
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
	</cfoutput><cfelseif compare(url.b,'')>
	<cfset allContents = s3.getBucket(url.b)>
	<cfoutput>
	<h1>Get Bucket</h1>
	<table cellpadding="2" cellspacing="0" border="1">
	<cfloop from="1" to="#arrayLen(allContents)#" index="i">
	<tr><td>#allContents[i].Key#</td><td>#allContents[i].LastModified#</td><td>#NumberFormat(allContents[i].Size)#</td><td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&vo=#URLEncodedFormat(allContents[i].Key)#">Get Link</a></td>
	<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&co=#URLEncodedFormat(allContents[i].Key)#">Copy</a></td>
	<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&ro=#URLEncodedFormat(allContents[i].Key)#">Rename</a></td>
	<td><a href="#cgi.script_name#?b=#URLEncodedFormat(url.b)#&do=#URLEncodedFormat(allContents[i].Key)#">Delete</a></td></tr>
	</cfloop>
	</table><br />
	<form action="#cgi.script_name#?b=#url.b#" method="post" enctype="multipart/form-data">
	<input type="file" name="objectName" size="30" />
	<input type="submit" name="uploadFile" value="Upload File" />
	<input type="checkbox" name="cacheControl" value="1" id="cc" />
	<label for="cc">Cache Control</label>
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
	<select name="acl">
		<option value="private">Private</option>
		<option value="public-read">Public-Read</option>
		<option value="public-read-write">Public-Read-Write</option>
		<option value="authenticated-read">Authenticated-Read</option>
	</select>
	<select name="storage">
		<option value="US">United States</option>
		<option value="EU">Europa</option>
	</select>
	<input type="submit" name="createBucket" value="Create Bucket" />
	</form>
	</cfoutput>
</cfif>
