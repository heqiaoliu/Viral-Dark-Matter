<?php    /*
    view 
    author: Nick Turner & Heqiao Liu
    site: viral_dark_matter data/view
    page: view_hq.php
    last updated: 27/03/2012 by HQ 
        */
require("common.php"); 
require_authentication(); ?>
<!DOCTYPE html>
<html lang="en">
<head> 
<?php require "head.html"; ?>
<script src="js/Highcharts-2.1.9/js/highcharts.js" type="text/javascript"></script>
<script src="js/jquery.form.js" type="text/javascript"></script>
<script src="js/Highcharts-2.1.9/js/modules/exporting.js" type="text/javascript"></script>
<script src="viewsite/getPlateInfo.js" type="text/javascript"></script>
<script src="viewsite/viewtool.js" type="text/javascript" ></script>
<script type="text/javascript" >

/*
    This section generates a chart from the csv file. 
    It uses jquery and highcharts.
*/
var chart;
var logBaseTwo=parseFloat(Math.LOG10E/Math.LOG2E); 


function gengraph(obj,tempList,individualList,wellname) {
    var subtitle=tempList.getAllInfo()+" "+individualList.toString();
    $('div#container').addClass('gengraph');
    minheight(tempList.listSize*wellname.length);   
    var options = new Array,
        seriesObj = new Array(); // create series object for chart
    seriesObj=getSeriesObj(obj,tempList,individualList,wellname);
    options = {
        chart: {
            renderTo: 'container',
            defaultSeriesType: 'line',
        },
	    labels: {
	        items: [{
            }],
            style: {
                color: '#808080',
            }
	    },
        title: {
            text: 'Growth Measurement'
        },
        subtitle: {
            text: "Select clone:"+subtitle+" with Wells:"+wellname.toString(),
        },
        xAxis: {
            title: {
                text: 'Time'
            }
        },
        yAxis: [{
	    type: 'logarithmic',
	    tickInterval:logBaseTwo, 
	    minorTickInterval:'auto',	
            title: {
                text: 'Growth (O.D.)'
            },
	    labels:{formatter:function(){return parseFloat((this.value).toString().substring(0,7));}},
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        }],
        series: seriesObj
    };
        // Create the chart 
        chart = new Highcharts.Chart(options);
	
}

/*
    This section processes the form to send to create_flatfile.php.
*/


        //For each clone, push onto clonename array (for use when we get the data back from the database) and append to the POST variable clone

//---------------------------generating and download a csv file
//passing a string of data to precsv.php
//each series seperate by ';' each growth measurement seperate by ','
//the data string should be eg. &data=EDT0000/0000:0,A1,0.00001,0.00002,...,0.00001;EDT0001...;
//      ----------------------------- EDT,vcid,replicate,well,growth,growth,...;nextone...;
$(function(){
  $("button#csv").click(function(){
    var targetstring="&data=";
    for(var i=0;i<chart.series.length;i++){
	targetstring+=chart.series[i].name;
	for(var j=0;j<chart.series[i].data.length;j++){
		targetstring+=","+chart.series[i].data[j].y;
	}
	targetstring+=";";
    }
    //the data string gonna post to precsv.php
    //the string as format, name, datapoints seperate by ',',and ';' at the end of each one
    $.ajax({
        type:"POST",
        url:"viewsite/precsv.php",
        data:targetstring,
        dataType:"json",
        //here dataObj="&filename="+dataObj; pass to downCsv.php
        success:function(dataObj){
          console.log(dataObj);
          window.location='http://vdm.sdsu.edu/data/viewsite/downCsv.php?filename='+dataObj;
        }
    });
  });
});



</script>


<?php

 /* database information */
$server   = "localhost";
$user     = "nturner";
$password = "LOB4steR";

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
if (!mysql_select_db( "viral_dark_matter", $db ))
   error( "Cannot select database 'viral_dark_matter'." );
?>

</head>

<body id="view">
<?php require "header.html" ?>
<nav>
  <?php require "nav.html" ?>
</nav>
<section id="mainarea">
    <article id="description" >
        <p id="userGuide1">For generating the site, please start from selecting Bacteria external ID.</p>
	<p id="userGuide2">Type the EDT# in the input box or using the scroll bar to find the one you are looking for.</p>
	<p id="userGuide3">Left click to select and focus on a bacteria ID. </p>
    </article><!-- /#description -->
<div id="selectClones">
    <form id="clones" action="" method="" >
    <!--<form action="create_flatfile.php" id="clones" method="POST" >-->

        <table id="clones">
            <tr>
               <td><form>EDT<input id="edtin" type="text" maxlength="4"><br/></form></td>
               <!-- vcid is no more use as select condition <td><form>VCID<input id="edtid" type="text" maxlength="5"><br/></form></td> !-->
            </tr>
        </table>
    <div id="gcContainer">
    <?php
    $replicateString="";
    $plateString="";
    echo "<div id=\"cloneSelect\">";
    $result=mysql_query("select b.bact_external_id,b.vc_id,b.bacteria_id from growth_new a left join bacteria b on b.bact_external_id=a.bacteria_external_id group by a.bacteria_external_id order by bact_external_id desc");
    while ($row =mysql_fetch_array($result)) {
        echo "<a name=\"".$row['bact_external_id']."\"><p class=\"beid\"  id=\"".$row['bact_external_id']."\" bacteria_id=\"".$row['bacteria_id']."\"title=\"".$row['vc_id']."\">".$row['bact_external_id']."</p></a>";
        $repResult=mysql_query("select distinct g.replicate_num, f.exp_date from growth_new g left join file f on g.file_name=f.file_name where g.bacteria_external_id='".$row['bact_external_id']."'");		while($thisrow=mysql_fetch_array($repResult)){
             	$i=$thisrow['replicate_num'];
		$replicateString.="<td class=\"replicate num ".$row['bact_external_id']."\" id=\"".$row['bact_external_id']."".$i."\" style=\"display:none;\" title=\"".$i."\" expdate=\"".$thisrow['exp_date']."\">".$i."</td>";
         }
	$plateResult=mysql_query("select distinct p.base_name,p.plate_id  from plate p left join growth_new g on p.plate_name=g.plate_name where g.bacteria_external_id='".$row['bact_external_id']."'");
	while($thisrow=mysql_fetch_array($plateResult)){
		$plate=$thisrow['base_name'];
		$plateString.="<td class=\"plate name ".$row['bact_external_id']."\" id=\"".$plate."\" plate_id=\"".$thisrow['plate_id']."\" style=\"display:none;\">".$plate."</td>";
	}
    }
    echo "</div>";
/*    echo "<div id=\"vcidSelect\">";
  //  This part is input box for vc_id which is not neccesary any more.
	$result=mysql_query("SELECT vc_id,bact_external_id From bacteria ORDER BY vc_id DESC");
    while ($row =mysql_fetch_array($result)) {
        echo "<p class=\"vcid\"  id=\"".$row['vc_id']."\" title=\"".$row['bact_external_id']."\">".$row['vc_id']."</p>";
    }
    echo "</div>";*/
    ?>
        <div class="gridwrapper">
        <input type="button" name="uncheckAll" id="clearButton" value="Select All"></input>
        <p id="infoBox">Information</p>
	<table id="plates" width="350">
		<tr>
			<td class="plate" id="desc">plate info</td>
			<?php echo $plateString ;?>
		</tr>
	</table>
	<table id="replicates">
		<tr id="replicate" class="replicate">
        	    <td class="replicate" id="desb">replicate info</td>
		    <?php 
        	          echo $replicateString;
        	    ?>
        	</tr>
	</table>
        <table id="Tclones" width="650" >
	    <?php
	    	for($i=0;$i<8;$i++){
		    $rowindex=chr(65+$i);
		    echo "<tr id=\"R".$rowindex."\">";
		    for($j=0;$j<13;$j++){
		      if($j==0){
   			echo "<td id=\"".$rowindex."\" class=\"selectRow\">".$rowindex."</td>";
		      }
		      else{
		        $temp=$rowindex;
			$temp.=$j;
                        echo "<td id=\"".$temp."\" class=\"".$rowindex." sel\" wellId=\"".($i+8*($j-1)+1)."\">".$temp."</td>";
                        }
      		      }
		    echo "</tr>";
	    	}
	    ?>
            <tr>
                <td><input type="submit" name="submit" class="button" id="submit_btn" value="Generate" onclick="return false;" ></td>
            </tr>
        </table>
    </div> <!-- /#gridwrapper -->
    </div> <!-- /#gcContainer -->
</form>
    <figure id="graph">
        <div id="container" style="width: 100%; height: 40px">Click Generate above to see a graph.</div>
        <!--button id="avg" onclick="return false;">get average for all selected data</button!-->
        <!--button id="dev" onclick="return false;">get deviationfor all selected data</button!-->
        <!--button id="chgx" onclick="return false;">change xAxis</button!-->
        <!--button id="chgYintvl" onclick="return false;">change Yinterval to log</button!-->
	<button id="csv" onclick="return false;">download as csvfile</button>
    </figure>
    <div id="extra">
        <input type="hidden" />
        <p></p>
    </div>

</section><!-- /#mainarea -->
<footer>
    <ul>
        <li><a href="input.php" id="Ffirst">external link</a></li>
    </ul>
</footer>
</body>
</html>
