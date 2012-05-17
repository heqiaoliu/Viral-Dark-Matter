<div id="ja-mainnav" class="wrap">
<div class="main clearfix">
	<?php if (($jamenu = $this->loadMenu())) $jamenu->genMenu ($this->getParam('startlevel',0), $this->getParam('endlevel',-1)); ?>
</div>
</div>

<?php if ($this->hasSubmenu() && ($jamenu = $this->loadMenu())) : ?>
<div id="ja-subnav" class="wrap">
<div class="main clearfix">
	<?php $jamenu->genMenu (1); ?>
</div>
</div>
<?php endif;?>

<ul class="no-display">
    <li><a href="<?php echo $this->getCurrentURL();?>#ja-content" title="<?php echo JText::_("Skip to content");?>"><?php echo JText::_("Skip to content");?></a></li>
</ul>
