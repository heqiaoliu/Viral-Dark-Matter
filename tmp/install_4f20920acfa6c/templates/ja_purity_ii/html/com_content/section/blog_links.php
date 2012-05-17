<?php
/*
# ------------------------------------------------------------------------
# Ja Purity ii template for joomla 1.5
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/


defined('_JEXEC') or die('Restricted access');
?>

<div class="blog_more">
	<h2><?php echo JText::_('More Articles...'); ?></h2>
	<ul class="blogsection">
		<?php foreach ($this->links as $link) : ?>
		<li>
			<a href="<?php echo JRoute::_(ContentHelperRoute::getArticleRoute($link->slug, $link->catslug, $link->sectionid)); ?>">
				<?php echo $this->escape($link->title); ?></a>
		</li>
		<?php endforeach; ?>
	</ul>
</div>
