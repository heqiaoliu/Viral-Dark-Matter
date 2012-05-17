<?php
/** $Id: default_address.php 12387 2009-06-30 01:17:44Z ian $ */
defined( '_JEXEC' ) or die( 'Restricted access' );
?>
<?php if ( ( $this->contact->params->get( 'address_check' ) > 0 ) &&  ( $this->contact->address || $this->contact->suburb  || $this->contact->state || $this->contact->country || $this->contact->postcode ) ) : ?>
<div class="jcontact-address">
<?php if ( $this->contact->params->get( 'address_check' ) > 0 ) : ?>
	<span class="jicons-icons" >
		<?php echo $this->contact->params->get( 'marker_address' ); ?>
	</span>
	<address>
<?php endif; ?>
<?php if ( $this->contact->address && $this->contact->params->get( 'show_street_address' ) ) : ?>
	<span class="jcontact-street">
		<?php echo nl2br($this->escape($this->contact->address)); ?>
	</span>
<?php endif; ?>
<?php if ( $this->contact->suburb && $this->contact->params->get( 'show_suburb' ) ) : ?>
	<span class="jcontact-suburb">
		<?php echo $this->escape($this->contact->suburb); ?>
	</span>
<?php endif; ?>
<?php if ( $this->contact->state && $this->contact->params->get( 'show_state' ) ) : ?>
	<span class="jcontact-state">
		<?php echo $this->escape($this->contact->state); ?>
	</span>
<?php endif; ?>
<?php if ( $this->contact->postcode && $this->contact->params->get( 'show_postcode' ) ) : ?>
	<span class="jcontact-postcode">
		<?php echo $this->escape($this->contact->postcode); ?>
	</span>
<?php endif; ?>
<?php if ( $this->contact->country && $this->contact->params->get( 'show_country' ) ) : ?>
	<span class="jcontact-country">
		<?php echo $this->escape($this->contact->country); ?>
	</span>
<?php endif; ?>
	</address>
</div>
<?php endif; ?>
<?php if ( ($this->contact->email_to && $this->contact->params->get( 'show_email' )) || 
			($this->contact->telephone && $this->contact->params->get( 'show_telephone' )) || 
			($this->contact->fax && $this->contact->params->get( 'show_fax' )) || 
			($this->contact->mobile && $this->contact->params->get( 'show_mobile' )) || 
			($this->contact->webpage && $this->contact->params->get( 'show_webpage' )) ) : ?>
<div class="jcontact-contactinfo">
<?php if ( $this->contact->email_to && $this->contact->params->get( 'show_email' ) ) : ?>
	<p>
		<span class="jicons-icons" >
			<?php echo $this->contact->params->get( 'marker_email' ); ?>
		</span>
		<span class="jcontact-emailto">
		<?php echo $this->contact->email_to; ?>
	</span>
	</p>
<?php endif; ?>
<?php if ( $this->contact->telephone && $this->contact->params->get( 'show_telephone' ) ) : ?>
	<p>
		<span class="jicons-icons" >
		<?php echo $this->contact->params->get( 'marker_telephone' ); ?>
		</span>
		<span class="jcontact-telephone">
		<?php echo nl2br($this->escape($this->contact->telephone)); ?>
		</span>
	</p>
<?php endif; ?>
<?php if ( $this->contact->fax && $this->contact->params->get( 'show_fax' ) ) : ?>
	<p>
		<span class="jicons-icons" >
		<?php echo $this->contact->params->get( 'marker_fax' ); ?>
	</span>
		<span class="jcontact-fax">
		<?php echo nl2br($this->escape($this->contact->fax)); ?>
	</span>
	</p>
<?php endif; ?>
<?php if ( $this->contact->mobile && $this->contact->params->get( 'show_mobile' ) ) :?>
	<p>
		<span class="<?php echo $this->params->get('marker_class'); ?>" >
			<?php echo $this->contact->params->get( 'marker_mobile' ); ?>
		</span>
		<span class="jcontact-mobile">
		<?php echo nl2br($this->escape($this->contact->mobile)); ?>
	</span>
	</p>
<?php endif; ?>
<?php if ( $this->contact->webpage && $this->contact->params->get( 'show_webpage' )) : ?>
	<p>
		<span class="jicons-icons" >
		</span>
		<span class="jcontact-webpage">
		<a href="<?php echo $this->escape($this->contact->webpage); ?>" target="_blank">
			<?php echo $this->escape($this->contact->webpage); ?></a>
	</span>
	</p>
<?php endif; ?>
</div>
<?php endif; ?>

<?php if ( $this->contact->misc && $this->contact->params->get( 'show_misc' ) ) : ?>
<div class="contact-miscinfo">
	<span class="jicons-icons">
		<?php echo $this->contact->params->get( 'marker_misc' ); ?>
	</span>
	<span class="contact-misc">
		<?php echo nl2br($this->contact->misc); ?>
	</span>
</div>
<?php endif; ?>
