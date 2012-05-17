<?php


defined( '_JEXEC' ) or die( 'Restricted access' );
?>

<h3>
	<?php echo $this->escape($this->message->title); ?>
</h3>

<p class="message">
	<?php echo $this->escape($this->message->text); ?>
</p>
