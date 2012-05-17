<?php
/*
#------------------------------------------------------------------------
  JA Purity II for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


// no direct access
defined('_JEXEC') or die('Restricted access');  ?>
<span class="breadcrumbs pathway">
<?php 
$start = $count > 1?1:0;
for ($i = $start; $i < $count; $i ++) :
	
	//Parse title and remove the options & description which configure for mega menu.
	$title = $list[$i]->name;
	$title = str_replace (array('\\[','\\]'), array('%open%', '%close%'), $title);
	$regex = '/([^\[]*)\[([^\]]*)\](.*)$/';
	if (preg_match ($regex, $title, $matches)) {
		$title = $matches[1];
	} else {
		$title = $title;
	}
	$title = str_replace (array('%open%', '%close%'), array('[',']'), $title);
	$name = $title;
	
	// If not the last item in the breadcrumbs add the separator
	if ($i < $count -1) {
		if(!empty($list[$i]->link)) {
			echo '<a href="'.$list[$i]->link.'" class="pathway">'.$name.'</a>';
		} else {
			echo '<span class="name">'.$name.'</span>';
		}
		echo ' '.$separator.' ';
	}  else if ($params->get('showLast', 1)) { // when $i == $count -1 and 'showLast' is true
	    echo '<span class="name">'.$name.'</span>';
	}
endfor; ?>
</span>