<?php
/*$Id jaDiffTool.php v1.0.0 2010-03-31 thanhnv Exp*/

class jaDiffTool
{
	var $objLeft;
	var $objRight;
	
	//code lines of version 1
	var $aLineLeft = array();
	var $aLineLeftOriginal = array();
	
	//code lines of version 2
	var $aLineRight = array();
	var $aLineRightOriginal = array();
	
	var $totalLineLeft = 0;
	var $totalLineRight = 0;
	
	var $debug = false;
	//join all near lines with same status to group
	var $aGroup = array();
	var $aMerged = array();
	//total line after merged two versions
	var $totalLine = 0;
	//if percent of match between two line is large than xx% => two lines is the same line
	var $allowPercent = 50;
	
	//2010-10-04
	/**
	 * Vietnamese:
	 * dung de tang do chinh xac khi tim 2 dong khop voi nhau,
	 * khi tim duoc mot dong gan giong voi dong can so sanh, tiep tuc tim kiem xem co dong nao gan giong voi dong da cho hon ko,
	 * neu tim thay thi se chon dong moi do
	 *
	 * $allowPercentSafe must be larger than $allowPercent, and should be larger than 90
	 * @var unknown_type
	 */
	var $allowPercentSafe = 90;
	
	//so luong dong tiep theo can check trong giai thuat tim dong chua LCS (longest common sub-string)
	var $numNextLinesCheck = 5;
	
	
	function jaDiffTool() {
	}
	
	function buildObject($title, $file, $content, $editabled=0) {
		$obj = new stdClass();
		$obj->title = $title;
		$obj->file = $file;
		$obj->content = $content;
		$obj->editabled = $editabled;
		return $obj;
	}
	
	function compare($objLeft, $objRight, $mode = 'string') {
		$this->objLeft = $objLeft;
		$this->objRight = $objRight;
		if($mode == 'file') {
			if(JFile::exists($objLeft->file)) {
				$objLeft->content = file_get_contents($objLeft->file);
			} else {
				$objLeft->content = '';
			}
			
			
			if(JFile::exists($objRight->file)) {
				$objRight->content = file_get_contents($objRight->file);
			} else {
				$objRight->content = '';
			}
			
		}
		$result = $this->diffString($objLeft->content, $objRight->content);
		
		$objLeft->result = $result['sideLeft'];
		$objRight->result = $result['sideRight'];
		
		$info = new stdClass();
		$info->left = $objLeft;
		$info->right = $objRight;
		return $info;
	}
	
	function diffFiles($fileLeft, $fileRight) {
		if(JFile::exists($fileLeft) && JFile::exists($fileRight)) {
			$strLeft = file_get_contents($fileLeft);
			$strRight = file_get_contents($fileRight);
			$result = $this->diffString($strLeft, $strRight);
			$result['fileLeft'] = $fileLeft;
			$result['fileRight'] = $fileRight;	
			return $result;
		} else {
			return false;
		}
	}
	
	function diffString($strLeft, $strRight) {
		$this->_prepareContent($strLeft, $strRight);
		//return false;
		
		$this->totalLineLeft = count($this->aLineLeft);
		$this->totalLineRight = count($this->aLineRight);
		
		$aMerged = array();
		$cntLeft=0;
		$cntRight=0;
		//compare two lines between two version
		while ($cntLeft < $this->totalLineLeft && $cntRight < $this->totalLineRight) {
			/*if(empty($this->aLineLeft[$cntLeft])) {
				//skip blank line
				$this->addLine("blank", "", "", $cntLeft, $cntRight);
				$cntLeft++;
				if(empty($this->aLineRight[$cntRight])) {
					$cntRight++;
				}
			}*/
			if($this->matchedString($this->aLineLeft[$cntLeft], $this->aLineRight[$cntRight])) {
				//nochange
				$this->addLine("nochange", $this->aLineLeftOriginal[$cntLeft], $this->aLineRightOriginal[$cntRight], $cntLeft, $cntRight);
				$cntLeft++;
				$cntRight++;
			} else {
				//$matchLine = $this->_findMostLikeLine($this->aLineLeft[$cntLeft], $cntRight, $this->totalLineRight);
				$matchLine = $this->_findMostLikeLineSafe($cntLeft, $cntRight, $this->totalLineRight);
				if($matchLine === false) {
					//this line was removed
					$this->addLine("removed", $this->aLineLeftOriginal[$cntLeft], "", $cntLeft, $cntRight);
					$cntLeft++;
				} else {
					
					//from $cntRight to $matchLine is added lines on new version
					for($i = $cntRight; $i<$matchLine['line']; $i++) {
						$this->addLine("new", $this->aLineRightOriginal[$i], "", $cntLeft, $i);
					}
					//modified line at $matchLine
					$status = $matchLine['percent'] == 100 ? "nochange" : "modified";
					$this->addLine($status, $this->aLineLeftOriginal[$cntLeft], $this->aLineRightOriginal[$matchLine['line']], $cntLeft, $matchLine['line']);
					//
					$cntRight = $matchLine['line']+1;
					$cntLeft++;
				}
			}
		}
		
		if($cntLeft < $this->totalLineLeft) {
			//if right side is reached end line
			//=> all remain lines of left side are removed lines
			for($i = $cntLeft; $i< $this->totalLineLeft; $i++) {
				$this->addLine("removed", $this->aLineLeftOriginal[$i], '', $i, $cntRight);
			}
		} elseif($cntRight < $this->totalLineRight) {
			//otherwise, if left side is reached end line
			//=> all remain lines of left side are new lines
			for($i = $cntRight; $i<$this->totalLineRight; $i++) {
				$this->addLine("new", '', $this->aLineRightOriginal[$i], $cntLeft, $i);
			}
		}
		$this->totalLine = count($this->aMerged);
		
		return $this->_displayDiff();
	}
	
	/**
	 * Vietnamese:
	 * neu dong cua version ben trai trung voi dong cua version ben phai,
	 * nhung dong tiep theo cua version ben trai lai trung 1 dong cua version ben phai co so thu tu nho hon,
	 * => dong tren cua version ben trai da bi xoa
	 * English:
	 * if the line of left version (lineL1) is matched with one line on right version (called lineR1),
	 * But the next lines (@link $numNextLinesCheck) of left version is matched with one line on right version (called lineR2) too
	 * and lineR2 is lower than lineR1 (compare about line number)
	 * Thus, the lineL1 is removed in right version
	 *
	 * @param unknown_type $lineLeft
	 * @param unknown_type $start
	 * @param unknown_type $limit
	 * @return unknown
	 */
	function _findMostLikeLineSafe($lineLeft, $start, $limit) {
		$lineRight = $this->_findMostLikeLine($lineLeft, $start, $limit);
		if($lineRight === false) {
			return false;
		} else {
			$numLines = 0;
			for($i = $lineLeft+1; $i < $this->totalLineLeft; $i++) {
				if(!empty($this->aLineLeft[$i])) {
					$numLines++;
					$lineRight2 = $this->_findMostLikeLine($i, $start, $lineRight['line']+1);
					if($lineRight2 !== false && ($lineRight2['percent'] > $lineRight['percent']) && ($lineRight2['percent'] > $this->allowPercentSafe)) {
						/*$str = $this->_trimContent($this->aLineLeft[$lineLeft]);
						if((strlen($str) <= 3 ) || ($lineRight2['percent'] > $lineRight['percent']))  {
							return false;
						}*/
						return false;
					}
					if($numLines >= $this->numNextLinesCheck) {
						break;
					}
				}
			}
		}
		return $lineRight;
	}
	
	
	/**
	 * _findMostLikeLine
	 * @desc this method is used to find a line that have longest common sub-string (LCS) with given string
	 *
	 * @param unknown_type $str
	 * @param mix $pos (position of line was found, or false if not found=> line was remove)
	 */
	function _findMostLikeLine($lineLeft, $start, $limit) {
		$str = $this->aLineLeft[$lineLeft];
		$matchChars = 0;
		$result = false;
		for($i=$start; $i<$limit; $i++) {
			if($this->matchedString($str, $this->aLineRight[$i])) {
				return array('line' => $i, 'percent' => 100);
			} else {
				$percent = $this->_findLongestCommonString($str, $this->aLineRight[$i]);
				
				if ($percent > $this->allowPercent) {
					if(!$result) {
						$result = array('line' => $i, 'percent' => $percent);
						/*if($percent > $this->allowPercentSafe) {
							return $result;
						}*/
					} else {
						if($percent > $result['percent'] && $percent > $this->allowPercentSafe) {
							//tim thay mot dong khac giong voi dong ben trai hon
							$result = array('line' => $i, 'percent' => $percent);
						}
					}
				}
			}
		}
		return $result;
		
	}
	
	function addLine($status, $contentLeft, $contentRight, $currLineLeft, $currLineRight) {
		//fix line to start from 1
		$currLineLeft++;
		$currLineRight++;
		$this->aMerged[] = array(
			"status"=>$status, 
			"contentLeft"=>htmlentities($contentLeft), 
			"contentRight"=>htmlentities($contentRight), 
			"line1"=>str_pad($currLineLeft, 3, '0', STR_PAD_LEFT),
			"line2"=>str_pad($currLineRight, 3, '0', STR_PAD_LEFT));
	}
	
	function _displayDiff() {
		//rebuild versions
		$sHtmlVerLeft = "";
		$sHtmlVerRight = "";
		$cnt = 0;
		$lineFormat = "<pre id=\"%s\" class=\"%s\"><span class=\"%s\">&nbsp;</span><span class=\"line\">%s</span>%s</pre>";
		
		//group lines
		$status = "";
		for($cnt = 1; $cnt <= $this->totalLine; $cnt++) {
			$line = $this->aMerged[$cnt-1];
			if($line["status"] != $status) {
				$status = $line["status"];
				$this->aGroup[$cnt] = 1;
			}
		}
		for($cnt = 1; $cnt <= $this->totalLine; $cnt++) {
			$line = $this->aMerged[$cnt-1];
			
			switch ($line["status"]) {
				/*case 'blank':
					$sHtmlVerLeft .= $this->_displayLine('left', $cnt, $line['line1'], 'blank');
					$sHtmlVerRight .= $this->_displayLine('right', $cnt, '', 'noexists');
					break;*/
				case 'nochange':
					$sHtmlVerLeft .= $this->_displayLine('left', $cnt, $line['line1'], 'nochange', $line['contentLeft']);
					$sHtmlVerRight .= $this->_displayLine('right', $cnt, $line['line2'], 'nochange', $line['contentRight']);
					break;
				case 'new':
					$sHtmlVerLeft .= $this->_displayLine('left', $cnt, '', 'noexists');
					$sHtmlVerRight .= $this->_displayLine('right', $cnt, $line['line2'], 'new', $line['contentLeft']);
					break;
				case 'removed':
					$sHtmlVerLeft .= $this->_displayLine('left', $cnt, $line['line1'], 'removed', $line['contentLeft']);
					$sHtmlVerRight .= $this->_displayLine('right', $cnt, '', 'noexists');
					break;
				case 'modified':
					$sHtmlVerLeft .= $this->_displayLine('left', $cnt, $line['line1'], 'modified', $line['contentLeft']);
					$sHtmlVerRight .= $this->_displayLine('right', $cnt, $line['line2'], 'modified', $line['contentRight']);
					break;
			}
			$sHtmlVerLeft .= "\r\n";
			$sHtmlVerRight .= "\r\n";
		}
		return array('sideLeft' => $sHtmlVerLeft, 'sideRight' => $sHtmlVerRight);
	}
	
	/**
	 * Enter description here...
	 *
	 * @param string $side - left or right
	 * @param int $id - line is using for both version
	 * @param int $line - original line of each version
	 * @param string $status - status of line
	 * @param string $content - content of line
	 * @return unknown
	 */
	function _displayLine($side, $id, $line, $status, $content = ' ') {
		$lineId = "line-{$side}-{$id}";
		
		if(isset($this->aGroup[$id])) {
			//find end of group
			$end = $id + 1;
			while (!isset($this->aGroup[$end]) && $end <= $this->totalLine) {
				$end++;
			}
			$end--;
			
			$action = " onmouseover=\"jaDiffActiveGroup({$id},{$end});\"";
			$action .= " onmouseout=\"jaDiffInactiveGroup({$id},{$end});\"";
			if($side == 'right') {
				if($this->objLeft->editabled) {
					$action .= " onclick=\"jaDiffCopyToLeft({$id},{$end});\"";
					$actionCss = 'copyToLeft';
					$actionTitle = 'copy to left';
				} else {
					$actionCss = 'copyToLeftDisabled';
					$actionTitle = 'copy to left is disabled';
				}
			} else {
				if($this->objRight->editabled) {
					$action .= " onclick=\"jaDiffCopyToRight({$id},{$end});\"";
					$actionCss = 'copyToRight';
					$actionTitle = 'copy to right';
				} else {
					$actionCss = 'copyToRightDisabled';
					$actionTitle = 'copy to right is disabled';
				}
			}
		} else {
			$action = "";
			$actionCss = (isset($this->aGroup[$id+1]) || ($id == $this->totalLine)) ? 'copyJoinBottom' : 'copyJoin';
			$actionTitle = '';
		}
		$sLine = ($status == 'noexists') ? "<span class=\"line\">---</span>" : "<span class=\"line\">{$line}</span>";
		return "<pre id=\"{$lineId}\" class=\"{$status}\"><span class=\"{$actionCss}\" title=\"{$actionTitle}\" {$action}>&nbsp;</span>{$sLine}<span class=\"content\">{$content}</span></pre>";
	}
	
	function matchedString($strLeft, $strRight) {
		$strLeft = $this->_trimContent($strLeft);
		$strRight = $this->_trimContent($strRight);
		return ($strLeft == $strRight);
	}
	
	/**
	 * Modify from this function (below link)
	 * http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_substring
	 *
	 * @param unknown_type $strLeft
	 * @param unknown_type $strRight
	 * @return unknown
	 */
	function _findLongestCommonString($strLeft, $strRight) {
		$strLeft = $this->_trimContent($strLeft);
		$strRight = $this->_trimContent($strRight);
		
		$m = strlen($strLeft);
		$n = strlen($strRight);
		$L = array();
		$z = 0;
		$ret = array();
	 
		for($i=0; $i<$m; $i++){
			$L[$i] = array();
			for($j=0; $j<$n; $j++){
				$L[$i][$j] = 0;
			}
		}
	 
		for($i=0; $i<$m; $i++){
			for($j=0; $j<$n; $j++){
				if( $strLeft[$i] == $strRight[$j] ){
					$L[$i][$j] = (isset($L[$i-1][$j-1])) ? $L[$i-1][$j-1] + 1 : 1;
					
					if( $L[$i][$j] > 2){
						$z = $L[$i][$j];
						//$ret = array();
					}
					if( $L[$i][$j] == $z ) {
						$start = $i-$z+1;
						$len = $z;
						$end = $start + $len;
						$sub = substr($strLeft, $start, $len);
						//xoa nhung chuoi con trong mang cac chuoi da tim thay
						//ma la mot phan cua chuoi vua tim dc
						$aTemp = array();
						foreach ($ret as $aSub) {
							if(!(($aSub['start']>=$start) && ($aSub['end'] <= $end) && (strpos($sub, $aSub['str']) !== false))) {
								$aTemp[] = $aSub;
							}
						}
						$ret = $aTemp;
						$ret[] = array('start' => $start, 'end' => $end, 'str' => $sub);
						unset($aTemp);
					}
				}
			}
		}
		//print_r($ret);
		
		if(count($ret) == 0) {
			return false;
		} else {
			$total = 0;
			foreach ($ret as $aSub) {
				$total += $aSub['end'] - $aSub['start'];
			}
			$percent = intval(($total * 100)/strlen($strLeft));
			if(($percent >= 100) && (count($ret) > 1)) {
				//thanhnv: is not really 100% matched :)
				$percent = 99;
			}
			return $percent;
		}
	}
	
	function _prepareContent($strLeft, $strRight) {
		
		/*$strLeft = preg_replace("/\t|\s/", " ", $strLeft);
		$strRight = preg_replace("/\t|\s/", " ", $strRight);
		
		die(htmlentities($strLeft));*/
		
		$strLeft = preg_replace("/\r\n|\n/", "\n", $strLeft);
		$strRight = preg_replace("/\r\n|\n/", "\n", $strRight);
		
		$this->aLineLeft = explode("\n", $strLeft);
		$this->aLineRight = explode("\n", $strRight);
		$this->aLineLeftOriginal = $this->aLineLeft;
		$this->aLineRightOriginal = $this->aLineRight;
		
		for($i=0; $i< $this->totalLineLeft; $i++) {
			$this->aLineLeft[$i] = $this->_trimContent($this->aLineLeft[$i], " ");
		}
		for($i=0; $i< $this->totalLineRight; $i++) {
			$this->aLineRight[$i] = $this->_trimContent($this->aLineRight[$i], " ");
		}
	}
	
	function _trimContent($str, $replace = "") {
		return preg_replace("/\s|\t/", "", $str);
	}
}

?>