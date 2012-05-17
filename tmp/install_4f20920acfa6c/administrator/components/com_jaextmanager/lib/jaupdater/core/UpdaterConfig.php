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
 * This class will be use for store configuration for both client and service module
 *
 */
class UpdaterConfig {
  var $id = 0;

  /**
   *
   * @var Hash table to store configuration
   */
  var $configHash = array();

  function UpdaterConfig($configs = array()) {
    $this->id = rand();
    $this->apply($configs);
  }

  /**
   *  Use for batch config apply
   *
   * @param $configs
   */
  function apply($configs = array()) {
    foreach ($configs as $key=>$value) {
      $this->set($key, $value);
    }
  }

  /**
   *
   * @param $key
   * @param $value
   *
   * @return  boolean true if success, otherwise return false
   */
  function set($key, $value) {
    if (!empty($key)) {
      $this->configHash[$key] = $value;
      return true;
    }
    return false;
  }

  /**
   *
   * @param $key
   *
   * @return  mixed if option is not exists return null
   */
  function get($key) {
    if (array_key_exists($key, $this->configHash)) {
      return $this->configHash[$key];
    }
    return null;
  }

  /**
   *
   * @param $config  UpdaterConfig
   *
   * @return  boolean true if success, otherwise false is returned
   */
  function merge($config) {
    if (!empty($config) &&
        is_object($config)) {
      $this->configHash = array_merge($this->configHash, $config->configHash);
    }
  }

  /**
   *
   * @param $key
   *
   * @return  boolean true if config exists, otherwise return false
   */
  function remove($key) {
    if (array_key_exists($key, $this->configHash)) {
      unset($this->configHash[$key]);
      return true;
    }
    return false;
  }
}