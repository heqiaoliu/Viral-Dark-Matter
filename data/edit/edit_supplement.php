<?php
require "initialize.php";
require("edit_helpers.php"); 
?>
<!DOCTYPE html>
<html lang="en">
<head> 
<?php require "../head.html"; ?>
<script type="text/javascript">
	$(function() { 
		$(".edit_tr").click(function() {
			var ID=$(this).attr('id');
			$("#sn_"+ID).hide();
			$("#ki_"+ID).hide();
			$("#si_"+ID).hide();
			$("#sn_input_"+ID).show();
			$("#ki_input_"+ID).show();
			$("#si_input_"+ID).show();
		}).change(function() {
			var ID=$(this).attr('id');
			var bei=$("#sn_input_"+ID).val();
			var bn=$("#ki_input_"+ID).val();
			var vi=$("#si_input_"+ID).val();
			var dataString = 'id='+ID +'&sn='+bei +'&ki='+bn +'&si='+vi;
			console.log(dataString);
			$("#bei_"+ID).html('Loading');
			if(bei.length>0 && bn.length>0 && vi.length>0 && v.length>0) {
				$.ajax({
					type: "POST",
					url: "edit_update_bact.php",
					data: dataString,
					cache: false,
					success: function(html) {
						$("#sn_"+ID).html(bei);
						$("#ki_"+ID).html(bn);
						$("#si_"+ID).html(vi);
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
require "../header.html";?>
<nav>
<?php require "../nav.html"; ?>
</nav>
<section id="mainarea">
	<?php 
		$Supplement = Container::makeSupplement();
		$Supplement->setDatabaseConnection($db); 
		$bactArr = $Supplement->readSupplements(); 
		echo createEditSelect('supplementLive', 600, 400, array('sn', 'ki', 'si'), $bactArr); 
	?>
</section>
<footer></footer>
</body>
</html>