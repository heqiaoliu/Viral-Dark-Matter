<?php 

function createEditSelect($divName, $width, $height, $tag_ids, $dbArr) {
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