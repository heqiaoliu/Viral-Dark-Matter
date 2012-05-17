<div id="ja-header" class="main clearfix">

	<div class="inner">
		<?php
		$siteName = $this->sitename();
		if ($this->getParam('logoType')=='image'): ?>
		<h1 class="logo">
			<a href="index.php" title="<?php echo $siteName; ?>"><span><?php echo $siteName; ?></span></a>
		</h1>
		<?php else:
		$logoText = (trim($this->getParam('logoType-text-logoText'))=='') ? $config->sitename : $this->getParam('logoType-text-logoText');
		$sloganText = (trim($this->getParam('logoType-text-sloganText'))=='') ? JText::_('SITE SLOGAN') : $this->getParam('logoType-text-sloganText');	?>
		<div class="logo-text">
			<h1><a href="index.php" title="<?php echo $siteName; ?>"><span><?php echo $logoText; ?></span></a></h1>
			<p class="site-slogan"><?php echo $sloganText;?></p>
		</div>
		<?php endif; ?>
		
		<?php if($this->countModules('search')) : ?>
		<div id="ja-search">
			<jdoc:include type="modules" name="search" />
		</div>
		<?php endif; ?>
	</div>

	<div class="ja-topbar clearfix">

		<p class="ja-day">
		  <?php 
			echo "<span class=\"day\">".date ('l')."</span>";
			echo "<span class=\"date\">, ".date ('M')." ".date ('d').date ('S')."</span>";
		  ?>
		</p>

		<p class="ja-updatetime"><span>Last update:</span><em>9:10 AM GMT</em></p>

	</div>
	
</div>
	