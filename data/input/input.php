<?php  
require "input_initialize.php";
?>
<!DOCTYPE html>
<html lang="en">
<head> 
  <?php require "../head.html"; ?>
  <script src="input_js.js" type="text/javascript"></script>
</head>
<?php echo '<body id="input">';
require "../header.html"; ?>
<nav>
  <?php  require "../nav.html"; ?>
</nav>
<section id="mainarea">
  <div id="description" >
    <p>Please select the file type, the bacterial ID, the plate type and add any additional information.  Plates associated with the viral dark matter project should be "multi-plate reader."</p>
    <p id="error"></p>
    <p id="success" style="color: green;"><?php if (isset($_REQUEST['success'])) echo $_REQUEST['success']; ?></p>
  </div><!-- /#description -->
  <form action="input_uploader.php" method="post" enctype="multipart/form-data">
  <div id="leftCol">
    <table>
      <colgroup>
        <col class="col1">
        <col class="col2">
      </colgroup>
      <tr>
        <input type="hidden" name="MAX_FILE_SIZE" value="9000000" />
        <td><p>Choose a file to upload: </p></td>
        <td><input id="uploadedfile" name="uploadedfile" type="file" /></td>
      </tr>
      <tr>
        <!-- THIS HIDDEN FIELD DETERMINES WHETHER THE CURRENT FILE's DATA WILL BE DELETED BEFORE UPLOAD -->
        <td><input type="hidden" name="overwrite" id="overwrite" value="no" /> </td>
        <!-- ***************************************************************************** -->
      </tr>
      <tr>
        <td><p class="inputTitle" >Name:</p></td>
        <?php 
        $dbo_joom = new DBObject("localhost", "nturner", "LOB4steR", "vdm_joomla");
        $db_joom = $dbo_joom->getDB();

        $User = Container::makeUser();
        $User->setDatabaseConnection($db_joom);
        $Name = $User->getCurrentName(); ?>
        <td><input name="name" disable="disable" value="<? echo $Name ?>" onfocus="if(this.value==this.defaultValue)this.value='';" onblur="if(this.value=='')this.value=this.defaultValue;"/></td>
      </tr>
      <tr>
        <td><p class="inputTitle" >Select File Type: <em>*</em></p></td>
        <td><select name="type">
        <optgroup label="phenotype microarray">
          <option value="singleplate">single plate reader</option>
          <option value="multiplate">multi plate reader</option>
        </optgroup>
        <!--
        <optgroup label="Lab2">
          <option value="mix">mix</option>
          <option value="exp4">exp4</option>
        </optgroup>
        --> 
        </select></td>
      </tr>
      <tr> 
        <div id="dradio1"><input type="radio" name="radio1" id="radio_bact" checked="checked" /></div> <div id="dradio2"><input type="radio" name="radio2" id="radio_vcid" /></div>
        <td><p class="inputTitle" >Bacterial ID: <em>*</em></p></td>
        <td>
        <select name="bactid" id="bactid">
        <optgroup label="Bacterial ID">
        <?php 
        $bacter = Container::makeBacter();
        $bacter->setDatabaseConnection($db); 
        $bactArr = $bacter->readBacteria();
        echo createSelect($bactArr, 1);
        ?>
        </optgroup>
        </select>
        </td>
      </tr>
      <tr>
        <td><p class="inputTitle" >VCID: <em>*</em></p></td>
        <!--<td><input name="vcid" id="vcid" placeholder="e.g. 5604 or phoH" required /></td>-->
        <td>
        <select name="vcid" id="vcid" disabled="disabled"> <!--disabled="disabled" >-->
        <optgroup label="VCID">
        <?php echo createSelect($bactArr, 3); ?>
        </optgroup>
        </select>
        </td>
      </tr>
      <tr>
        <!-- HERE IS WHERE THE DATA FROM AJAX CALL TO VB_SELECT IS STORED (VCID OR BACTID) -->
        <td><input type="hidden" name="other" id="other" value="none" /> </td>
        <!-- ***************************************************************************** -->
      </tr>
      <tr>
        <td><p class="inputTitle" >Plate: <em>*</em></p></td>
        <td>
        <select name="plate">
        <optgroup label="plate name">
        <?php 
          $plate = Container::makePlate();
          $plate->setDatabaseConnection($db); 
          $plateArr = $plate->readPlates();
          echo createSelect($plateArr, 0);
        ?>
        </optgroup>
        </select>
        </td>
      </tr>
  </table>
  </div> <!-- /#leftCol -->
  <div id="rightCol">
  <table>
    <colgroup>
      <col class="col1">
      <col class="col2">
      </colgroup>
      <tr>
        <td><p class="inputTitle" id="addinfo">Additional Information:</p></td>
        <td><textarea name="additionalInfo" placeholder="Enter any notes here." rows="9" columns="100" ></textarea></td>
      </tr>
      <tr>
        <td><input id="upload" type="submit" value="Upload File" /></td>
      </tr>
    </table>
    </div> <!-- /#rightCol -->
    
    </form>
</section><!-- /#mainarea -->
<footer>
    <ul>
        <li><a href="input.php" id="Ffirst">external link</a></li>
    </ul>
</footer>
</body>
</html>
<?php
/* Close database: */
//mysql_close( $db );
?>