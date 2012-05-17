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
 * Helper for archive action: compress, uncompress
 *
 */
class ArchiveHelper {

	/**
   *  Compress file as zip using pclzip library (thanhnv - use other lib now :D)
   *
   * @param $zipFile  string path to store zip file
   * @param $path {string | array()} path to file or directory to zip
   * @param $rmPath  boolean do not add full path to archive
   *
   * @return  boolean true if success, false if failure
   */
	function zip($zipFile, $path, $rmPath = false) {
		$oZip = new CreateZipFile();
		
		if (!is_array($path)) {
			$paths[] = $path;
		} else {
			$paths = $path;
		}
		foreach ($paths as $path) {
			if(JFile::exists($path)) {
				$oZip->addDirectory($outputDir);
				$fileContents=file_get_contents($path);
				$oZip->addFile($fileContents, basename($path));
			} elseif (JFolder::exists($path)) {
				$outputDir = str_replace(array(dirname($path), DS, '/'), '', $path) . DS;
				$oZip->zipDirectory($path, $outputDir);
			}
		}
		
		$out = JFile::write($zipFile, $oZip->getZippedfile());
		
		return $out;
	}

	/**
   * Uncompress zip file using pclzip library
   *
   * @param $zipFile  string path to zip file
   * @param $extractPath  string path to location which will be extract to
   *
   * @return  boolean true if success, false if failure
   */
	function unZip($zipFile, $extractPath) {
		jimport('joomla.filesystem.archive');
		
		$result = JArchive::extract($zipFile, $extractPath);
		if ($result === false) {
			return false;
		}
		return true;
		
		/*$pcl = new PclZip($zipFile);
		if(empty($pcl)) {
			return false;
		}
		$retVal = $pcl->extract(PCLZIP_OPT_PATH, $extractPath);
		$pcl->privCloseFd();
		return $retVal;*/
	}
}