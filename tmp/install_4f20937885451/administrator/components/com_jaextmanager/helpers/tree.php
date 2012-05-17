<?php
define('JA_DTREE_IMG_PATH', 'components/'.JACOMPONENT.'/assets/dtree/img/');

jimport('joomla.filesystem.file');
jimport('joomla.filesystem.folder');
function printTreeConflicted($productInfo, $folder) {
	global $jauc;
	$product = $jauc->getProduct($productInfo);
	$str = _printTreeConflicted($product, 0, $folder, "");
	return $str;
}

function _printTreeConflicted($product, $parent, $folder, $path="") {
	static $treeNode = 0;
	static $aFolder = array();
	$exceptions = array('.', '..', 'jaupdater.comment.txt');
	if($parent == 0) {
		$treeNode = 0;
		$aFolder = array();
	}
	$md5CheckSums = new CheckSumsMD5();
	
	$str =  "";
	// Root node
	if($parent == 0) {
        $str .= "var d = new dTree('d'); \r\n";
		$str .= "d.add(0,-1,' <a href=\'javascript: d.openAll();\' style=\'color:black\'>[Open all]<\/a> <a href=\'javascript: d.closeAll();\' style=\'color:black\'>[Close all]<\/a>', '#', ''); \r\n";
	}
	
	$handle = opendir($folder);
	$found = false;
	while (($entry = readdir($handle)) !== false) {
		if(!in_array($entry, $exceptions)) {
			$found = true;
			$treeNode++;
			$item = $folder . $entry;
			if( JFolder::exists($item) ){
				$str .=  "d.add(".$treeNode.",".$parent.",' ".$entry."','#', 'folder'); \r\n";
				$aFolder[$treeNode] = array();
				$aFolder[$treeNode]['parent'] = $parent;
				$str .= _printTreeConflicted($product, $treeNode, $item . DS, $path . $entry . "/");
			}else{
				$location = $path . $entry;
				$fileLive = $product->getFilePath($location);
				if(JFile::exists($fileLive)) {
					$status = ($md5CheckSums->getCheckSum($item) == $md5CheckSums->getCheckSum($fileLive)) ? "solved" : "bmodified";
				}
				$str .=  "d.add(".$treeNode.",".$parent.",' ".$entry."','#', '".$location."', '', '".JA_DTREE_IMG_PATH."icon_".$status.".gif','',0,'dtree_status_".$status."'); \r\n";
				$aFolder[$parent]['status'][$status] = $status;
				$aFolder[$treeNode]['status'][$status] = $status;
			}
			
		}
	}
	closedir($handle);
	
	if(!$found) {
		//folder is empty
		$aFolder[$parent]['status']['empty'] = 'empty';
		$aFolder[$treeNode]['status']['empty'] = 'empty';
	}
	
	if($parent == 0) {
		$str .= printNodeAsArray($treeNode, $aFolder);
	}
	return $str;
}


function printChildNode($data){
	$str = _printChildNode(0, $data, "");
	return $str;
}
function _printChildNode($parent, $data, $path=""){
	static $treeNode = 0;
	static $aFolder = array();
	if($parent == 0) {
		$treeNode = 0;
		$aFolder = array();
	}
	
	$str =  "";
	// Root node
	if($parent == 0) {
        $str .= "var d = new dTree('d'); \r\n";
		$str .= "d.add(0,-1,' <a href=\'javascript: d.openAll();\' style=\'color:black\'>[Open all]<\/a> <a href=\'javascript: d.closeAll();\' style=\'color:black\'>[Close all]<\/a>', '#', ''); \r\n";
	}
	
	// Branch node
	foreach ($data as $k=>$item){
		$treeNode++;
		if( is_object($item) ){
			$str .=  "d.add(".$treeNode.",".$parent.",' ".$k."','#', 'folder'); \r\n";
			$aFolder[$treeNode] = array();
			$aFolder[$treeNode]['parent'] = $parent;
			$str .= _printChildNode($treeNode, $item, $path . $k . "/");
		}else{
			$location = $path . $k;
			$str .=  "d.add(".$treeNode.",".$parent.",' ".$k."','#', '".$location."', '', '".JA_DTREE_IMG_PATH."icon_".$item.".gif','',0,'dtree_status_".$item."'); \r\n";
			$aFolder[$parent]['status'][$item] = $item;
			$aFolder[$treeNode]['status'][$item] = $item;
		}
	}
	if($parent == 0) {
		$str .= printNodeAsArray($treeNode, $aFolder);
	}
	return $str;
}

function printNodeAsArray($treeNode, $aFolder) {
	$str = "";
	$strFolder = "var aTreeFolderStatus = new Array(); \r\n";
	$strFile = "var aTreeFileStatus = new Array(); \r\n";
	$aStatus = array();//for folders
	$aStatus2 = array();//for files
	for($i = $treeNode; $i>=0; $i--) {
		if(isset($aFolder[$i])) {
			if(isset($aFolder[$i]['status'])) {
				if(isset($aFolder[$i]['parent'])) {
					foreach($aFolder[$i]['status'] as $status) {
						$aStatus[$status][] = $i;
					}
					if(isset($aFolder[$aFolder[$i]['parent']])){
						foreach($aFolder[$i]['status'] as $status) {
							$aFolder[$aFolder[$i]['parent']]['status'][$status] = $status;
						}
					}
				} else {
					foreach($aFolder[$i]['status'] as $status) {
						$aStatus2[$status][] = $i;
					}
				}
			}
		}
	}
	
	if(count($aStatus) > 0) {
		foreach($aStatus as $status => $ids) {
			$strFolder .= "aTreeFolderStatus['{$status}'] = [".implode(',', $ids)."]; \r\n";
		}
	}
	if(count($aStatus2) > 0) {
		foreach($aStatus2 as $status => $ids) {
			$strFile .= "aTreeFileStatus['{$status}'] = [".implode(',', $ids)."]; \r\n";
		}
	}
	
	
    $str .= "var numTreeNode = ".$treeNode."; \r\n";
	$str .= "document.write(d); \r\n";
	$str .= "d.openAll(); \r\n";
	$str .= $strFolder;
	$str .= $strFile;
	return $str;
}
?>