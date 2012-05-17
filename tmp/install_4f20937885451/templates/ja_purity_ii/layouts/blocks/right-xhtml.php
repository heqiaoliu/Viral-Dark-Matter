<?php if (($r = $this->getColumnWidth('r'))): ?>
<!-- RIGHT COLUMN--> 
<div id="ja-right" class="column sidebar" style="width:<?php echo $r ?>%">

	<?php 
	$pos = $this->getPositionName ('right-mass-top');
	if ($this->countModules($pos)): ?>
	<div class="ja-mass ja-mass-top clearfix">
		<jdoc:include type="modules" name="<?php echo $pos;?>" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php
	$right1 = $this->getPositionName ('right1');
	$right2 = $this->getPositionName ('right2');
	$cls_right1 = $cls_right2 = "";
	if ($this->countModules("$right1 && $right2")) {
		$cls_right1 = "ja-right1";
		$cls_right2 = "ja-right2";
	}
	if ($this->countModules("$right1 + $right2")):
	?>
	<div class="ja-colswrap clearfix <?php echo $this->getColumnWidth('cls_r'); ?>">

	<?php if ($this->countModules($right1)): ?>
		<div class="ja-col <?php echo $cls_right1;?> column" style="width:<?php echo $this->getColumnWidth('r1')?>%">
			<jdoc:include type="modules" name="<?php echo $right1;?>" style="JAxhtml" />
		</div>
	<?php endif; ?>

	<?php if ($this->countModules($right2)): ?>
		<div class="ja-col <?php echo $cls_right2;?> column" style="width:<?php echo $this->getColumnWidth('r2')?>%">
			<jdoc:include type="modules" name="<?php echo $right2;?>" style="JAxhtml" />
		</div>
	<?php endif; ?>

	</div>
	<?php endif; ?>

	<?php 
	$pos = $this->getPositionName ('right-mass-bottom');
	if ($this->countModules($pos)): ?>
	<div class="ja-mass ja-mass-bottom clearfix">
		<jdoc:include type="modules" name="<?php echo $pos;?>" style="JAxhtml" />
	</div>
	<?php endif; ?>

</div>
<!-- RIGHT COLUMN--> 
<?php endif; ?>