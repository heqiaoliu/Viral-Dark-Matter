<?php if (($l = $this->getColumnWidth('l'))): ?>
<!-- LEFT COLUMN--> 
<div id="ja-left" class="column sidebar" style="width:<?php echo $l ?>%">

	<?php 
	$pos = $this->getPositionName ('left-mass-top');
	if ($this->countModules($pos)): ?>
	<div class="ja-mass ja-mass-top clearfix">
		<jdoc:include type="modules" name="<?php echo $pos;?>" style="JArounded" />
	</div>
	<?php endif; ?>
	
	<?php
	$left1 = $this->getPositionName ('left1');
	$left2 = $this->getPositionName ('left2');
	$cls_left1 = $cls_left2 = "";
	if ($this->countModules("$left1 && $left2")) {
		$cls_left1 = "ja-left1";
		$cls_left2 = "ja-left2";
	}
	if ($this->countModules("$left1 + $left2")):
	?>
	<div class="ja-colswrap clearfix <?php echo $this->getColumnWidth('cls_l'); ?>">
	<?php if ($this->countModules($left1)): ?>
		<div class="ja-col <?php echo $cls_left1;?> column" style="width:<?php echo $this->getColumnWidth('l1')?>%">
			<jdoc:include type="modules" name="<?php echo $left1;?>" style="JArounded" />
		</div>
	<?php endif; ?>
	<?php if ($this->countModules($left2)): ?>
		<div class="ja-col <?php echo $cls_left2;?> column" style="width:<?php echo $this->getColumnWidth('l2')?>%">
			<jdoc:include type="modules" name="<?php echo $left2;?>" style="JArounded" />
		</div>
	<?php endif; ?>
	</div>
	<?php endif; ?>
	
	<?php 
	$pos = $this->getPositionName ('left-mass-bottom');
	if ($this->countModules($pos)): ?>
	<div class="ja-mass ja-mass-bottom clearfix">
		<jdoc:include type="modules" name="<?php echo $pos;?>" style="JArounded" />
	</div>
	<?php endif; ?>

</div>
<!-- //LEFT COLUMN--> 
<?php endif; ?>