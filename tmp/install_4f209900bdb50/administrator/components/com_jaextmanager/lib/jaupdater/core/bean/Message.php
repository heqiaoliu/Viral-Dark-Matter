<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager Client Library
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license - PHP files are GNU/GPL V2. CSS / JS are Copyrighted Commercial,
# bound by Proprietary License of JoomlArt. For details on licensing, 
# Please Read Terms of Use at http://www.joomlart.com/terms_of_use.html.
# Author: JoomlArt.com
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# Redistribution, Modification or Re-licensing of this file in part of full, 
# is bound by the License applied. 
# ------------------------------------------------------------------------
*/ 

// no direct access
defined( '_JA' ) or die( 'Restricted access' );

/**
 * Message Object use for communication between service and client
 *
 */
class Message {

  var $from = null;
  var $to = null;
  var $content = null;

  /**
   * @param $content
   * @param $from
   * @param $to
   */
  function Message($content, $from, $to) {
    if (is_array($content)) {
      $this->content = $content;
    } else {
      $this->content[] = $content;
    }
    $this->from = $from;
    $this->to = $to;
  }
}