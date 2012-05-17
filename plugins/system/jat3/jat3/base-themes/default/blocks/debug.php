<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// No direct access
defined('_JEXEC') or die;
?>

<jdoc:include type="modules" name="debug" />

<?php if ($this->getParam ('infomode',1) == 1 && JRequest::getCmd ('t3info')) : ?>
    <script type="text/javascript">
    var jalayout=<?php echo json_encode($this->getLayoutXML()) ?>;
    var t3info='<?php echo JRequest::getCmd('t3info') ?>';
    </script>
    <?php if (is_dir (T3Path::path('layoutinfo', true))) : ?>
        <link type="text/css" rel="stylesheet" href="<?php echo T3Path::url('layoutinfo/style.css', true) ?>" />
        <script type="text/javascript" src="<?php echo T3Path::url('layoutinfo/script.js', true) ?>"></script>
    <?php else :?>
        <?php if (T3Path::getPath ('layoutinfo')) : ?>
        <link type="text/css" rel="stylesheet" href="<?php echo T3Path::getUrl('layoutinfo/style.css') ?>" />
        <script type="text/javascript" src="<?php echo T3Path::getUrl('layoutinfo/script.js') ?>"></script>
        <?php endif; ?>
    <?php endif; ?>
<?php endif; ?>