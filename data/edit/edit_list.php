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
      $("#fn_"+ID).hide();
      $("#n_"+ID).hide();
      $("#ed_"+ID).hide();
      $("#ud_"+ID).hide();
      $("#bei_"+ID).hide();
      $("#rn_"+ID).hide();
      $("#no_"+ID).hide();
      
      $("#fn_input_"+ID).show();
      $("#n_input_"+ID).show();
      $("#ed_input_"+ID).show();
      $("#ud_input_"+ID).show();
      $("#bei_input_"+ID).show();
      $("#rn_input_"+ID).show();
      $("#no_input_"+ID).show();
    }).change(function() {
      var ID = $(this).attr('id');
      var fn = $("#fn_input_"+ID).val();
      var n  = $("#n_input_"+ID).val();
      var ed = $("#ed_input_"+ID).val();
      var ud = $("#ud_input_"+ID).val();
      var bi = $("#bei_input_"+ID).val();
      var rn = $("#rn_input_"+ID).val();
      var no = $("#no_input_"+ID).val();
      var dataString = 'id='+ID +'&fn='+fn +'&n='+n +'&ed='+ed+'&ud='+ud +'&bei='+bi +'&rn='+rn +'&no='+no;
      console.log(dataString);
      $("#fn_"+ID).html('Loading');
      if(fn.length>0 && n.length>0 && ed.length>0 && ud.length>0 && bei.length>0 && rn.length>0 && no.length>0) {
        $.ajax({
          type: "POST",
          url: "edit_update_file.php",
          data: dataString,
          cache: false, 
          success: function(html) {
            $("#fn_"+ID).html(fn);
            $("#n_"+ID).html(n);
            $("#ed_"+ID).html(ed);
            $("#ud_"+ID).html(ud);
            $("#bei_"+ID).html(bi);
            $("#rn"+ID).html(rn);
            $("#no_"+ID).html(no);
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
<body id="list">
  <?php  require "../header.html"; ?>
  <nav>
      <?php require "../nav.html"; ?>
  </nav>      
  <section id="mainarea">                
    <article id="description" >
      <h3>uploaded files:</h3>
      <table width="200" id="filelist">
      <?php 
        $thelist = " ";
        $list = array();
        if ($handle = opendir('../upload')) {
            while (false !== ($file = readdir($handle))) {
                if ($file != "." && $file != ".." && $file != "index.php") {
                  $list[] = $file;
                }
            }
            asort($list);
            closedir($handle);
        }
        foreach ($list as $file) {
            $thelist .= '
            <tr>
            <td>
            <a href="../upload/'.$file.'">'.$file.'</a>
            </td>
            </tr>';
        }
        echo $thelist; 
      ?>
      </table><!-- /#filelist -->
    </article><!-- /#description -->
    <?php 
      $File = Container::makeFile();
      $File->setDatabaseConnection($db); 
      $fileArr = $File->readFilesRef(); 
      echo createEditSelect('fileLive', 700, 500, array('fn', 'n', 'ed', 'ud', 'bei', 'rn', 'no'), $fileArr); 
    ?>
  </section><!-- /#mainarea -->
  <footer>
  	<ul>
  		<li><a href="index.php" id="Ffirst">external link</a></li>
  	</ul>
  </footer>
</body>
</html>
