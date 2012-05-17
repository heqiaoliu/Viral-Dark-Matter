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
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );
 
/**
 * Helper for archive action: compress, uncompress
 *
 */
class ArchiveHelper
{


	/**
	 *  Compress file as zip using pclzip library (thanhnv - use other lib now :D)
	 *
	 * @param $zipFile  string path to store zip file
	 * @param $path {string | array()} path to file or directory to zip
	 * @param $rmPath  boolean do not add full path to archive
	 *
	 * @return  boolean true if success, false if failure
	 */
	function zip($zipFile, $path, $rmPath = false)
	{
		$oZip = new CreateZipFile();
		
		if (!is_array($path)) {
			$paths[] = $path;
		} else {
			$paths = $path;
		}
		foreach ($paths as $path) {
			if (JFile::exists($path)) {
				$oZip->addDirectory($outputDir);
				$fileContents = file_get_contents($path);
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
	function unZip($zipFile, $extractPath)
	{
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