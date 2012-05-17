<?php 

/*
* uploadedfile
* overwrite
* name
* type
* radio1, radio2 -> neither are used
* bactid
* vcid
* other
* plate
* additionalInfo
*/

echo '
<html>
<head>
	<title>MacGyver</title>
</head>
<body>
<p>THE TESTER</p>
<form action="input_uploader_test.php" method="post" enctype="multipart/form-data">
	<table>
		<input type="hidden" name="MAX_FILE_SIZE" value="9000000" />
		<tr>
			<td>uploadedfile</td>
			<td><input id="uploadedfile" name="uploadedfile" type="file" /></td>
		</tr>
		<tr>
			<td>overwrite</td>
			<td><input name="overwrite" value="yes" type="text"></td>
		</tr>
		<tr>
			<td>name</td>
			<td><input name="name" value="Nick Turner" type="text"></td>
		</tr>
		<tr>
			<td>type</td>
			<td><input name="type" value="singleplate" type="text"></td>
		</tr>
		<tr>
			<td>bactid</td>
			<td><input name="bactid" value="EDT2231" type="text"></td>
		</tr>
		<tr>
			<td>vcid</td>
			<td><input name="vcid" value="" type="text"></td>
		</tr>
		<tr>
			<td>other</td>
			<td><input name="other" value="0" type="text"></td>
		</tr>
		<tr>
			<td>plate</td>
			<td><input name="plate" value="carbon_plate_1" type="text"></td>
		</tr>
		<tr>
			<td>additionalInfo</td>
			<td><input name="additionalInfo" value="TEST" type="text"></td>
		</tr>
		<tr>
			<td><input type="submit" value="submit" id="submit"></td>
		</tr>
	</table>
	<p>
		Common test values:
	</p>
	<p>EDT2231A-ID656(27Apr2012).txt <br> t2236A-ID326.txt <br> Nick Turner <br> singleplate <br> EDT2231 EDT2235 1111 <br> test <br> 9999</p>
</form>
</body>
</html>


';
 

 ?>