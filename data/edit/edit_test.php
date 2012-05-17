<?php
function __autoload($class_name) {
    require_once 'classes/'.$class_name . '.php';
}
require("common.php"); 
require_authentication(); ?>
<!DOCTYPE html>
<html lang="en">
<head> 
<?php require "head.html"; ?>
<script type="text/javascript">
	$(function() { 
		$(".edit_tr").click(function() {
			var ID=$(this).attr('id');
			$("#bei_"+ID).hide();
			$("#bn_"+ID).hide();
			$("#vi_"+ID).hide();
			$("#v_"+ID).hide();
			$("#bei_input_"+ID).show();
			$("#bn_input_"+ID).show();
			$("#vi_input_"+ID).show();
			$("#v_input_"+ID).show();
			console.log("#bei_input_"+ID);
		}).change(function() {
			var ID=$(this).attr('id');
			var bei=$("#bei_input_"+ID).val();
			var bn=$("#bn_input_"+ID).val();
			var vi=$("#vi_input_"+ID).val();
			var v=$("#v_input_"+ID).val();
			var dataString = 'id='+ID +'&bei='+bei +'&bn='+bn +'&vi='+vi +'&v='+v;
			console.log(dataString);
			$("#bei_"+ID).html('Loading');
			if(bei.length>0 && bn.length>0 && vi.length>0 && v.length>0) {
				$.ajax({
					type: "POST",
					url: "edit_update_bact.php",
					data: dataString,
					cache: false,
					success: function(html) {
						$("#bei_"+ID).html(bei);
						$("#bn_"+ID).html(bn);
						$("#vi_"+ID).html(vi);
						$("#v_"+ID).html(v);
						console.log(html);
					}
				});
			} else {
				alert('Enter something.');
			}
		});
		// Edit input box click action
		$(".editbox").mouseup(function() {
			return false
		});

		// Outside click action
		$(document).mouseup(function() {
			$(".editbox").hide();
			$(".text").show();
		});
	});
</script>
</head>
<?php echo '<body id="edit">';
require "header.html";?>
<nav>
<?php require "nav.html"; ?>
</nav>
<?php 

function createSelect($divName, $width, $height, $tag_ids, $dbArr) {
	array_unshift($tag_ids, '0');  // allows for $i to refer to the same spot in both $tag_ids and $dbArr
    $string = '';
    $string .= "
		<form action=''>
		<div id='".$divName."'>
		<table width='".$width."' height='".$height."'>
			<colgroup>
				<col class='col1'>
			</colgroup>";
    for ($a=0; $a<count($dbArr); $a++) {
        $string .= "<tr id='".$dbArr[$a][0]."' class='edit_tr' >";
        for ($i = 1; $i<count($dbArr[0])/2; $i++) {
        	$string .=
        		"<td class='edit_td'>
					<span id='".$tag_ids[$i]."_".$dbArr[$a][0]."' class='text'>".$dbArr[$a][$i]."</span>
					<input type='text' value='".$dbArr[$a][$i]."' class='editbox' id='".$tag_ids[$i]."_input_".$dbArr[$a][0]."'/>
				</td>";
    	}
    	$string .= "</tr>";
    }
    $string .= "</table></div></form>";
    return $string;
}

?>
<section id="mainarea">
	<div id="description">
		<p>Insert your data here.</p>
	</div>
	<form method="post" action="edit_addClone.php">
		<div id="leftcol">
			<table width="400">
				<colgroup>
					<col class="col1">
				</colgroup>
				<tbody>
					<tr>
						<td>
							<p class="inputTitle">Bacterial External ID <em>*</em> </p>
						</td>
						<td>
							<input required="" placeholder="e.g. EDT0000" name="bact_external_id">
						</td>
					</tr>
					<tr>
						<td>
							<p class="inputTitle">Bacterial Name:</p>
						</td>
						<td>
							<input  placeholder="e.g. Escherichia coli" name="bact_name">
						</td>
					</tr>
					<tr>
						<td>
							<p class="inputTitle">VCID</p>
						</td>
						<td>
							<input placeholder="e.g. 5432" name="vc_id">
						</td>
					</tr>
					<tr>
						<td>
							<p class="inputTitle">Vector<em>*</em></p>
						</td>
						<td>
							<input required"" placeholder="e.g. pEMB11" name="vector">
						</td>
					</tr>
					<tr>
						<td>
							<input type="submit" value="Add clone">
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</form>	
	<?php 

		$dbo = new DBObject("localhost", "nturner", "LOB4steR", "viral_dark_matter");
    	$db = $dbo->getDB();
		Container::$_database = $db;
		$bacter = Container::makeBacter();
		$bacter->setDatabaseConnection($db); 
		$bactArr = $bacter->readBacteria(); 

		echo createSelect('bacteriaLive', 600, 400, array('bei', 'bn', 'vi', 'v'), $bactArr); 
	?>
	
</section>
<footer></footer>
</body>
</html>