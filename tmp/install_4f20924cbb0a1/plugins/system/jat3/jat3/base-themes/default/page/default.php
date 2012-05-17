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
<?php if ($this->isIE() && ($this->isRTL())) { ?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<?php } else { ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<?php } ?>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $this->language; ?>" lang="<?php echo $this->language; ?>">

<head>
	<?php //gen head base on theme info
	$this->showBlock ('head');
	?>

	<?php
	$blocks = T3Common::node_children($this->getBlocksXML ('head'), 'block');
	foreach ($blocks as $block) :
		$this->showBlock ($block); 
	endforeach; 
	?>
	
	<?php echo $this->showBlock ('css') ?>
</head>

<body id="bd" class="<?php if (!T3Common::mobile_device_detect()):?>bd<?php endif;?> <?php echo $this->getBodyClass();?>">
<div id="ja-wrapper">
	<a name="Top" id="Top"></a>
	
	<?php
	$blks = &$this->getBlocksXML ('top');
	$blocks = &T3Common::node_children($blks, 'block');
	foreach ($blocks as $block) :
		$this->showBlock ($block); 
	endforeach; 
	?>

	<!-- MAIN CONTAINER -->
	<div id="ja-container" class="wrap <?php echo $this->getColumnWidth('cls_w')?$this->getColumnWidth('cls_w'):'ja-mf'; ?>">
	<?php $this->genBlockBegin ($this->getBlocksXML ('middle')) ?>
		<div id="ja-mainbody" style="width:<?php echo $this->getColumnWidth('mw') ?>%">
			<!-- CONTENT -->
			<div id="ja-main" style="width:<?php echo $this->getColumnWidth('m') ?>%">
			<div class="inner clearfix">
				
				<?php echo $this->loadBlock ('message') ?>

				<?php 
				//content-mass-top
				if($this->hasBlock('content-mass-top')) : 
				$block = &$this->getBlockXML ('content-mass-top');
				?>
				<div id="ja-content-mass-top" class="ja-mass ja-mass-top clearfix">
					<?php $this->showBlock ($block); ?>
				</div>
				<?php
				 
				endif; ?>

				<div id="ja-contentwrap" class="clearfix <?php echo $this->getColumnWidth('cls_m'); ?>">
					<div id="ja-content" class="column" style="width:<?php echo $this->getColumnWidth('cw') ?>%">
						<div id="ja-current-content" class="column" style="width:<?php echo $this->getColumnWidth('c') ?>%">
							<?php 
							//content-top
							if($this->hasBlock('content-top')) : 
							$block = &$this->getBlockXML ('content-top');							
							?>
							<div id="ja-content-top" class="ja-content-top clearfix">
								<?php $this->showBlock ($block); ?>
							</div>
							<?php endif; ?>
							
							<?php if (!$this->getParam ('hide_content_block', 0)): ?>
							<div id="ja-content-main" class="ja-content-main clearfix">
								<?php echo $this->showBlock ('content') ?>
							</div>
							<?php endif ?>

							<?php 
							//content-bottom
							if($this->hasBlock('content-bottom')) : 
							$block = &$this->getBlockXML ('content-bottom');
							?>
							<div id="ja-content-bottom" class="ja-content-bottom clearfix">
								<?php $this->showBlock ($block); ?>
							</div>
							<?php endif; ?>
						</div>
						
						<?php 
						//inset1
						if($this->hasBlock('inset1')) : 
						$block = &$this->getBlockXML ('inset1');
						?>
						<div id="ja-inset1" class="ja-col column ja-inset1" style="width:<?php echo $this->getColumnWidth('i1') ?>%">
							<?php $this->showBlock ($block); ?>
						</div>
						<?php endif; ?>
					</div>

					<?php 
					//inset2
					if($this->hasBlock('inset2')) : 
					$block = &$this->getBlockXML ('inset2');
					?>
					<div id="ja-inset2" class="ja-col column ja-inset2" style="width:<?php echo $this->getColumnWidth('i2') ?>%">
						<?php $this->showBlock ($block); ?>
					</div>
					<?php endif; ?>
					
				</div>

				<?php 
				//content-mass-bottom
				if($this->hasBlock('content-mass-bottom')) : 
				$block = &$this->getBlockXML ('content-mass-bottom');
				?>
				<div id="ja-content-mass-bottom" class="ja-mass ja-mass-bottom clearfix">
					<?php $this->showBlock ($block); ?>
				</div>
				<?php endif; ?>
			</div>
			</div>
			<!-- //CONTENT -->
			<?php if (($l = $this->getColumnWidth('l'))): ?>
			<!-- LEFT COLUMN--> 
			<div id="ja-left" class="column sidebar" style="width:<?php echo $l ?>%">
				<?php 
				//left-mass-top
				if($this->hasBlock('left-mass-top')) : 
				$block = &$this->getBlockXML ('left-mass-top');
				?>
				<div id="ja-left-mass-top" class="ja-mass ja-mass-top clearfix">
					<?php $this->showBlock ($block); ?>
				</div>
				<?php endif; ?>

				<?php
				$cls1 = $cls2 = "";
				if ($this->hasBlock('left1') && $this->hasBlock('left2')) {
					$cls1 = "ja-left1";
					$cls2 = "ja-left2";
				}
				if ($this->hasBlock('left1') || $this->hasBlock('left2')):
				?>
				<div class="ja-colswrap clearfix <?php echo $this->getColumnWidth('cls_l'); ?>">
				<?php if ($this->hasBlock('left1')):
					$block = &$this->getBlockXML('left1'); 
				?>
					<div id="ja-left1" class="ja-col <?php echo $cls1;?> column" style="width:<?php echo $this->getColumnWidth('l1')?>%">
						<?php $this->showBlock ($block); ?>				
					</div>
				<?php endif ?>

				<?php if ($this->hasBlock('left2')): 
					$block = &$this->getBlockXML('left2'); 
				?>
					<div id="ja-left2" class="ja-col <?php echo $cls2;?> column" style="width:<?php echo $this->getColumnWidth('l2')?>%">
						<?php $this->showBlock ($block); ?>				
					</div>
				<?php endif ?>
				</div>
				<?php endif ?>
				<?php 
				//left-mass-bottom
				if($this->hasBlock('left-mass-bottom')) : 
				$block = &$this->getBlockXML ('left-mass-bottom');
				?>
				<div id="ja-left-mass-bottom" class="ja-mass ja-mass-bottom clearfix">
					<?php $this->showBlock ($block); ?>
				</div>
				<?php endif; ?>
			</div>
			<!-- //LEFT COLUMN--> 
			<?php endif; ?>
			
		</div>
		<?php if (($r = $this->getColumnWidth('r'))): ?>
		<!-- RIGHT COLUMN--> 
		<div id="ja-right" class="column sidebar" style="width:<?php echo $r ?>%">

			<?php 
			//left-mass-top
			if($this->hasBlock('right-mass-top')) : 
			$block = &$this->getBlockXML ('right-mass-top');
			?>
			<div id="ja-right-mass-top" class="ja-mass ja-mass-top clearfix">
				<?php $this->showBlock ($block); ?>
			</div>
			<?php endif; ?>

			<?php
			$cls1 = $cls2 = "";
			if ($this->hasBlock('right1') && $this->hasBlock('right2')) {
				$cls1 = "ja-right1";
				$cls2 = "ja-right2";
			}
			if ($this->hasBlock('right1') || $this->hasBlock('right2')): ?>
			<div class="ja-colswrap clearfix <?php echo $this->getColumnWidth('cls_r'); ?>">
				<?php if ($this->hasBlock('right1')):
				$block = &$this->getBlockXML('right1'); 
				?>
				<div id="ja-right1" class="ja-col <?php echo $cls1;?> column" style="width:<?php echo $this->getColumnWidth('r1')?>%">
					<?php $this->showBlock ($block); ?>					
				</div>
				<?php endif ?>

				<?php if ($this->hasBlock('right2')): 
				$block = &$this->getBlockXML('right2'); 
				?>
				<div id="ja-right2" class="ja-col <?php echo $cls2;?> column" style="width:<?php echo $this->getColumnWidth('r2')?>%">
					<?php $this->showBlock ($block); ?>					
				</div>
				<?php endif ?>
			</div>
			<?php endif ?>
			<?php 
			//right-mass-bottom
			if($this->hasBlock('right-mass-bottom')) : 
			$block = &$this->getBlockXML ('right-mass-bottom');
			?>
			<div id="ja-right-mass-bottom" class="ja-mass ja-mass-bottom clearfix">
				<?php $this->showBlock ($block); ?>
			</div>
			<?php endif; ?>
		</div>
		<!-- //RIGHT COLUMN--> 
		<?php endif; ?>
	<?php $this->genBlockEnd ($this->getBlocksXML ('middle')) ?>
	</div>
	<?php 
	//Add fix height for main area
	if (T3Common::node_attributes ($this->getBlocksXML ('middle'), 'fixheight')) {
		$this->showBlock ('fixheight');
	}
	?>
	<!-- //MAIN CONTAINER -->

	<?php
	$blks = &$this->getBlocksXML ('bottom');
	$blocks = &T3Common::node_children($blks, 'block');
	foreach ($blocks as $block) :
		if (T3Common::getBrowserSortName() == 'ie' && T3Common::getBrowserMajorVersion() == 7) echo "<br class=\"clearfix\"/>";
		$this->showBlock ($block); 
	endforeach; 
	?>

</div>

<?php if ($this->isIE6()) : ?>
	<?php $this->showBlock('ie6/ie6warning') ?>
<?php endif; ?>

<?php $this->showBlock('debug') ?>

</body>

</html>