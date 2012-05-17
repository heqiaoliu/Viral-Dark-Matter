<?php

$server   = "localhost";
$user     = "heqiaol";
$password = "LHQk666!";

trim($server);
trim($user);
trim($password);

function error( $msg )
{
    print( "<h2>ERROR: $msg</h2>\n" );
    exit();
}

/* Make a connection to the database server: */
$db = mysql_connect( $server, $user, $password );

if ( ! $db )
    error( "Cannot open connection to $user@$server" );

/* Choose the database to work with: */
if (!mysql_select_db( "vdm_joomla", $db ))
   error( "Cannot select database 'viral_dark_matter'." );

$days=4-idate("w");
if($days<0)
	$days+=7;
$nextMeeting=date("Y-m-d",mktime(0,0,0,date("m"),date("d")+$days,date("Y")));
$lastMeeting=date("Y-m-d",mktime(0,0,0,date("m"),date("d")+$days-7,date("Y")));
$query="SELECT f.file_title,u.name,f.url_download,f.file_pic  FROM vdm_jdownloads_files f left join vdm_users u on f.created_id= u.id WHERE date(f.date_added) <= '".$nextMeeting."' and date(f.date_added)> '".$lastMeeting."' and f.cat_id = 4 order by u.name asc";
$result=mysql_query($query);

$queryB="SELECT f.file_title,u.name,f.url_download,f.file_pic  FROM vdm_jdownloads_files f left join vdm_users u on f.created_id= u.id WHERE date(f.date_added) <= '".$lastMeeting."' and f.cat_id = 4 order by u.name asc";
$previous=mysql_query($queryB);
?>


<head>
<link rel="stylesheet" href="templates/meetingStyle.css" type="text/css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
<script type="text/javascript">
$(document).ready(function(){
	$("div#old").hide();
	$("p.old").click(function(){
		$("div#old").toggle();
	});
});

</script>
</head>
<html>
<?php
$pdfAddress="http://vdm.sdsu.edu/VdmData/Meeting/";
$pptAddress="http://docs.google.com/viewer?url=vdm.sdsu.edu%2FVdmData%2FMeeting%2F";
echo "<a name=\"top\"><p class=\"meetingIndex\">Meeting ".$nextMeeting."</p></a>";
$filesIndex="";
$filesDisplay="";
while ($row =mysql_fetch_array($result)) {

	$fileIndex=$row['name']." \"".$row['file_title']."\"";
	if($row['file_pic']=='pdf.png')
		$fileAddress=$pdfAddress.$row['url_download'];
	else
		$fileAddress=$pptAddress.$row['url_download']."&embedded=true";
	$filesIndex.="<a href=\"#".$fileIndex."\">".$fileIndex."</a>";
	$filesDisplay.="<div class=\slide\"><div>";
	$filesDisplay.="<a href=\"".$fileAddress."\" target=\"_blank\">click to see ".$row['file_title']." in full screen.</a>";
	$filesDisplay.="<a name=\"".$row['name']."\" href=\"#top\">Back to Top</a>";
	$filesDisplay.="</div>";
	$filesDisplay.="<iframe src=\"".$fileAddress."\" style=\"height:100%; width:100%\"></iframe>";
	$filesDisplay.="</div>";
}
$filesIndex.="<a><p class=\"old\">See files for previous meetings>></p></a>";
$oldFiles="";
while($row =mysql_fetch_array($previous)){
	$fileIndex=$row['name']." \"".$row['file_title']."\"";
	if($row['file_pic']=='pdf.png')
		$fileAddress=$pdfAddress.$row['url_download'];
	else
		$fileAddress=$pptAddress.$row['url_download']."&embedded=true";
	$oldFiles.="<a href=\"".$fileAddress."\" target=\"_blank\">".$fileIndex."</a>";
}
echo "<div class=\"fileposter\">";
echo $filesIndex;
echo "</div>";
echo "<div id=\"old\" class=\"fileposter\">";
echo $oldFiles;
echo "</div>";
echo $filesDisplay;
?>
</html>
