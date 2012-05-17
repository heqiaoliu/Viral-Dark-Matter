<?php 
require "rosetta_initialize.php";
?>
<!DOCTYPE html>
<html lang="en">
<head> 
  <?php require "../head.html"; ?>
</head>
<?php echo '<body id="rosetta">';
require "../header.html"; ?>
<nav>
  <?php  require "../nav.html"; ?>
</nav>
<section id="mainarea">
  <div id="description" >
  </div>
    
<?php 
$Rosetta = Container::makeRosetta();
$Rosetta->setDatabaseConnection($db); 
//$rosettaArr = $Rosetta->

/*
	$bacter = Container::makeBacter();
	$bacter->setDatabaseConnection($db); 
	$bactArr = $bacter->readBacteria(); 
*/
?>
<div id="rosettaTable">

</div>
</section><!-- /#mainarea -->
<footer>
    <ul>
        <li><a href="input.php" id="Ffirst">external link</a></li>
    </ul>
</footer>
</body>
</html>
