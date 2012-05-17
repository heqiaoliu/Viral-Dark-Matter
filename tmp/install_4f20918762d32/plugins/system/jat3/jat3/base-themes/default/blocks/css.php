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
<?php
if (T3Common::mobile_device_detect()) return; /* don't apply custom css for handheld device */

/*Load google font and style for special font*/
$elements = array('global', 'logo', 'slogan', 'moduletitle','pageheading', 'contentheading', 'mainnav', 'subnav');
$fontweights = array('normal' , 'bold' , 'bolder' , 'lighter' , '100' , '200' , '300' , '400' , '500' , '600' , '700' , '800' , '900');
$fonts = array();
$_fonts = array();
$_subsets = array();
foreach ($elements as $element) {
    $fontsetting = $this->getParam ('gfont_'.$element);
    $fontsetting = str_replace ("\|", '|', $fontsetting);
    $fontsetting = explode('|', $fontsetting);
    $fonts[$element] = '';
    if (count($fontsetting) > 4) {
        $fonts[$element] = $fontsetting[0];
        if ($fonts[$element]) {
            $name = $fontsetting[0];
            if (!isset($_fonts[$name])) {
               $_fonts[$name] = array();
            }
            $fonts[$element] = "font-family: '{$fonts[$element]}';";
            // Style for font weight & font style
            if ($fontsetting[3]) {
            	// Check font variant
                $_fonts[$name][$fontsetting[3]] = $fontsetting[3];
                $fs = '';
                // Split font weight & font style
                foreach ($fontweights as $fw) {
                    if (strpos($fontsetting[3], $fw) !== false) {
                        $fonts[$element] .= 'font-weight:'. $fw . ';';
                        $fs = str_replace($fw, '', $fontsetting[3]);
                        break;
                    }
                }
                if (empty($fs)) {
                    $fs = $fontsetting[3];
                }
                $fonts[$element] .= 'font-style:' . $fs . ';';
            }
            // Get subsets
            if ($fontsetting[4]) {
                $_subsets[$fontsetting[4]] = $fontsetting[4];
            }
        }
    }
    if (count($fontsetting) > 2) {
        $custom_css = isset($fontsetting[1]) && ($fontsetting[1] == '1');
        if ($custom_css && trim($fontsetting[2])) {
            $custom = '';
            $custom = trim ($fontsetting[2]);
            if ($custom && substr($custom, -1) != ';') $custom .= ';';
            $fonts[$element] .= $custom;
        }
    }
}
if (count ($_fonts)) :
    // Join fonts to build request
    $gfonts = array();
    foreach ($_fonts as $name=>$variants) {
        array_push($gfonts, $name . ':' . implode(',', $variants));
    }
    $gfonts = str_replace (' ', '+', implode ('|', $gfonts));
    // Join subsets
    $subsets = implode(',', $_subsets);
    if (empty($gfonts)) {
        $subsets = '';
    } else {
        $subsets = '&subset=' . $subsets;
    }
    // Get suitable protocol
    $uri = JFactory::getURI();
    if ($uri->isSSL()) {
        $protocol = 'https';
    } else {
        $protocol = 'http';
    }
?>
<link rel="stylesheet" type="text/css" href="<?php echo $protocol; ?>://fonts.googleapis.com/css?family=<?php echo $gfonts, $subsets; ?>" />
<?php endif ?>

<style type="text/css">
/*dynamic css*/
<?php if ($fonts['global']): ?>
    body#bd,
    div.logo-text h1 a,
    div.ja-moduletable h3, div.moduletable h3,
    div.ja-module h3, div.module h3,
    h1.componentheading, .componentheading,
    .contentheading,
    .article-content h1,
    .article-content h2,
    .article-content h3,
    .article-content h4,
    .article-content h5,
    .article-content h6
    {<?php echo $fonts['global']; ?>}
<?php endif; ?>
<?php if ($fonts['logo']): ?>
    div.logo-text h1, div.logo-text h1 a
    {<?php echo $fonts['logo']; ?>}
<?php endif; ?>
<?php if ($fonts['slogan']): ?>
    p.site-slogan
    {<?php echo $fonts['slogan']; ?>}
<?php endif; ?>
<?php if ($fonts['mainnav']): ?>
    #ja-splitmenu,
    #jasdl-mainnav,
    #ja-cssmenu li,
    #ja-megamenu ul.level0
    {<?php echo $fonts['mainnav']; ?>}
<?php endif; ?>
<?php if ($fonts['subnav']): ?>
    #ja-subnav,
    #jasdl-subnav,
    #ja-cssmenu li li,
    #ja-megamenu ul.level1
    {<?php echo $fonts['subnav']; ?>}
<?php endif; ?>
<?php if ($fonts['pageheading']): ?>
    h1.componentheading, .componentheading
    {<?php echo $fonts['pageheading']; ?>}
<?php endif; ?>
<?php if ($fonts['contentheading']): ?>
    .contentheading,
    .article-content h1,
    .article-content h2,
    .article-content h3,
    .article-content h4,
    .article-content h5,
    .article-content h6
    {<?php echo $fonts['contentheading']; ?> }
<?php endif; ?>
<?php if ($fonts['moduletitle']): ?>
    div.ja-moduletable h3, div.moduletable h3,
    div.ja-module h3, div.module h3
    {<?php echo $fonts['moduletitle']; ?>}
<?php endif; ?>

<?php
$mainwidth = $this->getMainWidth();
if ($mainwidth) : ?>
    body.bd .main {width: <?php echo $mainwidth ?>;}
    body.bd #ja-wrapper {min-width: <?php echo $mainwidth ?>;}
<?php endif; ?>
</style>