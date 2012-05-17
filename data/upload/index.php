<?php
$thelist = " ";
 if ($handle = opendir('.')) {
   while (false !== ($file = readdir($handle)))
      {
          if ($file != "." && $file != ".." && $file != "index.php")
	  {
          	$thelist .= '<a href="'.$file.'">'.$file.'</a>';
          }
       }
  closedir($handle);
  }
?>
<p>List of files:</p>
<?php echo $thelist ?>

