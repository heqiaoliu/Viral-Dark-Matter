function getSeriesObj(){

}

/*
function getSeriesObj(obj,tempList,individualList,wellname){
    var colors= new Array('#4572A7','#AA4643','#89A54E','#80699B','#3D96AE','#DB843D','#92A8CD','#A47D7C','#B5CA92');
    var seriesObj=new Array();
    var counter=0;
    var clock=new Date();
    var start=clock.getSeconds()*1000+clock.getMilliseconds();
    for(var i=0;i<tempList.listSize();i++){
		var cnm=tempList.getBactId(i);
		for(var j=0;j<wellname.length;j++){
			var wnm=wellname[j];
			for(var k=0;k<tempList.getGroupNum(i);k++){
				var seriesName;
				var curColor=colors[counter++%9];
				var curSize=tempList.getGroupSize(i,k);
			    	if(curSize>1){
					var devUp=new Array();
					var devDown=new Array();
				}
				var avgSer=new Array();
				console.log(curSize);
				var groupMem=tempList.getGroup(i,k);
				var dataLen=obj[cnm+":"+groupMem[0]][wnm].length;
				for(var l=0;l<dataLen;l++){
					var tempAvg=0;
					var tempSsqure=0;
					var tempSTD=0;
					var tempname;
					for(var m=0;m<curSize;m++){
						tempname=cnm+":"+groupMem[m];
						tempAvg+=parseFloat(obj[tempname][wnm][l][1]);
					}
					tempAvg/=curSize;
					if(curSize>1){
						for(var m=0;m<curSize;m++){
							tempname=cnm+":"+groupMem[m];
							tempSsqure+=Math.pow(parseFloat(obj[tempname][wnm][l][1])-tempAvg,2);
						}
						tempSTD=Math.sqrt(tempSsqure/curSize);
					devUp.push(new Array(parseFloat(obj[tempname][wnm][l][0]),tempAvg+tempSTD));
					devDown.push(new Array(parseFloat(obj[tempname][wnm][l][0]),tempAvg-tempSTD));
					}
				avgSer.push(new Array(parseFloat(obj[tempname][wnm][l][0]),tempAvg));
				}
				seriesName=cnm;

				if(curSize>1){
					seriesName="*Avg of "+cnm+" Rep"+tempList.getRepNames(i,k);
				}
			    	seriesName+="-"+wnm;
			    seriesObj.push({name:seriesName,color:curColor,data:avgSer});
				if(curSize>1){
					var seriesName1="*Dev+ of "+cnm+"Rep"+tempList.getRepNames(i,k);
					var seriesName2="*Dev- of "+cnm+"Rep"+tempList.getRepNames(i,k);
			    		seriesObj.push({name:seriesName1,dashStyle:"shortDot",lineWidth:0.5,marker:{enabled:false,radius:2},color:curColor,data:devUp});
			    		seriesObj.push({name:seriesName2,dashStyle:"shortDot",lineWidth:0.5,marker:{enabled:false,radius:2},color:curColor,data:devDown});
				}
			}
		}
	}
	for(var i=0;i<individualList.length;i++){
		var cnm=individualList[i];
      		for(var j=0;j<wellname.length;j++){
			var wnm=wellname[j];
			var dataPoints=new Array();
			var curColor=colors[(counter++)%9];
			for(var k=0;k<obj[cnm][wnm].length;k++)
				dataPoints.push(new Array(parseFloat(obj[cnm][wnm][k][0]),parseFloat(obj[cnm][wnm][k][1])));
			seriesObj.push({name:cnm,color:curColor,data:dataPoints});
			counter;
		}
	} 



	console.log(seriesObj);
	return seriesObj;
}
*/
//------------------following is  the methods for JQuery Quick implement
//unique jQuery selector x, and the class want to toggle y.
//class y will be add if the target has it, otherwise removed.
function classTog(x,y){
  if($(x).hasClass(y))
    $(x).removeClass(y);
  else
    $(x).addClass(y);
}

function classTogTwo(varx,vary,classx,classy){
  if($(varx).hasClass(classx)){
    $(varx).removeClass(classx);
    $(vary).removeClass(classy);
  }
  else{
    $(varx).addClass(classx);
    $(vary).addClass(classy);
  }
    
}

function twoClassTog(varx,classOne,classTwo){
  if($(varx).hasClass(classOne)){
    if($(varx).hasClass(classTwo)){
    $(varx).removeClass(classOne);
    $(varx).removeClass(classTwo);}
    else
    $(varx).addClass(classTwo);
  }
  else
    $(varx).addClass(classOne);
    
}

function htmlChange(varx,message){
   $(varx).html(message);
}
//-------------------------------instruction to users
$(document).ready(function(){
  $("p.beid").click(function(){
    $("p#userGuid").html("Please click to choose plate type. ");
  });
  $("td.plate").click(function(){
    $("p#userGuid").html("Please click to choose replicate(s): click once(yellow)--to show as individual; click twice(blue)-- join into group to show average and STD. ");
  });

  $("td.replicate").click(function(){    
    $("p#userGuid").html("Please click well number to choose wells.");
  });

  $("td.sel").click(function(){
    $("p#userGuid").html("Once done with selecting wells, please click to generate the graph.");
  });
});


//----------------following is effect for view.php
$(function(){
  $("td.sel").mouseover(function(){
    var x=(this).id;
    if(x.length>1){
	getWell(x);
    }
  });
  $("#Tclones td").mouseleave(function(){
      htmlChange("p#infoBox","Information");
  });
});


$(function(){
  $("td.replicate.num").mouseover(function(){
    htmlChange("p#infoBox","Replicate"+(parseInt((this).title)+1)+" information: "+(this).getAttribute("expdate"));
  });
  $("td.replicate.num").mouseleave(function(){
    htmlChange("p#infoBox","Information");
  });
});

$(function() {
  $('.selectRow').click(function() {
    classTogTwo(".selectRow#"+(this).id,".sel."+(this).id,"Rselected","selected");
  });
});

$(function() {
  $('#Tclones td.sel').click(function() {
    var x = "td#"+this.id+".sel";
    classTog(x,"selected");
  });
});


$(function() {
  $('#clearButton').click(function() {
    clearVal = $(this).val();
    if (clearVal == "Clear") {
        $('#Tclones td.sel').removeClass('selected');
        $(this).val("Select All");
    } else {
        $('#Tclones td.sel').addClass('selected');
        $(this).val("Clear");
    }
  });
});



$(function (){
  $("td.replicate.num").click(function(){
    var item="td.replicate#"+(this).id;
    twoClassTog(item,"selected","grouped");
  });
});

function repInfo(x,y){
    $("td.replicate").hide();
    $("td.replicate#desb").html("Replicate for "+x+":");
    $("td.replicate#desb").show();
    $("td.replicate."+x+"."+y).show();
}




$(function(){
  $("p.beid").click(function(){
    if($(this).hasClass("focus")&&$(this).hasClass("selected")){
        $(this).removeClass("selected");
    }
    else{
        $("p.beid").removeClass("focus");
	$(this).addClass("selected");
	$(this).addClass("focus");
    }
    plateInfo((this).getAttribute("bacteria_id"));
  });
});

$(function (){
  $("td.plate.name").click(function(){
    var item="td.plate#"+(this).id;
    $("td.replicate").removeClass("focus");
    $(this).addClass("focus");
    classTog(item,"selected");
    repInfo((this).getAttribute("plate_id"),(this).getAttribute("bacteria_id"));
  });
});

function plateInfo(x){
    $("td.plate").hide();
    $("td.plate#desc").html("Plate for "+x+":");
    $("td.plate#desc").show();
    $("td.plate."+x).show();
}


$(function(){
  $("input#edtin").keyup(function(){
    var x=$(this).val();  
    if(x.length==4){
      x="EDT"+x;
      $("p.beid").removeClass("focus");
      $("p.beid#"+x).addClass("focus");
      repInfo(x);
      $(this).val("");
    }
  });
});


function minheight(number) {
    if (number > 20 ){
            var height = (600 + (number-20)*3).toString()+"px";
            $('div#container').css("min-height", height);
    }
}

$(function() {  
    $('#submit_btn').click(function() {
	var request="&exp_id=";
	var table=new selectTable();
	$("p.beid.selected").each(function(){
		var bact=(this).id
		var additionClass=(this).getAttribute("bacteria_id");
		$("td.plate.selected."+additionClass).each(function(){
			var plate=(this).id;
			additionClass+="."+(this).getAttribute("plate_id");
			$("td.replicate.selected."+additionClass).each(function(){
				request+=(this).getAttribute("exp_id")+";";
				var obj=new dataObj((this).getAttribute("exp_id"),bact,plate,(this).id,(this).getAttribute("exp_date"));
				if($(this).hasClass("grouped"))
					table.addGroupMem(obj);
				else
					table.addIndMem(obj);	
			});
			
		});
	});
	request+="&well=";
	$("td.sel.selected").each(function(){
		request+=(this).getAttribute("wellid")+";";
	});
	console.log(table);
	console.log(request);
/*	var tempList=new selectList(); 
	var request="&request=";
	//start filling the selectList Object;
	$("p.beid.selected").each(function(){
		var bactId=(this).getAttribute("bacteria_id");
		var extId=(this).id;
		$("td.plate.selected."+extId).each(function(){
			var plateName=(this).id;
			var plateId=(this).getAttribute("plate_id");
			$("td.replicate.selected."+extId).each(function(){
				var expDate=(this).getAttribute("expdate");
				if($(this).hasClass("grouped"))
					tempList.addGroup(extId,plateName,expDate,(this).title);
				else
					tempList.addIndiv(extId,plateName,expDate,(this).title);
				request+=bactId+","+plateId+","+(this).title+";";
			});
		});		
	});	

	//wellList filling by selected wells	
	request+="&well=";
	$("td.sel.selected").each(function(){
		tempList.addWell((this).id);
		request+=(this).getAttribute("wellid")+";";
	});	
	console.log(tempList);

	console.log(request);*/
      });
});

function sendRequest(request){
	$.ajax({
            type: "POST",
            url: "view_pregraph.php",
            data: request,
            dataType: "json",
            success: function(dataObj) {
                //display message back to user here
                gengraph(dataObj,tempList,individualList,wellname);
            }
         });
}
