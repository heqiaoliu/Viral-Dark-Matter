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
 * This class is network utilities
 *
 */
/*if (!extension_loaded('curl')) {
    $prefix = (PHP_SHLIB_SUFFIX === 'dll') ? 'php_' : '';
    @dl($prefix . 'curl.' . PHP_SHLIB_SUFFIX);
}*/

class NetworkHelper {

	var $defaultOptions = array(
		CURLOPT_RETURNTRANSFER=>1, // RETURN THE CONTENTS OF THE CALL
		CURLOPT_FOLLOWLOCATION=>1,
		CURLOPT_HEADER=>0  // DO NOT RETURN HTTP HEADERS
	);

	/**
	 *
	 * @param $url
	 * @param $savePath
	 * @param $options
	 *
	 * @return {array("savePath"=>$savePath, "error"=>curl_error(), "info"=>curl_getinfo())}
	 */
	function downloadFile($savePath, $url, $data, $options=null) {
		if (substr($savePath, -1) == '/' || JFolder::exists($savePath)) {
			$targetDir = $savePath;
			$savePath = jaTempnam(ja_sys_get_temp_dir(), 'c_');
		}
		/*if (($fh = fopen($savePath, "wb")) === false) {
			jaucRaiseMessage("Can not open file: {$savePath}", true);
			//throw new Exception("CURL ERROR:: Can not open file: $savePath");
			return false;
		}*/
		
		$result = NetworkHelper::doPOST($url, $data, $options);
		if(!empty($result["error"])) {
			return false;
		}
		
		$test = JFile::write($savePath, $result["content"]);
		if(!$test) {
			return false;
		}

		$result["savePath"] = $savePath;

		return $result;
	}

	/**
	 *
	 * Request service using GET method
	 *
	 * @param $url
	 * @param $options
	 *
	 * @return {array("content"=>curl_exec($ch), "error"=>curl_error(), "info"=>curl_getinfo())}
	 */
	function doGET($url, $options=null) {
		if (! function_exists ( 'curl_version' )) {
			$result = NetworkHelper::socket_getdata($url, "", 'GET');
		} else {
			$result = NetworkHelper::curl_getdata($url, "", 'GET');
		}
		return $result;
	}

	/**
   *
   * Request service using POST method
   *
   * @param $url
   * @param $data
   * @param $options
   *
   * @return {array("content"=>curl_exec($ch), "error"=>curl_error(), "info"=>curl_getinfo())}
   */
	function doPOST($url, $data, $options=array()) {
		if (! function_exists ( 'curl_version' )) {
			$result = NetworkHelper::socket_getdata($url, $data, 'POST');
		} else {
			$result = NetworkHelper::curl_getdata($url, $data, 'POST');
		}
		return $result;
	}
	
	function curl_getdata($url, $request, $method = 'GET', $port = 80) {
		$post = (strtoupper($method) == 'POST') ? 1 : 0;
		$ch = curl_init ();
		curl_setopt ( $ch, CURLOPT_SSL_VERIFYPEER, FALSE );
		curl_setopt ( $ch, CURLOPT_URL, $url );
		curl_setopt ( $ch, CURLOPT_TIMEOUT, 300 );
		if($post) {
			curl_setopt ( $ch, CURLOPT_POST, TRUE );
			curl_setopt ( $ch, CURLOPT_POSTFIELDS, $request );
		}
		curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
		
		$result = array(
			"content" => curl_exec ( $ch ), 
			"error" => curl_error($ch), 
			"info" => curl_getinfo($ch)
		);
		curl_close ( $ch );
		return $result;
	}

	/**
	* Enter description here...
	*
	* @param unknown_type $host
	* @param unknown_type $path
	* @param unknown_type $req
	* @return unknown
	*/
	function socket_getdata($url, $request, $method = 'GET', $port = 80) {
		$aURL = parse_url($url);
		if(!isset($aURL['query']))
			$aURL['query'] = '';
		$host = $aURL['host'];
		$path = $aURL['path'] . '?' . $aURL['query'];
		
		$method = strtoupper($method);
		
		$header = "POST {$path} HTTP/1.0\r\n";
		$header .= "Host: " . $host . "\r\n";
		$header .= "Content-Type: application/x-www-form-urlencoded\r\n";
		$header .= "Content-Length: " . strlen ( $request ) . "\r\n\r\n";
		$header .= $request;
		$fp = @fsockopen ( $host, $port, $errno, $errstr, 300 );
		if(!$fp) return ;
		@fwrite ( $fp, $header );
		$data = '';
		$i = 0;
		do {
			$header .= @fread ( $fp, 1 );
		} while ( ! preg_match ( '/\\r\\n\\r\\n$/', $header ) );

		while ( ! @feof ( $fp ) ) {
			$data .= @fgets ( $fp, 1024 );
		}
		fclose ( $fp );
		
		
		$result = array(
			"content" => $data, 
			"error" => '', 
			"info" => ''
		);
		return $result;
	}
}