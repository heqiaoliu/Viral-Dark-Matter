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
<script src="getPlateInfo.js" type="text/javascript"></script>
<script src="viewtool.js" type="text/javascript" ></script>
<script type="text/javascript" >

/*
    This section generates a chart from the csv file. 
    It uses jquery and highcharts.
*/
var chart;



function gengraph(obj,selectList,wellname) {

    $('div#container').addClass('gengraph');
    minheight(selectList.length*wellname.length);   
    var options = {},
        cnm, // clone name
        wnm, // well name
        x = selectList.length,
        y = wellname.length,
        dp, // datapoint
	groups= new Array();
        seriesObj = new Array(); // create series object for chart

    // Translate 2 separate arrays, clonename and wellname, into a javascript object and attach it to chart 
    // e.g. options.series: seriesObj
    for(var i=0;i<selectList.length;i++){
	groups = selectList[i].split(",");
	for(var ij=0;ij<groups.length;ij++){
		
		var oneGroup=groups[ij].split("^");
		for(var j=0;j<y;j++){
			    wnm = wellname[j];
			    var pointNum=obj[oneGroup[0]][wnm].length;
			    console.log(pointNum);	
			    dp = new Array();
			    var seriesName;
				if(pointNum>1)
					seriesName="*average of ";
			    for(var k=0;k<pointNum;k++) {
				var avgY=0;
				for(var l=0;l<oneGroup.length;l++){
					cnm=oneGroup[l];
					if(k==0)
						seriesName+=cnm+" and ";
					avgY+=parseFloat(obj[cnm][wnm][k][1]);
				}
				temp=Array(parseFloat(obj[cnm][wnm][k][0]),avgY/oneGroup.length);
				dp[k] = temp;
			    }
	    //for each series, the name will be 'External id'-'well number'
			    console.log(dp);
			    if(oneGroup.length==1)
				seriesName=cnm;
			    seriesName+="-"+wnm;
			    seriesObj.push({name:seriesName,data:dp});
       	 		}
	}
    }


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
            text: 'Viral Dark Matter'
        },
        subtitle: {
            text: "Select clone:"+selectList.toString()+" with Wells:"+wellname.toString(),
        },
        xAxis: {
        //    categories: ['0', '27', '54', '81', '108', '135', '161', '188', '215', '242', '269', '295', '322', '349', '376', '403', '430', '456', '483', '510', '537', '564', '591', '617' ],
            title: {
                text: 'Time'
            }
        },
        yAxis: [{
	    type: 'logarithmic',
	    tickInterval:0.3/*(Math.L0G10E/Math.LOG2E)*/, 
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
	
//    }); 
}


/*
    This section processes the form to send to create_flatfile.php.
*/

/*function groupsObj(){
  this.expDate=new Array();
  this.repStr=new Array();

}
groupsObj.prototype.addRep=function(repDate,repNum){
	var pos=this.expDate.indexOf(repDate);
	if(pos>=0)
		this.repStr[pos]+="^"+repNum;
        else{
		this.expDate[this.expDate.length]=repDate;
		this.repStr[this.repStr.length]=repNum;
        }
}

groupsObj.prototype.returnGroups=function(){
	return this.repStr.toString();
}
*/
$(function() {  
    $('#submit_btn').click(function() {  
	// validate and process form here  
        var datastring = "", // For POST value clone, e.g. $_POST['clone'] and its value is a ; seperated string. EDT1111;EDT2222;EDT3333 etc.
            tempstring = "", // For POST value well e.g. A1;A2;A3;A4;E1;E2; ...
            file = $('select#file').val(),
            clone = $('select#clone').val(),
            counter = 0,
            selectList = new Array(),
            wellname = new Array();

        //For each clone, push onto clonename array (for use when we get the data back from the database) and append to the POST variable clone
        $('p.selected').each(function() {
	    if($(this).hasClass("beid")){
	      var tempGroup=new groupsObj();
	      var externalId=(this).id; 
              var labelInfo= (this).id;
              datastring = datastring+labelInfo;
	      if((this).title!="")
		 labelInfo+="/"+(this).title;
	      alert (labelInfo);
	      $("td.replicate."+(this).id).each(function(){
		if($(this).hasClass("selected")){
		  tempGroup.addRep((this).getAttribute("expdate"),labelInfo+":"+(this).title);
		  var tempReplicateNum=(this).title;
		  
//                  selectList.push(labelInfo+":"+tempReplicateNum);
		  datastring+=","+tempReplicateNum;
		}
	      });
	      datastring+=";";
		console.log(tempGroup.returnGroups());
		selectList.push(tempGroup.returnGroups());

	    }
	    if($(this).hasClass("vcid")){
	      if((this).title==""){
                var labelName = (this).id;
                tempstring = tempstring+labelName+";";
                selectList.push(labelName);
	      }
	   } 
        });
	if(datastring.length!=0)
	  datastring="&clone="+datastring;
	if(tempstring.length!=0)
	  datastring+="&vcid="+tempstring;
        console.log(datastring+"\n");
        console.log(datastring+"\n");
	tempstring="";
        // For each well, push onto wellname array and append to POST variable well.  
        $('td.sel.selected').each(function() {
            $this = (this).id;
            tempstring = tempstring+$this+";";
            wellname.push($this);
        });
        datastring+="&well="+tempstring;
	$.ajax({
            type: "POST",
            url: "view_pregraph.php",
            data: datastring,
            dataType: "json",
            success: function(dataObj) {

                //display message back to user here
                console.log("inside success");
                console.log(dataObj);
                gengraph(dataObj,selectList,wellname);
            }
        });
        return false;
    });  
 }); 

    function minheight(number) {
    if (number > 20 ){
            var height = (600 + (number-20)*3).toString()+"px";
            alert(height);
            $('div#container').css("min-height", height);
    }
}

$(function(){
/*    var htime=new Array(); 
    for(var i=0;i<24;i++)
      htime[i]=(parseFloat(mtime[i])/60).toFixed(2).toString(); 
    var hOrm=0;*/
  $("button#chgx").click(function(){
    var mtime=chart.options.xAxis[0].categories ;
	console.log(mtime);
/*    if(hOrm==0){
      chart.xAxis[0].setCategories(htime);
      chart.xAxis.setTitle({text:"Time(hours)"});
      hOrm=1;
    }
    else{
      chart.xAxis[0].setCategories(mtime);
      chart.xAxis.setTitle({text:"Time(minutes)"});
      hOrm=0;
    }*/
  });
});


//generating and download a csv file
//passing a string of data to precsv.php
//each series seperate by ';' each growth measurement seperate by ','
//the data string should be eg. &data=EDT0000/0000:0,A1,0.00001,0.00002,...,0.00001;EDT0001...;
//                                    EDT,vcid,replicate,well,growth,growth,...;nextone...;
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
        url:"precsv.php",
        data:targetstring,
        dataType:"json",
        //here dataObj="&filename="+dataObj; pass to downCsv.php
        success:function(dataObj){
          console.log(dataObj);
          window.location='http://vdm.sdsu.edu/data/downCsv.php?filename='+dataObj;
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
        <p>Select the clone from the list on the left.  Then select the wells from the grid and click generate to see a graph of the data.</p>
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
    echo "<div id=\"cloneSelect\">";
    $result=mysql_query("select b.bact_external_id,b.vc_id from growth_new a left join bacteria b on b.bact_external_id=a.bacteria_external_id group by a.bacteria_external_id order by bact_external_id desc");
    while ($row =mysql_fetch_array($result)) {
        echo "<p class=\"beid\"  id=\"".$row['bact_external_id']."\" title=\"".$row['vc_id']."\">".$row['bact_external_id']."</p>";
        $repResult=mysql_query("select distinct g.replicate_num, f.exp_date from growth_new g left join file f on g.file_name=f.file_name where g.bacteria_external_id='".$row['bact_external_id']."'");		while($thisrow=mysql_fetch_array($repResult)){
             	$i=$thisrow['replicate_num'];
		$replicateString.="<td class=\"replicate num ".$row['bact_external_id']."\" id=\"".$row['bact_external_id']."".$i."\" style=\"display:none;\" title=\"".$i."\" expdate=\"".$thisrow['exp_date']."\">".($i+1)."</td>";
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
        <table id="Tclones" width="650" >
	<tr id="replicate">
            <td class="replicate" id="desb">replicate info</td>
	    <?php 
                  echo $replicateString;
            ?>
        </tr>
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
                        echo "<td id=\"".$temp."\" class=\"".$rowindex." sel\" >".$temp."</td>";
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
