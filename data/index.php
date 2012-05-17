<?php
/*
author: Nick Turner
        site: viral_dark_matter data_input
        page: index.php
        last updated: 11/18/2011 by Nick Turner

        TODO: 
        - user login: md5 checksum, 
        - input bacterial id (name)
        - VCID
        - plate id is selected -> map of supplements and conc for confirmation
        - all input data can be checked on confirmation screen
        - some data is cross referenced from database or selected directly from database

        - cairo
        - gnuplot
*/
require("common.php"); 
require_authentication(); ?>
<!DOCTYPE html>
<html lang="en">
<head> 
<?php require "head.html"; ?>
</head>
<?php echo '<body id="index">';
require "header.html";?>
<nav>
<?php require "nav.html"; ?>
</nav>
<section id="mainarea">
	<article id="description" >
		<h1>Viral Dark Matter Project</h1>
		<p>
			This website is designed for data input for the viral dark matter project.  Start with the input page if you have data to upload, or go straight to view to see existing data in the database.  
		</p>
		<h3>Instructions:</h3>
		<p>
			Use this website to upload data from a multi-plate reader.  The output from the machine must be in the following format:
		</p
		<p>
		<pre>
02/11/2012 11:50:09 PM	557	
Kinetic read cycle completed:	1  of  1
Well list:	a1r0(a1:h12) = (a1(a1:h12))
Data:	ABS DATA
Units:	O.D.
Display format:	%0.3f
A1	0.364689
A2	0.383005
...
...
H11	0.284526
H12	0.314316
Well list:	a1r1(a1:h12) = a1(a1:h12)-0
Data:	BACKGROUND SUBTRACTED DATA
Units:	O.D.
Display format:	%0.3f
A1	0.364689
A2	0.383005
...
...
H11	0.284526
H12	0.314316
		</pre>
		</p>
		<p>
			Note: we will soon be accepting output from the single plate reader as well.  
		</p>
	</article><!-- /#description -->	

</section><!-- /#mainarea -->	
<footer>
	<ul>
		<li>
			<a href="index.php" id="Ffirst">external link</a>
		</li>
	</ul>
</footer>
</body>
</html>
