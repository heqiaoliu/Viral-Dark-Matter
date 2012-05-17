<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
//defined ( '_JEXEC' ) or die ( 'Restricted access' );

if (!defined('_JA'))
	define("_JA", "JoomlArt Enterprise");
define("_JA_ROOT", realpath(dirname(__FILE__)));

require_once (_JA_ROOT . DS . "jaupdater" . DS . "JAUpdater.php");

if (defined('_JEXEC')) {
	include_once (_JA_ROOT . DS . "config_joomla.php");
} else {
	include_once (_JA_ROOT . DS . "config.php");
}

class UpdaterClient
{
	
	var $config, $lastAction;


	function UpdaterClient()
	{
		global $config;
		
		$this->config = new UpdaterConfig();
		
		if (!empty($config)) {
			$this->config->merge($config);
		}
	}


	function invokeService($message, $product = null)
	{
		$messageData = "json=" . json_encode($message);
		
		$content = $message->content;
		$account = $content["args"]["account"];
		$serviceUrl = $account->ws_uri;
		$result = NetworkHelper::doPOST($serviceUrl, $messageData);
		$result = $this->getJsonObject($result);
		
		if ($result === false) {
			//jaucRaiseMessage("Responding an error from Web Service", true);
			return false;
		} else if (!empty($result->error)) {
			jaucRaiseMessage($result->error, true);
			return false;
			//throw new Exception('Invoking service ['.$message->content->service.'] error '.$result->error);
		} else {
			return $result->response;
		}
	}


	/**
	 * Build service message
	 *
	 * @param $from string identify of this host
	 * @param $to string name of web service
	 * @param $content object service call and arguments
	 *
	 * @return Message
	 */
	function buildMessage($content, $from = null, $to = null)
	{
		$args = (isset($content["args"])) ? $content["args"] : array();
		
		$product = (isset($args["product"])) ? $args["product"] : null;
		if (!isset($args["account"]) || !is_object($args["account"])) {
			$account = new stdClass();
			$account->ws_uri = $this->getServiceUrl($product);
			$account->ws_user = $this->getServiceUsername($product);
			$account->ws_pass = $this->getServicePassword($product);
		
		} else {
			$account = $args["account"];
		}
		$account->user_domain = $_SERVER['SERVER_NAME'];
		$content["args"]["account"] = $account;
		
		$from = empty($from) ? $_SERVER["REMOTE_ADDR"] : $from;
		$to = empty($to) ? "JAUpdater Web Service" : $to;
		return (new Message($content, $from, $to));
	}


	function authUser($service)
	{
		$content["service"] = "authUser";
		$content["args"]["account"] = $service;
		
		$product = null;
		$result = $this->invokeService($this->buildMessage($content), $product);
		return $result;
	}


	/**
	 *
	 * @param $data string json string
	 *
	 * @return object
	 */
	function getJsonObject($data)
	{
		$result = json_decode($data["content"]);
		if (!empty($result) && !empty($result->content)) {
			return $result->content;
		} else {
			//echo $data["content"];
			return false;
			//throw new Exception("Invalid JSON data");
		}
	}


	function isLocalMode($product = null)
	{
		if (is_object($product) && !empty($product->ws_mode)) {
			return ($product->ws_mode == 'local') ? 1 : 0;
		} else {
			return ($this->config->get("WS_MODE") == 'local') ? 1 : 0;
		}
	}


	function getServiceUrl($product = null)
	{
		if (is_object($product) && !empty($product->ws_uri)) {
			return $product->ws_uri;
		} else {
			//default value
			return $this->config->get("WS_URI");
		}
	}


	function getServiceUsername($product = null)
	{
		if (is_object($product) && !empty($product->ws_user)) {
			return $product->ws_user;
		} else {
			//default value
			return $this->config->get("WS_USER");
		}
	}


	function getServicePassword($product = null)
	{
		if (is_object($product) && !empty($product->ws_pass)) {
			return $product->ws_pass;
		} else {
			//default value
			return $this->config->get("WS_PASS");
		}
	}


	function getProduct($product)
	{
		$pro = new jaProducts($product, $this->config);
		return $pro;
	}


	/**
	 * Enter description here...
	 *
	 * @param unknown_type $refresh
	 * @return unknown
	 */
	function getListProducts($refresh = 0)
	{
		//cache client
		$dataDir = FileSystemHelper::clean(JA_WORKING_DATA_FOLDER);
		
		$productsFile = $dataDir . "jaupdater.products.json";
		$productList = null;
		if (file_exists($productsFile) && !$refresh) {
			$updateTime = filectime($productsFile);
			$currentTime = time();
			$cacheTimelife = 3 * 24 * 60 * 60; //3 days
			if ($updateTime + $cacheTimelife > $currentTime) {
				$productList = json_decode(file_get_contents($productsFile));
			}
		}
		
		if (empty($productList)) {
			$content["service"] = "listProducts";
			$content["args"]["refresh"] = $refresh;
			
			$result = $this->invokeService($this->buildMessage($content));
			if ($result === false) {
				jaucRaiseMessage("Fail to get list of products.");
				return false;
			} else {
				$productList = $result;
				//update cache
				JFile::write($productsFile, json_encode($productList));
			}
		}
		return $productList;
	}


	function getNewerVersions($product)
	{
		if ($this->isLocalMode($product)) {
			return $this->getNewerVersionsLocal($product);
		}
		
		$content["service"] = "getNewerVersions";
		$pro = new jaProducts($product, $this->config);
		// Remove some unneeded information
		$content["args"]["product"] = $pro->getInfo();
		
		$result = $this->invokeService($this->buildMessage($content), $product);
		return $result;
	}


	/**
	 * @return same result with getNewerVersions but getting information from local repo
	 */
	function getNewerVersionsLocal($product)
	{
		if (!($productDir = $this->getLocalVersionsPath($product))) {
			return false;
		}
		
		if (!JFolder::exists($productDir)) {
			return false;
		} else {
			$obj = new stdClass();
			$handle = opendir($productDir);
			
			$pro = new jaProducts($product, $this->config);
			while (($entry = readdir($handle)) !== false) {
				if (JFolder::exists($productDir . $entry . DS) && $entry != '.' && $entry != '..') {
					$result = $this->isNewerVersion($entry, $product->version);
					if ($result) {
						$aVersions = $pro->_parseListVersions($productDir . $entry . DS . basename($pro->configFile));
						
						$ver = new stdClass();
						$ver->type = $product->type;
						$ver->name = $product->name;
						$ver->extKey = $product->extKey;
						$ver->version = $entry;
						if ($result == 2) {
							$ver->notSure = 1;
						}
						
						if (isset($aVersions[$entry]) && isset($aVersions[$entry]['changelogUrl'])) {
							$ver->changelogUrl = $aVersions[$entry]['changelogUrl'];
						}
						
						$obj->$entry = $ver;
					}
				}
			}
			closedir($handle);
			
			return $obj;
		}
	}


	function buildDiff($product, $newVersion)
	{
		if ($this->isLocalMode($product)) {
			return $this->buildDiffLocal($product, $newVersion);
		}
		$pro = new jaProducts($product, $this->config, true);
		
		$content["service"] = "buildDiff";
		$content["args"]["product"] = $pro->getFullInfo();
		$content["args"]["newVersion"] = $newVersion;
		
		$result = $this->invokeService($this->buildMessage($content), $product);
		return $result;
	}


	/**
	 * @return same result with buildDiff but getting information from local repo
	 */
	
	function buildDiffLocal($product, $newVersion)
	{
		if (!($productDir = $this->getLocalVersionsPath($product))) {
			return false;
		}
		//
		$newVerDir = $productDir . $newVersion . DS;
		if (!JFolder::exists($newVerDir)) {
			return false;
		}
		$vUpgrade = new stdClass();
		$vUpgrade->crc = $this->getVersionChecksum($newVerDir);
		//
		$orgVerDir = $productDir . $product->version . DS;
		if (JFolder::exists($orgVerDir)) {
			$vServer = new stdClass();
			$vServer->crc = $this->getVersionChecksum($orgVerDir);
		}
		//
		$pro = new jaProducts($product, $this->config, true);
		$oldPro = $pro->getFullInfo();
		//
		$compare = new jaCompareTool();
		if (isset($vServer)) {
			return $compare->checkToUpgrade($oldPro, $vServer, $vUpgrade);
		} else {
			return $compare->checkToBuildUpgradePackage($oldPro, $vUpgrade);
		}
	}


	function getFileContent($product, $version, $file)
	{
		if ($this->isLocalMode($product)) {
			return $this->getFileContentLocal($product, $version, $file);
		}
		
		$pro = new jaProducts($product, $this->config);
		$content["service"] = "getFileContent";
		$content["args"]["product"] = $pro->getInfo();
		$content["args"]["version"] = $version;
		$content["args"]["file"] = $file;
		
		$result = $this->invokeService($this->buildMessage($content), $product);
		return $result;
	}


	function getFileContentLocal($product, $version, $file)
	{
		$product->version = $version;
		$location = $this->getLocalVersionPath($product);
		$file = $location . $file;
		if (JFile::exists($file)) {
			return file_get_contents($file);
		} else {
			return false;
		}
	}


	function buildDiffFilesConflicted($product)
	{
		$pro = new jaProducts($product, $this->config);
		
		$diffFolder = $product->diffFolder;
		$diffFile = $product->diffFile;
		
		$titleLive = "Live file";
		$fileLive = $pro->getFilePath($diffFile);
		if (!JFile::exists($fileLive)) {
			$titleLive = "Removed";
			$strLive = "";
		} else {
			$strLive = file_get_contents($fileLive);
		}
		
		$titleBackup = "Backup file";
		$fileBackup = $this->getLocalConflictPath($pro->getInfo(), $diffFolder) . $diffFile;
		$fileBackup = FileSystemHelper::clean($fileBackup);
		$strBackup = file_get_contents($fileBackup);
		
		$diff = new jaDiffTool();
		$objLeft = $diff->buildObject($titleLive, $fileLive, $strLive, 1);
		$objRight = $diff->buildObject($titleBackup, $fileBackup, $strBackup, 0);
		$result = $diff->compare($objLeft, $objRight, 'string');
		return $result;
	}


	function buildDiffFiles($product, $newVersion)
	{
		if ($this->isLocalMode($product)) {
			return $this->buildDiffFilesLocal($product, $newVersion);
		}
		$pro = new jaProducts($product, $this->config);
		
		$diffType = isset($product->diffType) ? $product->diffType : 'LN';
		$diffFile = $product->diffFile;
		
		$titleLive = "Current file (The file of version {$product->version} and modified by you)";
		$titleOrig = "Original file (The file of version {$product->version})";
		$titleNew = "New file (The file of new version {$newVersion})";
		
		$fileLive = $pro->getFilePath($diffFile);
		$fileOrig = "Remote File";
		$fileNew = "Remote File";
		
		if (JFile::exists($fileLive)) {
			$strLive = file_get_contents($fileLive);
		} else {
			$strLive = '';
			$titleLive = "Current file (The file of version {$product->version} and modified by you) <span style=\"color:red;\">Removed</span>";
		}
		
		$strOrig = $this->getFileContent($product, $product->version, $diffFile);
		if ($strOrig === false) {
			//If not found original version on server
			//system will compare live version (of user' site) with new version (on server)
			$strOrig = $strLive;
			$fileOrig = $fileLive;
			$titleOrig = $titleLive;
		}
		$strNew = $this->getFileContent($product, $newVersion, $diffFile);
		
		/*********/
		$arrayTypes = array('L' => 'Live', 'N' => 'New', 'O' => 'Orig');
		$suffix1 = $arrayTypes[substr($diffType, 0, 1)];
		$suffix2 = $arrayTypes[substr($diffType, 1, 1)];
		
		$title1 = ${'title' . $suffix1};
		$file1 = ${'file' . $suffix1};
		$str1 = ${'str' . $suffix1};
		
		$title2 = ${'title' . $suffix2};
		$file2 = ${'file' . $suffix2};
		$str2 = ${'str' . $suffix2};
		/*********/
		
		if ($str1 !== false && $str2 !== false) {
			$diff = new jaDiffTool();
			$objLeft = $diff->buildObject($title1, $file1, $str1, 0);
			$objRight = $diff->buildObject($title2, $file2, $str2, 0);
			$result = $diff->compare($objLeft, $objRight, 'string');
			return $result;
		} else {
			return false;
		}
	}


	function buildDiffFilesLocal($product, $newVersion)
	{
		if (!($productDir = $this->getLocalVersionsPath($product))) {
			return false;
		}
		$pro = new jaProducts($product, $this->config);
		
		$diffType = isset($product->diffType) ? $product->diffType : 'LN';
		$diffFile = $product->diffFile;
		/**
		 * (L) = Files of Live version on user site.
		 * (O) = Original files of live version.
		 * (N) = New Version Files.
		 */
		
		$titleLive = "Current file (The file of version {$product->version} and modified by you)";
		$titleOrig = "Original file (The file of version {$product->version})";
		$titleNew = "New file (The file of new version {$newVersion})";
		
		$fileLive = $pro->getFilePath($diffFile);
		$fileOrig = FileSystemHelper::clean($productDir . $product->version . DS . $diffFile);
		$fileNew = FileSystemHelper::clean($productDir . $newVersion . DS . $diffFile);
		if (!JFile::exists($fileOrig)) {
			//missing current version on local repository
			//=> using live file to compare
			$fileOrig = $fileLive;
			$titleOrig = $titleLive;
		}
		/*********/
		$arrayTypes = array('L' => 'Live', 'N' => 'New', 'O' => 'Orig');
		$suffix1 = $arrayTypes[substr($diffType, 0, 1)];
		$suffix2 = $arrayTypes[substr($diffType, 1, 1)];
		
		$title1 = ${'title' . $suffix1};
		$file1 = ${'file' . $suffix1};
		
		$title2 = ${'title' . $suffix2};
		$file2 = ${'file' . $suffix2};
		/*********/
		
		if (JFile::exists($file1) && JFile::exists($file2)) {
			$diff = new jaDiffTool();
			$objLeft = $diff->buildObject($title1, $file1, '', 0);
			$objRight = $diff->buildObject($title2, $file2, '', 0);
			$result = $diff->compare($objLeft, $objRight, 'file');
			return $result;
		} else {
			return false;
		}
	}


	/**
	 * display diff view for update.joomlart.com
	 *
	 * @param (string) $uniqueKey
	 * @param (string) $ver1
	 * @param (string) $ver2
	 * @return unknown
	 */
	function buildDiff2($uniqueKey, $version1, $version2)
	{
		
		$content["service"] = "buildDiff2";
		$content["args"]["uniqueKey"] = $uniqueKey;
		$content["args"]["version1"] = $version1;
		$content["args"]["version2"] = $version2;
		
		$result = $this->invokeService($this->buildMessage($content));
		return $result;
	}


	/**
	 * with product get from local
	 *
	 * @param unknown_type $product
	 * @param unknown_type $logVersion
	 * @return unknown
	 */
	function getChangeLog($product, $logVersion)
	{
		if ($this->isLocalMode($product)) {
			$changelog = $this->getChangeLogLocal($product, $logVersion);
			if ($changelog !== false) {
				return $changelog;
			}
		}
		
		$pro = new jaProducts($product, $this->config);
		
		$content["service"] = "getChangeLog";
		$content["args"]["product"] = $pro->getInfo();
		$content["args"]["logVersion"] = $logVersion;
		
		$result = $this->invokeService($this->buildMessage($content), $product);
		return $result;
	}


	/**
	 * @return same result with buildDiff but getting information from local repo
	 */
	function getChangeLogLocal($product, $logVersion)
	{
		if (!($productDir = $this->getLocalVersionsPath($product))) {
			return false;
		}
		
		$logFile = $productDir . $logVersion . DS . "change_log.log";
		if (JFile::exists($logFile)) {
			return file_get_contents($logFile);
		} else {
			return false;
		}
	}


	/**
	 * with product get from server
	 *
	 * @param unknown_type $product
	 * @param unknown_type $logVersion
	 * @return unknown
	 */
	function getChangeLog2($product, $logVersion)
	{
		$content["service"] = "getChangeLog";
		$content["args"]["product"] = $product;
		$content["args"]["logVersion"] = $logVersion;
		
		$result = $this->invokeService($this->buildMessage($content), $product);
		return $result;
	}


	/**
	 * Do upgrade action
	 */
	
	function doUpgrade($product, $upgradeVersion)
	{
		$pro = new jaProducts($product, $this->config);
		$upgradePackage = $this->_downloadUpgradePackage($pro, $upgradeVersion);
		if ($upgradePackage === false) {
			return false;
		} else {
			//check downloaded package
			$json = json_decode(file_get_contents($upgradePackage));
			if (is_object($json)) {
				if (isset($json->content)) {
					if (isset($json->content->error) && !empty($json->content->error)) {
						jaucRaiseMessage($json->content->error, true);
						return false;
					}
				}
				jaucRaiseMessage("Upgrade Package is not valid format", true);
				return false;
			}
			//
			

			if ($pro->doUpgrade($upgradePackage, $upgradeVersion) === false) {
				//throw new Exception('[UpdaterClient] Upgrade is fail', 100);
				jaucRaiseMessage("Error occur when upgrading.", true);
				return false;
			}
			return true;
		}
	}


	function _downloadUpgradePackage($product, $upgradeVersion)
	{
		if ($this->isLocalMode($product)) {
			return $this->_downloadUpgradePackageLocal($product, $upgradeVersion);
		}
		
		$content["service"] = "downloadUpgradePackage";
		$content["args"]["product"] = $product->getFullInfo();
		$content["args"]["newVersion"] = $upgradeVersion;
		$message = "json=" . json_encode($this->buildMessage($content));
		
		$tmpFile = jaTempnam(ja_sys_get_temp_dir(), 'ja');
		$result = NetworkHelper::downloadFile($tmpFile, $this->getServiceUrl($product), $message);
		$downloadedFile = $result["savePath"];
		if (!JFile::exists($downloadedFile)) {
			//throw new Exception('[UpdaterClient] Fail to download upgrade package', 100);
			jaucRaiseMessage("Error occur when downloading upgrade package!", true);
			return false;
		} else {
			@chmod($downloadedFile, 0644);
			return $downloadedFile;
		}
	}


	/**
	 * @return same result with _downloadUpgradePackage but getting information from local repo
	 */
	
	function _downloadUpgradePackageLocal($product, $upgradeVersion)
	{
		@set_time_limit(0);
		if ($product->version == $upgradeVersion) {
			jaucRaiseMessage("UpdaterService: cannot upgrade to same version", true);
			return false;
		}
		if (!($productDir = $this->getLocalVersionsPath($product))) {
			return false;
		}
		//
		$newVerDir = $productDir . $upgradeVersion . DS;
		if (!JFolder::exists($newVerDir)) {
			return false;
		}
		$vUpgrade = new stdClass();
		$vUpgrade->crc = $this->getVersionChecksum($newVerDir);
		//
		$orgVerDir = $productDir . $product->version . DS;
		if (JFolder::exists($orgVerDir)) {
			$vServer = new stdClass();
			$vServer->crc = $this->getVersionChecksum($orgVerDir);
		}
		//
		$pro = new jaProducts($product, $this->config, true);
		$oldPro = $pro->getFullInfo();
		//
		$pathPackageStore = $this->getLocalPatchPath($product);
		$package = sprintf("%s_%s_%s.zip", $product->extKey, $product->version, $upgradeVersion);
		$package = $pathPackageStore . $package;
		
		if (!isset($vServer)) {
			//clear cached package file
			if (JFile::exists($package)) {
				JFile::delete($package);
			}
		}
		
		if (!JFile::exists($package)) {
			
			$compare = new jaCompareTool();
			if (isset($vServer)) {
				$vResult = $compare->checkToBuildUpgradePackage($vServer, $vUpgrade);
			} else {
				$vResult = $compare->checkToBuildUpgradePackage($oldPro, $vUpgrade);
			}
			
			$tmpDir = FileSystemHelper::tmpDir(null, 'ja', 0777);
			$tmpDir = $tmpDir . $oldPro->extKey . DS;
			if (JFolder::create($tmpDir, 0777) === false) {
				jaucRaiseMessage("UpdaterService: cannot build upgrade package", true);
				return false;
			}
			
			$infoFile = $tmpDir . "jaupdater.info.json";
			JFile::write($infoFile, json_encode($vResult));
			
			//echo $tmpDir;
			$this->_buildUpgradePackage($newVerDir, $tmpDir, $vResult);
			
			ArchiveHelper::zip($package, $tmpDir, true);
		}
		
		return $package;
	}


	function _buildUpgradePackage($src, $dst, $objectFilter)
	{
		$src = FileSystemHelper::clean($src);
		$dst = FileSystemHelper::clean($dst);
		
		if (JFolder::exists($src)) {
			if (!JFolder::exists($dst)) {
				JFolder::create($dst, 0777);
			}
			$dir = opendir($src);
			while (false !== ($file = readdir($dir))) {
				if (($file != '.') && ($file != '..')) {
					if (JFolder::exists($src . DS . $file)) {
						if (isset($objectFilter->$file)) {
							$this->_buildUpgradePackage($src . DS . $file, $dst . DS . $file, $objectFilter->$file);
						}
					} else {
						if (isset($objectFilter->$file) && in_array($objectFilter->$file, array('new', 'updated'))) {
							JFile::copy($src . DS . $file, $dst . DS . $file);
						}
					}
				}
			}
			closedir($dir);
		} elseif (JFile::exists($src)) {
			$file = basename($src);
			if (JFolder::exists($dst)) {
				$dst = FileSystemHelper::clean($dst . DS . $file);
			}
			if (isset($objectFilter->$file) && in_array($objectFilter->$file, array('new', 'updated'))) {
				JFile::copy($src, $dst);
			}
		}
	}


	function _parseBackupInfo($fileInfo)
	{
		$aFields = array("extKey", "version", "createDate", "comment");
		if (JFile::exists($fileInfo)) {
			$content = file_get_contents($fileInfo);
			preg_match_all("/([^\r\n=]+)=([^\r\n]*)/", $content, $matches);
			
			$data = array();
			foreach ($matches[1] as $key => $name) {
				$data[$name] = $matches[2][$key];
			}
			foreach ($aFields as $key) {
				if (!isset($data[$key])) {
					$data[$key] = ""; //default value
				}
			}
			return $data;
		} else {
			return false;
		}
	}


	function listBackupFiles($product, $upgradeVersion)
	{
		$folder = $this->getLocalBackupPath($product);
		
		$files = FileSystemHelper::files($folder);
		if ($files) {
			$aFiles = array();
			$i = -1;
			foreach ($files as $file) {
				if (FileSystemHelper::getExt($file) == "zip") {
					if (strpos($file, $product->extKey) === 0) {
						$backupName = FileSystemHelper::stripExt($file);
						$fileInfo = $folder . $backupName . ".txt";
						if (($data = $this->_parseBackupInfo($fileInfo)) !== false) {
							$i++;
							$aFiles[$i]['extKey'] = $product->extKey;
							$aFiles[$i]['version'] = $data["version"];
							$aFiles[$i]['name'] = $file;
							$aFiles[$i]['title'] = date("M d, Y - H:i:s", strtotime($data["createDate"]));
							$aFiles[$i]['comment'] = $data["comment"];
							if (JFolder::exists($folder . $backupName . DS)) {
								$aFiles[$i]['conflicted'] = 1;
								$aFiles[$i]['conflictedFolder'] = $backupName;
							} else {
								$aFiles[$i]['conflicted'] = 0;
							}
						}
					}
				}
			}
			if ($i >= 0) {
				//sort by newer down to older
				$aFiles = array_reverse($aFiles);
				//group by version
				return $this->msort($aFiles, 'version');
			} else {
				//throw new Exception('[UpdaterClient->listBackupFiles] No backup file is found', 100);
				return false;
			}
		} else {
			//throw new Exception('[UpdaterClient->listBackupFiles] No backup file is found', 100);
			return false;
		}
	}


	function listBackupConflicted($product, $version)
	{
		$backupDir = $this->getLocalConflictBasePath($product);
		
		$aFolders = array();
		
		$handle = opendir($backupDir);
		$i = -1;
		while (($entry = readdir($handle)) !== false) {
			$path = $backupDir . $entry . DS;
			if ($entry != '.' && $entry != '..' && JFolder::exists($path)) {
				$i++;
				$aFolders[$i] = array();
				$aFolders[$i]['name'] = $entry;
				$aFolders[$i]['title'] = date("M d, Y - H:i:s", $entry);
				if (JFile::exists($path . "jaupdater.comment.txt")) {
					$aFolders[$i]['comment'] = file_get_contents($path . "jaupdater.comment.txt");
				}
			}
		}
		closedir($handle);
		
		if ($i >= 0) {
			return $this->msort($aFolders, 'name');
		} else {
			return false;
		}
	}


	function msort($array, $id = "id")
	{
		$temp_array = array();
		while (count($array) > 0) {
			$lowest_id = 0;
			$index = 0;
			foreach ($array as $item) {
				if ($item[$id] > $array[$lowest_id][$id]) {
					$lowest_id = $index;
				}
				$index++;
			}
			$temp_array[] = $array[$lowest_id];
			$array = array_merge(array_slice($array, 0, $lowest_id), array_slice($array, $lowest_id + 1));
		}
		return $temp_array;
	}


	function doRecoveryFile($product, $file)
	{
		$folder = $this->getLocalBackupPath($product);
		
		$pro = new jaProducts($product, $this->config);
		$result = $pro->doRecovery($product, $folder, $file);
		
		if ($result) {
			return $result;
		} else {
			jaucRaiseMessage('Unsuccessfully Rollback', true);
			//throw new Exception('[UpdaterClient->doRecoveryFile] Recovery is fail', 100);
			return false;
		}
	}


	/**
	 * LOCAL REPO METHODS
	 */
	/**
	 * method isNewerVersion
	 * @desc check if version 1 is newer than version 2
	 *
	 * @param string $ver1
	 * @param string $ver2
	 * @param boolean $equalIs
	 * @return
	 * 0 - if version 1 is older than version 2
	 * 1 - if version 1 is newer than version 2
	 * 2 - if can not detect status
	 */
	function isNewerVersion($ver1, $ver2, $equalIs = false)
	{
		if ($ver1 == $ver2) {
			return ($equalIs) ? 1 : 0;
		} else {
			$aVer1 = explode('.', $ver1);
			$aVer2 = explode('.', $ver2);
			$cnt1 = count($aVer1);
			$cnt2 = count($aVer2);
			$cnt = max($cnt1, $cnt2);
			
			$i = -1;
			/*check what is newer version*/
			$result = 1;
			//first: set ver1 as newer version, ver2 as older version
			while ($i < $cnt) {
				$i++;
				if (isset($aVer1[$i]) && isset($aVer2[$i])) {
					if (intval($aVer1[$i]) < intval($aVer2[$i])) {
						$result = 0;
						break;
					} elseif (intval($aVer1[$i]) > intval($aVer2[$i])) {
						break;
					}
					if ($i == $cnt - 1) {
						//two versions are the same
						//but one of which is Beta or Alpha version
						$result = 2;
					}
				} elseif (isset($aVer1[$i])) {
					break;
				} elseif (isset($aVer2[$i])) {
					$result = 0;
					break;
				}
			}
			return $result;
		}
	}


	function getVersionChecksum($path)
	{
		$cache = $path . "jaupdater.checksum.json";
		if (JFile::exists($cache)) {
			return file_get_contents($cache);
		} else {
			$md5CheckSums = new CheckSumsMD5();
			$crc = $md5CheckSums->dumpCRCObject($path);
			$json = json_encode($crc);
			JFile::write($cache, $json);
			
			return $json;
		}
	}


	/**
	 * GET PATH OF PRODUCT ON LOCAL REPOSITORY
	 */
	function getLocalBasePath($product)
	{
		$basePath = JA_WORKING_DATA_FOLDER . $product->coreVersion . DS;
		if ($product->type == 'plugin' && isset($product->group) && !empty($product->group)) {
			$path = $basePath . $product->type . DS . $product->group . DS . $product->extKey . DS;
		} else {
			$path = $basePath . $product->type . DS . $product->extKey . DS;
		}
		return $path;
	}


	function getLocalVersionsPath($product, $checkExists = true)
	{
		$path = $this->getLocalBasePath($product) . "versions" . DS;
		if (JFolder::exists($path) || !$checkExists) {
			return $path;
		} else {
			return false;
		}
	}


	function getLocalVersionPath($product, $checkExists = true)
	{
		$path = $this->getLocalVersionsPath($product, $checkExists) . $product->version . DS;
		if (JFolder::exists($path) || !$checkExists) {
			return $path;
		} else {
			return false;
		}
	}


	function getLocalPatchPath($product)
	{
		$path = $this->getLocalBasePath($product) . "patch" . DS;
		if (!JFolder::exists($path)) {
			if (!FileSystemHelper::createDirRecursive($path, 0777)) {
				return false;
			}
		}
		return $path;
	}


	function getLocalBackupPath($product)
	{
		$path = $this->getLocalBasePath($product) . "backup" . DS;
		if (!JFolder::exists($path)) {
			if (!FileSystemHelper::createDirRecursive($path, 0777)) {
				return false;
			}
		}
		return $path;
	}


	function getLocalConflictPath($product, $folder = '')
	{
		if ($folder == '') {
			//create new folder to backup conflicted files
			//$date = date("YmdHis");
			$folder = time();
		}
		//store same folder with backup files
		$path = $this->getLocalBasePath($product) . "backup" . DS . $folder . DS;
		if (!JFolder::exists($path)) {
			if (!FileSystemHelper::createDirRecursive($path, 0777)) {
				return false;
			}
		}
		return $path;
	}


	function getLocalConflictBasePath($product)
	{
		$path = $this->getLocalBasePath($product) . "backup" . DS;
		if (!JFolder::exists($path)) {
			if (!FileSystemHelper::createDirRecursive($path, 0777)) {
				return false;
			}
		}
		return $path;
	}

}
