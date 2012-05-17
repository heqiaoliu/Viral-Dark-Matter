<?php  
/*precsv.php functionally generate an temp csv file for user to download.

 */
        $temp=tempnam("../data/csv","csv");
	$buffer=$_POST['data'];
	$dataSet=explode(';',$buffer);
	$parseSet=Array();
	$indexSet;
	$height=0;
	for($i=0;$i<count($dataSet);$i++){	
	    $indexedArr=explode('-',$dataSet[$i]);
	    if(count($indexedArr)>1){
	        $setBuf=explode(",",$indexedArr[1]);
	        if(count($setBuf)>$height)
		    $height=count($setBuf);
	        if(array_key_exists($indexedArr[0],$parseSet))
		    $parseSet[$indexedArr[0]][]=$setBuf;
	        else{
		    $parseSet[$indexedArr[0]]=Array($setBuf);	
     	    	    $indexSet[]=$indexedArr[0];

		}
	    }
	}
	
	echo exec("chmod 755 $temp");       
        $file=fopen($temp,"w+");
	for($i=0;$i<$height+2;$i++){
		for($j=0;$j<count($indexSet);$j++){
			if(array_key_exists($indexSet[$j],$parseSet)){
				for($k=0;$k<count($parseSet[$indexSet[$j]]);$k++){
					if($i==0){
						if(ord($indexSet[$j])==42)
							fwrite($file,$indexSet[$j]);
						else{
							$rowOneTwo=explode(":",$indexSet[$j]);
							fwrite($file,$rowOneTwo[0].",");}
					}
					else if($i==1){
						if(ord($indexSet[$j])==42)
							fwrite($file,",");
						else{
							$rowOneTwo=explode(":",$indexSet[$j]);
							if(count($rowOneTwo)>1)
								fwrite($file,$rowOneTwo[1].",");
							else
								fwrite($file,",");
						}
					}

					else{
						if($i<count($parseSet[$indexSet[$j]][$k])+2)
							fwrite($file,$parseSet[$indexSet[$j]][$k][$i-2].",");	
						else
							fwrite($file,",");
					}
				}
			}
		}
		fwrite($file,"\r\n");
	}
	fclose($file);
	echo json_encode($temp);
?>
