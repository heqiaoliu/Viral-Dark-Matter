<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */
?>
<script type="text/javascript">
	/*fix height for middle area columns*/
	function fixColsHeight () {
		equalHeight (['ja-left', 'ja-main', 'ja-right']);
		fixHeight (['ja-right1', 'ja-right2'], ['ja-right'], ['ja-right-mass-top', 'ja-right-mass-bottom']);
		fixHeight (['ja-left1', 'ja-left2'], ['ja-left'], ['ja-left-mass-top', 'ja-left-mass-bottom']);
		fixHeight (['ja-current-content', 'ja-inset1', 'ja-inset2'],['ja-main'], ['ja-content-mass-top','ja-content-mass-bottom']);
		fixHeight (['ja-content-main'], ['ja-current-content'], ['ja-content-top', 'ja-content-bottom']);
	}
	window.addEvent ('load', function () {
		//fixColsHeight.delay (100, this);
		updateHeight.periodical(500);
	});
	
	function updateHeight () {
		if ($('ja-container')) {
			var newH = $('ja-container').getCoordinates().height;
			if (!this.oldH || this.oldH != newH) {
				fixColsHeight();
				//update newH after fix
				var newH = $('ja-container').getCoordinates().height;
				this.oldH = newH;
			}
		}
	}
</script>