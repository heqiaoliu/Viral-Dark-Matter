<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

//no direct access
defined( '_JEXEC' ) or die( 'Retricted Access' );

?>
<tr class="<?php echo "row".$this->component->index % 2; ?>" <?php echo $this->component->style; ?>>
  <td><?php echo $this->pagination->getRowOffset( $this->component->index ); ?></td>
  <td>
    <input type="checkbox" id="cId<?php echo $this->component->index;?>"
          name="cId[]" value="<?php echo $this->component->id; ?>"
          onclick="isChecked(this.checked);" <?php echo $this->component->cbd; ?> />
  </td>
  <td>
    <span class="bold"><?php echo $this->component->name; ?></span>
  </td>
  <td align="center">
    <?php echo @$this->component->version != '' ? $this->component->version : '&nbsp;'; ?>
    </td>
  <td>
    <?php echo @$this->component->creationdate != '' ? $this->component->creationdate : '&nbsp;'; ?>
  </td>
</tr>
