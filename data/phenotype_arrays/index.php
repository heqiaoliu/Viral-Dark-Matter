<?php    /* 
        author: Nick Turner
        site: viral_dark_matter data_input
        page: view.php
        last updated: 11/18/2011 by Nick Turner 
        */
require("../common.php");
require_authentication(); ?>
<!DOCTYPE html>
<head>
        <link rel="stylesheet" type="text/css" href="../css/reset.css" />
        <link rel="stylesheet" type="text/css" href="../css/stylesheet.css" />
        <title>viral dark matter</title>
        <!--[if IE]>
        <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
        <script src="js/Highcharts-2.1.9/js/highcharts.js" type="text/javascript"></script>
        <script type="text/javascript" src="js/Highcharts-2.1.9/js/themes/gray.js"></script>
<script type="text/javascript" >        
function rowtoggle(source, row_num) {
//alert("in here:" + row_num);
//  checkboxes = document.getElementsById('row'+row_num);
//  for (var i in checkboxes) {
//      checkboxes[i].checked = source.checked;
//  }
  inputs = document.getElementsByTagName('input');
  for (var i in inputs)
  {
     if ( inputs[i].id == 'row'+row_num && inputs[i].type == 'checkbox' )
        inputs[i].checked = source.checked;;
  }
}

function allcheckboxes(toggle) {
  inputs = document.getElementsByTagName('input');
  for (var i in inputs)
  {
     var duh=inputs[i].id;
     if ( inputs[i].type == 'checkbox' && (duh.substring(0,3)=='row' || inputs[i].name=='checkAllRow') )
        inputs[i].checked = toggle;
  }
}

</script>
</head>
<body id="phenotype_arrays">
<html>

<?php require "../header.html" ?>
<nav>
        <ul>
                <li><a href="../index.php" id="Hfirst" >home</a></li>
                <li><a href="../input.php" >input</a></li>
                <li><a href="../phenotype_arrays" >view</a></li>
                <li><a href="../list.php" id="Hlast" >file list</a></li>
        </ul>
        <a href="../login.php" id="logout">logout </a>
</nav>

        <section id="mainarea">
                <article id="description" >
                <p>View your data here.</p>

<form name="checkbox_hell" method="post" action="/cgi-bin/get_pap_data.php">
<!--<input type="button" name="uncheckAll" onClick="allcheckboxes(false)" value="Select None"></input>-->
<p>
   <?php system('perl get_clones.pl'); ?>
</p>
<input type="button" name="checkAll" onClick="allcheckboxes(true)" value="Select All"></input> 
<input type="button" name="uncheckAll" onClick="allcheckboxes(false)" value="Clear Selection"></input> 
<table width="650">
   <tr> <td>Select Row</td><td colspan=12 align=center>Wells</td></tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'A')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowA" name="A1" value="A1">A1</input> </td>
	<td> <input type="checkbox" id="rowA" name="A2" value="A2">A2</input> </td>
	<td> <input type="checkbox" id="rowA" name="A3" value="A3">A3</input> </td>
	<td> <input type="checkbox" id="rowA" name="A4" value="A4">A4</input> </td>
	<td> <input type="checkbox" id="rowA" name="A5" value="A5">A5</input> </td>
	<td> <input type="checkbox" id="rowA" name="A6" value="A6">A6</input> </td>
	<td> <input type="checkbox" id="rowA" name="A7" value="A7">A7</input> </td>
	<td> <input type="checkbox" id="rowA" name="A8" value="A8">A8</input> </td>
	<td> <input type="checkbox" id="rowA" name="A9" value="A9">A9</input> </td>
	<td> <input type="checkbox" id="rowA" name="A10" value="A10">A10</input> </td>
	<td> <input type="checkbox" id="rowA" name="A11" value="A11">A11</input> </td>
	<td> <input type="checkbox" id="rowA" name="A12" value="A12">A12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'B')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowB" name="B1" value="B1">B1</input> </td>
	<td> <input type="checkbox" id="rowB" name="B2" value="B2">B2</input> </td>
	<td> <input type="checkbox" id="rowB" name="B3" value="B3">B3</input> </td>
	<td> <input type="checkbox" id="rowB" name="B4" value="B4">B4</input> </td>
	<td> <input type="checkbox" id="rowB" name="B5" value="B5">B5</input> </td>
	<td> <input type="checkbox" id="rowB" name="B6" value="B6">B6</input> </td>
	<td> <input type="checkbox" id="rowB" name="B7" value="B7">B7</input> </td>
	<td> <input type="checkbox" id="rowB" name="B8" value="B8">B8</input> </td>
	<td> <input type="checkbox" id="rowB" name="B9" value="B9">B9</input> </td>
	<td> <input type="checkbox" id="rowB" name="B10" value="B10">B10</input> </td>
	<td> <input type="checkbox" id="rowB" name="B11" value="B11">B11</input> </td>
	<td> <input type="checkbox" id="rowB" name="B12" value="B12">B12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'C')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowC" name="C1" value="C1">C1</input> </td>
	<td> <input type="checkbox" id="rowC" name="C2" value="C2">C2</input> </td>
	<td> <input type="checkbox" id="rowC" name="C3" value="C3">C3</input> </td>
	<td> <input type="checkbox" id="rowC" name="C4" value="C4">C4</input> </td>
	<td> <input type="checkbox" id="rowC" name="C5" value="C5">C5</input> </td>
	<td> <input type="checkbox" id="rowC" name="C6" value="C6">C6</input> </td>
	<td> <input type="checkbox" id="rowC" name="C7" value="C7">C7</input> </td>
	<td> <input type="checkbox" id="rowC" name="C8" value="C8">C8</input> </td>
	<td> <input type="checkbox" id="rowC" name="C9" value="C9">C9</input> </td>
	<td> <input type="checkbox" id="rowC" name="C10" value="C10">C10</input> </td>
	<td> <input type="checkbox" id="rowC" name="C11" value="C11">C11</input> </td>
	<td> <input type="checkbox" id="rowC" name="C12" value="C12">C12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'D')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowD" name="D1" value="D1">D1</input> </td>
	<td> <input type="checkbox" id="rowD" name="D2" value="D2">D2</input> </td>
	<td> <input type="checkbox" id="rowD" name="D3" value="D3">D3</input> </td>
	<td> <input type="checkbox" id="rowD" name="D4" value="D4">D4</input> </td>
	<td> <input type="checkbox" id="rowD" name="D5" value="D5">D5</input> </td>
	<td> <input type="checkbox" id="rowD" name="D6" value="D6">D6</input> </td>
	<td> <input type="checkbox" id="rowD" name="D7" value="D7">D7</input> </td>
	<td> <input type="checkbox" id="rowD" name="D8" value="D8">D8</input> </td>
	<td> <input type="checkbox" id="rowD" name="D9" value="D9">D9</input> </td>
	<td> <input type="checkbox" id="rowD" name="D10" value="D10">D10</input> </td>
	<td> <input type="checkbox" id="rowD" name="D11" value="D11">D11</input> </td>
	<td> <input type="checkbox" id="rowD" name="D12" value="D12">D12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'E')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowE" name="E1" value="E1">E1</input> </td>
	<td> <input type="checkbox" id="rowE" name="E2" value="E2">E2</input> </td>
	<td> <input type="checkbox" id="rowE" name="E3" value="E3">E3</input> </td>
	<td> <input type="checkbox" id="rowE" name="E4" value="E4">E4</input> </td>
	<td> <input type="checkbox" id="rowE" name="E5" value="E5">E5</input> </td>
	<td> <input type="checkbox" id="rowE" name="E6" value="E6">E6</input> </td>
	<td> <input type="checkbox" id="rowE" name="E7" value="E7">E7</input> </td>
	<td> <input type="checkbox" id="rowE" name="E8" value="E8">E8</input> </td>
	<td> <input type="checkbox" id="rowE" name="E9" value="E9">E9</input> </td>
	<td> <input type="checkbox" id="rowE" name="E10" value="E10">E10</input> </td>
	<td> <input type="checkbox" id="rowE" name="E11" value="E11">E11</input> </td>
	<td> <input type="checkbox" id="rowE" name="E12" value="E12">E12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'F')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowF" name="F1" value="F1">F1</input> </td>
	<td> <input type="checkbox" id="rowF" name="F2" value="F2">F2</input> </td>
	<td> <input type="checkbox" id="rowF" name="F3" value="F3">F3</input> </td>
	<td> <input type="checkbox" id="rowF" name="F4" value="F4">F4</input> </td>
	<td> <input type="checkbox" id="rowF" name="F5" value="F5">F5</input> </td>
	<td> <input type="checkbox" id="rowF" name="F6" value="F6">F6</input> </td>
	<td> <input type="checkbox" id="rowF" name="F7" value="F7">F7</input> </td>
	<td> <input type="checkbox" id="rowF" name="F8" value="F8">F8</input> </td>
	<td> <input type="checkbox" id="rowF" name="F9" value="F9">F9</input> </td>
	<td> <input type="checkbox" id="rowF" name="F10" value="F10">F10</input> </td>
	<td> <input type="checkbox" id="rowF" name="F11" value="F11">F11</input> </td>
	<td> <input type="checkbox" id="rowF" name="F12" value="F12">F12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'G')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowG" name="G1" value="G1">G1</input> </td>
	<td> <input type="checkbox" id="rowG" name="G2" value="G2">G2</input> </td>
	<td> <input type="checkbox" id="rowG" name="G3" value="G3">G3</input> </td>
	<td> <input type="checkbox" id="rowG" name="G4" value="G4">G4</input> </td>
	<td> <input type="checkbox" id="rowG" name="G5" value="G5">G5</input> </td>
	<td> <input type="checkbox" id="rowG" name="G6" value="G6">G6</input> </td>
	<td> <input type="checkbox" id="rowG" name="G7" value="G7">G7</input> </td>
	<td> <input type="checkbox" id="rowG" name="G8" value="G8">G8</input> </td>
	<td> <input type="checkbox" id="rowG" name="G9" value="G9">G9</input> </td>
	<td> <input type="checkbox" id="rowG" name="G10" value="G10">G10</input> </td>
	<td> <input type="checkbox" id="rowG" name="G11" value="G11">G11</input> </td>
	<td> <input type="checkbox" id="rowG" name="G12" value="G12">G12</input> </td>
   </tr>
   <tr>
	<td align="center"> <input type="checkbox" name="checkAllRow" onClick="rowtoggle(this, 'H')" value="checkAllRow"></input> </td>
	<td> <input type="checkbox" id="rowH" name="H1" value="H1">H1</input> </td>
	<td> <input type="checkbox" id="rowH" name="H2" value="H2">H2</input> </td>
	<td> <input type="checkbox" id="rowH" name="H3" value="H3">H3</input> </td>
	<td> <input type="checkbox" id="rowH" name="H4" value="H4">H4</input> </td>
	<td> <input type="checkbox" id="rowH" name="H5" value="H5">H5</input> </td>
	<td> <input type="checkbox" id="rowH" name="H6" value="H6">H6</input> </td>
	<td> <input type="checkbox" id="rowH" name="H7" value="H7">H7</input> </td>
	<td> <input type="checkbox" id="rowH" name="H8" value="H8">H8</input> </td>
	<td> <input type="checkbox" id="rowH" name="H9" value="H9">H9</input> </td>
	<td> <input type="checkbox" id="rowH" name="H10" value="H10">H10</input> </td>
	<td> <input type="checkbox" id="rowH" name="H11" value="H11">H11</input> </td>
	<td> <input type="checkbox" id="rowH" name="H12" value="H12">H12</input> </td>
   </tr>
</table>
<p><input VALUE="Show Plate Data" TYPE="Submit"></p>
</form>

</article><!-- /#description -->
<figure>
<?php if (isset($_GET['img'])) {?>

<div><?php echo $_SESSION['perlreturn']; ?></div>

<?php }?>
</figure>
        </section><!-- /#mainarea -->
        <footer>
                <ul>
                        <li><a href="input.php" id="Ffirst">external link</a></li>
                </ul>
        </footer>
</body>
</html>

