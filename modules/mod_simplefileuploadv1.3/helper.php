<?php

defined('_JEXEC') or die('Direct Access to this location is not allowed.');


class ModSimpleFileUploaderHelperv13{	
	
	function getUploadForm(
			&$params,
			$upload_location,
			$sfu_basepath,
			$mid, 
			$upload_users,
			$users_name
		) {			
		
			// Get settings:
			$upload_maxsize = $params->get( 'upload_maxsize', '100000' );
			$upload_filetypes = $params->get( 'upload_filetypes', '' );
			$upload_fileexist = $params->get( 'upload_fileexist', '' );
			$upload_email = $params->get( 'upload_email', '' );
			$upload_emailmsg = $params->get( 'upload_emailmsg', '0' );
			$upload_emailhtml = $params->get( 'upload_emailhtml', '1' );
			$upload_unzip = $params->get( 'upload_unzip', '0' );
			$upload_showerrmsg = $params->get( 'upload_showerrmsg', '1' );
			$upload_showdircontent = $params->get( 'upload_showdircontent', '0' );
			$upload_popshowpath = $params->get( 'upload_popshowpath', '1' );
			$upload_popshowbytes = $params->get( 'upload_popshowbytes', '0' );
			$upload_blacklist = $params->get( 'upload_blacklist', '.php .php3 .php4 .php5 .php6 .phtml .pl .py .jsp .asp .htm .shtml .sh .cgi .exe .bat .cmd .htaccess' );
			$upload_doubleext = $params->get( 'upload_doubleext', '1' );
			$upload_phpext = $params->get( 'upload_phpext', '1' );
			$upload_gifcomment = $params->get( 'upload_gifcomment', '1' );
			$upload_mailfrom = $params->get( 'upload_mailfrom' , 'noreply@simplefileupload.com' );
			$upload_maximgwidth = $params->get( 'upload_maximgwidth', '0' );
			$upload_maximgheight = $params->get( 'upload_maximgheight', '0' );
			$upload_compressimg = $params->get( 'upload_compressimg', '' );
			$upload_disablegdlib = $params->get( 'upload_disablegdlib', '0' );
			$upload_disablegdthreshold = $params->get( 'upload_diablegdthreshold', '0' );
			
			$upload_thumbcreate = $params->get( 'upload_thumbcreate', '0' );
			$upload_thumbsize = $params->get( 'upload_thumbsize', '40x40' );
			$upload_thumbname = $params->get( 'upload_thumbname', 'sfuthumb' );
			$upload_debug = $params->get( 'upload_debug', '0' );
			
			$upload_formfields = $params->get( 'upload_formfields', '' );
			$upload_useformsfields = $params->get( 'upload_useformsfields', '0' );
			if ($upload_useformsfields == 0) 
				$upload_formfields = "";
			$upload_formfieldsfile = $params->get( 'upload_formfieldsfile', '' );
			$upload_formfieldsdiv = $params->get( 'upload_formfieldsdiv', '|' );
			
			$upload_nohtmlencoding = $params->get( 'upload_nohtmlencoding', '0' );
			$upload_replacetag = $params->get( 'upload_replacetag', '0' );
		    
			$results = "";
			$fileCnt = 0;
			$fileErr = 0;
			$written = 0;
			$filename = "";
			$fileList = "";
			$fileInfo = "";
			$filetypeok = true;
			$filetype = "";
			$blacklist = explode(" ", $upload_blacklist);
			$formfieldsval = array();
			$formfieldsemail = array();
			$chkfileexist = "";

			$baseurl = "";
			$serverurl = "";
			$protocol = "";
			$protocol = "http://";
		
			if (substr($_SERVER["HTTP_REFERER"], 0, 5) === "https") $protocol = "https://";
			$folder = substr($_SERVER['SCRIPT_NAME'], 0, strrpos($_SERVER['SCRIPT_NAME'], "/"));
			if ($folder === "//") $folder = "";
			// Check if relative path
			if (substr($upload_location, 0, 1) === ".") {
				$serverurl .= str_replace(".", $protocol.$_SERVER["HTTP_HOST"].$folder, $upload_location);
				// Fix Windows path...
				$baseurl .= str_replace("\\", "", $serverurl);
			} else {
				if ((substr($upload_location, 1, 2) === ":\\") || (substr($upload_location, 0, 1) === "/")) {
					// Server root path
					$baseurl = "file://".str_replace("\\", "/", $upload_location);
				} else {
					$serverurl = str_replace("\\", "/", $_SERVER["DOCUMENT_ROOT"]);
					$baseurl = str_replace("\\", "/", $upload_location);
					$baseurl = str_replace($serverurl, "", $baseurl);
					//$baseurl = dirname($_SERVER["HTTP_REFERER"])."/".$baseurl;
					$baseurl = $protocol.$_SERVER["HTTP_HOST"].$folder."/".$baseurl;
				}
			}
			//Replace space with %20 for URL
			$baseurl = str_replace(" ", "%20", $baseurl);
			// Make sure it ends with front slash
			if ( substr( $baseurl , strlen($baseurl) - 1) !== "/" ) {
				$baseurl .= "/";
			}
			
			if(is_array($_FILES["uploadedfile$mid"]["name"])) {
				foreach($_FILES["uploadedfile$mid"]["name"] as $value) {
					/* Not really useful since I need type and size as well... just use $_FILES
					if(strlen($value) > 0) {
						//Check that we have a filename
						$filenames[] = $value;
					}*/
					$fileCnt += 1;
				}
			}
			
			for ($cnt = 0; $cnt<$fileCnt; $cnt++) {
			
				if ((strlen($_FILES["uploadedfile$mid"]["name"][$cnt]) > 0) && ($upload_users === "true")) {
				
					// Check blacklist first
					foreach ($blacklist as $file) {
						$filename = $_FILES["uploadedfile$mid"]["name"][$cnt];
						
						if (preg_match("/$file\$/i", $filename)) {
							$filetypeok = false;
							break;
						}
					}
					
					// Check double extension
					if ($upload_doubleext === "1" || $upload_phpext === "1") {
					
						$exts = explode('.', $filename);
						// There is more than one dot!
						if (count($exts) > 2) {
							// Any double extension blocked
							if ($upload_doubleext === "1") 
								$filetypeok = false;
							
							if ($upload_phpext === "1") {
								// Block .php.
								if (strtolower($exts[count($exts)-2]) === "php") 
									$filetypeok = false;
							}
						} else {
							// Check and block any .php combination
							if (stripos($filename, ".php") !== false) 
								$filetypeok = false;
						}
					}
					
					
					if ($_FILES["uploadedfile$mid"]["error"][$cnt] > 0) {
						// Check if there was any error
						$filetypeok = false;
					}

					if ($filetypeok) {
						$fileList .= $_FILES["uploadedfile$mid"]["name"][$cnt] . "|";
						$filetype = $_FILES["uploadedfile$mid"]["type"][$cnt];
						$fileInfo .= "(" . JText::_('TYPE') . ": " . $filetype . " " . JText::_('SIZE') . ": " . $_FILES["uploadedfile$mid"]["size"][$cnt] . " " . JText::_('BYTES') . ")|";
						
						if ($filetype === "") $filetype = "false";
						if (stripos($upload_filetypes, $filetype) === false) {
							$filetypeok = false;
						} else {
							$filetypeok = true;
						}
						if ($upload_filetypes === "*") {
							$filetypeok = true;
						}
						
						//Check if GIF and block GIF Comment
						if ($upload_gifcomment === "1" && (preg_match("/.gif\$/i", $_FILES["uploadedfile$mid"]["name"][$cnt]))) {
						
							$comment = ModSimpleFileUploaderHelperv13::getGIFComment($_FILES["uploadedfile$mid"]["tmp_name"][$cnt], $upload_debug);
							if(stripos($comment, "getGIFComment:BLOCK") !== false) {
								$filetypeok = false;
							}
							if ($upload_debug == 1) $results .= $comment;
						
						}
						
					}
					
					if (($filetypeok) && ($_FILES["uploadedfile$mid"]["size"][$cnt] < $upload_maxsize)) {
						$errmsg = "";
						$new_filename = "";
						
						if ($_FILES["uploadedfile$mid"]["error"][$cnt] > 0) {
							if (($_FILES["uploadedfile$mid"]["size"][$cnt] == 0) && ($_FILES["uploadedfile$mid"]["error"][$cnt] == 2)) {
								$errmsg = "(<span style='color:#dd2222'>".$_FILES["uploadedfile$mid"]["name"][$cnt].")</span>".JText::sprintf('ERROR_TOO_BIG', "<br />[PHP Error: " . $_FILES["uploadedfile$mid"]["error"][$cnt]) . "]<br />";
							} else {
								$errmsg = "(<span style='color:#dd2222'>".$_FILES["uploadedfile$mid"]["name"][$cnt].")</span>".JText::sprintf('ERROR_LABEL', $_FILES["uploadedfile$mid"]["error"][$cnt]) . "<br />";
							}
							if ($upload_showerrmsg == 1) 
								$results .= $errmsg;
							else
								$results .= JText::_('UPLOAD_FAILED');
							$fileErr = 1;
						} else {
							$bytesfilesize = $_FILES["uploadedfile$mid"]["size"][$cnt];
							// Check to see if GD lib functions should be skipped
							if ($upload_disablegdthreshold > 0) {
								if ($bytesfilesize >= $upload_disablegdthreshold) $upload_disablegdlib = 1;
							}
					  		$filesize = ModSimpleFileUploaderHelperv13::getFileSizePP($bytesfilesize);
							if (($upload_popshowbytes == 1) && ($bytesfilesize != $filesize)) $filesize = $filesize . " (" . $bytesfilesize . " " . JText::_('BYTES') . ")";
							//$results .= "<strong>" . JText::_('FILE_OK_MSG') . "</strong><br /><br />";
							$results .= "<span style='color:#55dd55'>".JText::sprintf('FILE_UPLOAD_LABEL', $_FILES["uploadedfile$mid"]["name"][$cnt]) . "</span><br />";
							$results .= JText::sprintf('FILE_TYPE_LABEL', $_FILES["uploadedfile$mid"]["type"][$cnt]) . "<br />";
							$results .= JText::sprintf('FILE_SIZE_LABEL', $filesize) . "<br />";
							#$results .= "uploaded to: " . $_FILES["uploadedfile$mid"]["tmp_name"][$cnt] . "<br />";
					  		if (file_exists($upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt])) {
								if ( $upload_fileexist === "0" ) {
									// FAIL
									$results .= "<br /><strong>" . JText::sprintf('FILE_EXISTS_MSG', $_FILES["uploadedfile$mid"]["name"][$cnt]) . "</strong><br /><br />" . JText::_('FILE_EXISTS_CORR');
									$fileErr = 1;
								}
								/* // Don't delete until new file has been created!
								if ( $upload_fileexist === "1" ) {
									// REPLACE
									unlink($upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt]);
									$results .= JText::_('FILE_EXISTS_REPLACE') . "<br />";
									$chkfileexist = "no";
								}*/
								
								if ( $upload_fileexist === "2" || $upload_fileexist === "1" ) {
									// BACKUP
									$new_filename = $_FILES["uploadedfile$mid"]["name"][$cnt] . microtime();
									rename($upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt], $upload_location . $new_filename);
									if ($upload_fileexist === "1")
										$results .= JText::_('FILE_EXISTS_REPLACE') . "<br />";
									else
										$results .= JText::sprintf('FILE_EXISTS_BACKUP',  $new_filename) . "<br />";
									$new_filename = $upload_location . $new_filename;
									$chkfileexist = "no";
								}
							} else {
								$chkfileexist = "no";
							}
							
							if ( $chkfileexist === "no" ) {
							
								// Resize and/or compress?
								$image_resize = false;
								$img_compressimg = 0;
								$img_maximgheight = 0;
								$img_maximgwidth = 0;
								// Check size of images before moving
								if (ModSimpleFileUploaderHelperv13::gd_get_info() && $upload_disablegdlib == 0) {
									
									if (($img = @getimagesize($_FILES["uploadedfile$mid"]["tmp_name"][$cnt])) && (((is_numeric($upload_maximgwidth) && $upload_maximgwidth > 0) || (is_numeric($upload_maximgheight) && $upload_maximgheight > 0)) || ($upload_thumbcreate == 1))) {
										list($width, $height, $type, $attr) = getimagesize($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]);
									
										// Make sure we have a valid compression ratio
										if (!is_numeric($upload_compressimg) || $upload_compressimg > 100 || $upload_compressimg <= 0)
											$img_compressimg = 100;
										else
											$img_compressimg = $upload_compressimg;
								
										if ($upload_maximgheight == 0) 
											$img_maximgheight = $height;
										else
											$img_maximgheight = $upload_maximgheight;
											
										if ($upload_maximgwidth == 0)
											$img_maximgwidth = $width;
										else
											$img_maximgwidth = $upload_maximgwidth;
										
										$ratioh = $img_maximgheight/$height;
										$ratiow = $img_maximgwidth/$width;
										$ratio = min($ratioh, $ratiow);
										// New dimensions
										$n_width = intval($ratio*$width);
										$n_height = intval($ratio*$height); 
										
										$errmsg = "";
										switch ($type) {
											case 1: //'image/gif'
												if (imagetypes() & IMG_GIF)  { // not the same as IMAGETYPE
													$oim = imageCreateFromGIF($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]) ;
												} else {
													$errmsg = "GIF ".JText::_('IMG_TYPE_FAIL')."<br />";
												}
												break;
											case 2: //'image/jpeg'
												if (imagetypes() & IMG_JPG)  {
													$oim = imageCreateFromJPEG($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]) ;
												} else {
													$errmsg = "JPEG ".JText::_('IMG_TYPE_FAIL')."<br />";
												}
												break;
											case 3: //'image/png'
												if (imagetypes() & IMG_PNG)  {
													$oim = imageCreateFromPNG($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]) ;
													$img_compressimg = round($img_compressimg / 10); // Quality is 0-9 for PNG
													if ($img_compressimg >= 10) $img_compressimg = 9; // If user has set quality to 100
												} else {
													$errmsg = "PNG ".JText::_('IMG_TYPE_FAIL')."<br />";
												}
												break;
											case 15: //'image/wbmp'
												if (imagetypes() & IMG_WBMP)  {
													$oim = imageCreateFromWBMP($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]) ;
												} else {
													$errmsg = "WBMP ".JText::_('IMG_TYPE_FAIL')."<br />";
												}
												break;
											default:
												$errmsg = $type." ".JText::_('IMG_TYPE_FAIL')."<br />";
												break;
										}

										if ($errmsg === "") {

											// If thumbnail
											$thumbfilename = "";
											if ($upload_thumbcreate == 1) {

												$img_thumbsize = strtolower($upload_thumbsize);
												$img_thumbsize = explode("x", $img_thumbsize);
												if (is_array($img_thumbsize)) {
													if (count($img_thumbsize) == 2) {
														if (is_numeric($img_thumbsize[0]) && is_numeric($img_thumbsize[1])) {
															$ttim=imagecreatetruecolor($img_thumbsize[0],$img_thumbsize[1]);
															imagecopyresampled($ttim,$oim,0,0,0,0,$img_thumbsize[0],$img_thumbsize[1],$width,$height);
															$ext = substr(strrchr($_FILES["uploadedfile$mid"]["name"][$cnt], '.'), 1);
															$thumbfilename .= substr($_FILES["uploadedfile$mid"]["name"][$cnt], 0, (strlen($_FILES["uploadedfile$mid"]["name"][$cnt])-(strlen($ext) +1))) . "_" . $upload_thumbname . "." . $ext;
															// Make thumb as a link
															$results .= JText::_('IMG_THUMB_FILE') . ' <a href="'.$baseurl.str_replace(" ", "%20", $thumbfilename).'" target="blank">'.$thumbfilename.'</a><br/>';
															//$results .= JText::_('IMG THUMB FILE') . " " . $thumbfilename . "<br />";
															// Add path to thumb filename
															$thumbfilename = $upload_location . $thumbfilename;
														}
													}
												}
											}
											// Only thumbnail, no resize
											if ($upload_maximgheight !== 0 && $upload_maximgwidth !== 0) {
												$tim=imagecreatetruecolor($n_width,$n_height);
												imagecopyresampled($tim,$oim,0,0,0,0,$n_width,$n_height,$width,$height);
											}

											switch ($type) {
												case 1:
													// Only thumbnail, no resize
													if ($upload_maximgheight !== 0 && $upload_maximgwidth !== 0)
														imageGIF($tim, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt]);
													if ($thumbfilename !== "") imageGIF($ttim, $thumbfilename);
													$image_resize = true;
													break;
												case 2:
													// Only thumbnail, no resize
													if ($upload_maximgheight !== 0 && $upload_maximgwidth !== 0)
														imageJPEG($tim, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt], $img_compressimg);
													if ($thumbfilename !== "") imageJPEG($ttim, $thumbfilename);
													$img_compressimg = "";
													$image_resize = true;
													break;
												case 3:
													// Only thumbnail, no resize
													if ($upload_maximgheight !== 0 && $upload_maximgwidth !== 0)
														imagePNG($tim, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt], $img_compressimg);
													if ($thumbfilename !== "") imagePNG($ttim, $thumbfilename);
													$img_compressimg = "";
													$image_resize = true;
													break;
												case 15:
													// Only thumbnail, no resize
													if ($upload_maximgheight !== 0 && $upload_maximgwidth !== 0)
														imageWBMP($tim, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt]);
													if ($thumbfilename !== "") imageWBMP($ttim, $thumbfilename);
													break;
													$image_resize = true;
												default:
													$image_resize = false;
													break;
											}
												
											// Only thumbnail, no resize
											if ($upload_maximgheight !== 0 && $upload_maximgwidth !== 0) {
												imagedestroy($tim);
												if ($image_resize)
													$results .= JText::_('IMG_ORIG_RESIZE')."<br />";
												else
													$results .= JText::_('IMG_RESIZE_FAIL')."<br />";
											} else {
												$image_resize = false;
											}
											
											imagedestroy($oim);
											if ($thumbfilename !== "") imagedestroy($ttim);
											
										} else {
											
											$fileErr = 1;
											$results .= JText::_('FAIL_REQUEST') . "<br />";
											$_SESSION["failedfile"] .= $_FILES["uploadedfile$mid"]["name"][$cnt]." (".JText::_('IMG_SAVE_FAIL').", ".$errmsg.")</br />";
										}
									}
									
									if (($img = @getimagesize($_FILES["uploadedfile$mid"]["tmp_name"][$cnt])) && (!$image_resize) && ($upload_compressimg !== "") && is_numeric($upload_compressimg)) {
										// Compress JPEG? This only happens if no resize!
										list($width, $height, $type, $attr) = getimagesize($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]);
										
										// Make sure we have a valid compression ratio
										if ($upload_compressimg > 100 || $upload_compressimg <= 0) $img_compressimg = 100;
										
										if (($type == 2) && (is_numeric($img_compressimg)) && ($fileErr == 0)) {
										
											$oim = imagecreatefromjpeg($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]);
											
											if (imagejpeg($oim, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt], $img_compressimg)) {
												$fileErr = 0;
												$image_resize = true;
											} else {
												$fileErr = 1;
												$results .= JText::_('FAIL_REQUEST') . "<br />";
												$_SESSION["failedfile"] .= $_FILES["uploadedfile$mid"]["name"][$cnt]." (".JText::_('IMG_COMPRESS_FAIL').")</br />";
											}
											imagedestroy($oim);
										}
										
										// Compress PNG? This only happens if no resize!
										if (($type == 3) && (is_numeric($upload_compressimg)) && ($fileErr == 0)) {
										
											$oim = imagecreatefrompng($_FILES["uploadedfile$mid"]["tmp_name"][$cnt]);
											
											$img_compressimg = round($upload_compressimg / 100); // Quality is 0-9 for PNG
											if ($img_compressimg >= 10) $img_compressimg = 9; // If user has set quality to 100
											
											if (imagepng($oim, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt], $img_compressimg)) {
												$fileErr = 0;
												$image_resize = true;
											} else {
												$fileErr = 1;
												$results .= JText::_('FAIL_REQUEST') . "<br />";
												$_SESSION["failedfile"] .= $_FILES["uploadedfile$mid"]["name"][$cnt]." (".JText::_('IMG_COMPRESS_FAIL').")</br />";
											}
											imagedestroy($oim);
										}
										
										if ($image_resize)
											$results .= JText::_('IMG_ORIG_COMPRESS')."<br />";
										else
											$results .= JText::_('IMG_COMPRESS_FAIL')."<br />";
									}	
								}

								// If image has been resized it is already saved
								if (!$image_resize) {
									if (move_uploaded_file($_FILES["uploadedfile$mid"]["tmp_name"][$cnt], $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt])) {
										$fileErr = 0;										
									} else {
										$fileErr = 1;
										$results .= JText::_('FAIL_REQUEST') . "<br />";
										$_FILES["uploadedfile$mid"]["name"][$cnt] = "";
									}
								}
								
								
								// Form Fields
								if (($upload_useformsfields == 1) && (strlen($upload_formfields) > 0) && ($fileErr == 0)) {

									$fields = explode(";", $upload_formfields);
									$valname = "";
									$valfile = "";
									$ffform = "";
									$fffield = "";
									$formfieldsemail[$cnt] = "";

									if ($upload_nohtmlencoding == 1)
										$ffform = trim ( $_REQUEST["sfuFormFields$mid"] );
									else
										$ffform = htmlentities ( trim ( $_REQUEST["sfuFormFields$mid"] ) , ENT_NOQUOTES , "utf-8" );
									if ($upload_debug == 1) print_r($_REQUEST);
									
									if ($upload_replacetag == 1) $ffform = str_replace(">", "&gt;", str_replace("<", "&lt;", $ffform));

									if ($upload_debug == 1) $results .= "ffform=$ffform<br/>";
									$ffform = explode("[||]", $ffform);
									
									// If create a row in the form fileds file...
									if (strlen($upload_formfieldsfile) > 0)
										$valfile = $_FILES["uploadedfile$mid"]["name"][$cnt].$upload_formfieldsdiv;
									
									for ($iff = 0; $iff < count($ffform); $iff++) {
										$valname = $ffform[$iff];
										
										$fffield = explode("=", $valname);
										
										foreach ($fields as $fld) {
										
											$valname = "sfuff".$mid."_".$fld."_".$_FILES["uploadedfile$mid"]["name"][$cnt];
											if ($valname === $fffield[0]) {
												if (strlen($upload_formfieldsfile) > 0)
													$valfile .= $fffield[1].$upload_formfieldsdiv;
												else
													$valfile .= $fld."=".$fffield[1]."\n";
												// Store for e-mail, use same counter as file
												$formfieldsemail[$cnt] .= $fld."=".$fffield[1]."\n";
											}
										}
										
										if ($upload_debug == 1) $results .= "valname=$valname<br/>";
										
									}
									
									if (strlen($upload_formfieldsfile) > 0) {
										// Remove last pipe
										$valfile = substr($valfile, 0, -1);
										// Check if we got something
										if ($valfile === $_FILES["uploadedfile$mid"]["name"][$cnt]) 
											$valfile = "";
									}
									
									if ($upload_debug == 1) $results .= "valfile=$valfile<br/>";
									if ((strlen($valfile) > 0) && (strlen($upload_formfieldsfile) == 0)) {
										// Write the file:
											
										$ffFile = $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt] . ".txt";
											
										if ($upload_debug == 1) $results .= "ffFile=$ffFile<br/>";
										$fh = fopen($ffFile, 'w') or $fileErr = 1;
										if ($fileErr == 1) {
											$results .= JText::_('FAIL_FORMFIELDS_FILE') . "<br />";
										} else {
											// For some mysterious reason PHP refuses to write UTF-8 as UTF-8. Some stupid work-around below found at php.net
											$valfile = mb_convert_encoding( $valfile, 'UTF-8'); 
											fwrite($fh, $valfile);
											fclose($fh);
										}
									
									}
									// Store for Form Fields File, use same counter as file
									$formfieldsval[$cnt] = $valfile;
								}
						
								
								if (($upload_popshowpath == 1) && ($fileErr == 0)) {
									$results .= JText::sprintf('FILE_SAVE_AS', '<a href="'.$baseurl.str_replace(" ", "%20", $_FILES["uploadedfile$mid"]["name"][$cnt]).'" target="blank">'.$baseurl.$_FILES["uploadedfile$mid"]["name"][$cnt].'</a>').'<br /><br />';
								}
								
								if ($upload_fileexist === "1" && file_exists($new_filename)) {
									if ($fileErr == 0) {
										// Delete (=replace) of old file
										unlink($new_filename);
									} else {
										// Put original back if something went wrong
										rename($new_filename, $upload_location . $_FILES["uploadedfile$mid"]["name"][$cnt]);
									}
								}
								//$results .= "<div style=\"width: 90%; text-align: right; \"><input type='button' value='" . JText::_('OK_BUTTON') . "' onclick='document.getElementById(\"div_simplefileuploadmsg\").style.display=\"none\";'></div>";
							}
						}

						// UNZIP
						if (($upload_unzip == 1) && ($fileErr == 0)) {
							if (($_FILES["uploadedfile$mid"]["type"][$cnt] === "application/x-tar") || ($_FILES["uploadedfile$mid"]["type"][$cnt] === "application/x-tar-compressed") || ($_FILES["uploadedfile$mid"]["type"][$cnt] === "application/tar-compressed")) {
								//system("tar -zxvf ".$upload_location.$_FILES["uploadedfile$mid"]["name"]);
								$res = shell_exec("cd ".$upload_location.";tar -xvzf ".$_FILES["uploadedfile$mid"]["name"][$cnt].";");
								if ($res === FALSE) {
									$results .= "<p>".JText::_('MSG_UNZIP_ERROR')."</p>";
								} else {
									$results .= "<p>".JText::_('MSG_UNZIP')."</p>";
								}
							}
							if (($_FILES["uploadedfile$mid"]["type"][$cnt] === "application/x-zip") || ($_FILES["uploadedfile$mid"]["type"][$cnt] === "application/x-zip-compressed") || ($_FILES["uploadedfile$mid"]["type"][$cnt] === "application/zip-compressed")) {
								$zip = new ZipArchive;
								$res = $zip->open($upload_location.$_FILES["uploadedfile$mid"]["name"][$cnt]);
								if ($res === TRUE) {
									$zip->extractTo($upload_location);
									$zip->close();
									$results .= "<p>".JText::_('MSG_UNZIP')."</p>";
								} else {
									$results .= "<p>".JText::_('MSG_UNZIP_ERROR')."</p>";
								}
							}
						}
						$_SESSION["uploaderr$mid"] = $fileErr;
					} else {
						$fileErr = 1;
						$errmsg = "(<span style='color:#dd2222'>".$_FILES["uploadedfile$mid"]["name"][$cnt].")</span><div>".JText::sprintf('FILE_IN_ERROR', $filetype)."<br />&nbsp;&nbsp;[".ModSimpleFileUploaderHelperv13::errCodeToMessage($_FILES["uploadedfile$mid"]["error"][$cnt])."]</div><br />";
						$_SESSION["uploaderr$mid"] = 1;
						if ($upload_showerrmsg == 1)
							$results .= $errmsg;
						else
							$results .= JText::_('UPLOAD_FAILED')."<br /><br />";
						
						if ($written == 0) {
							$filesize = ModSimpleFileUploaderHelperv13::getFileSizePP($upload_maxsize);
							$results .= JText::_('ALLOWED_TYPES') . ": " . $upload_filetypes . "<br />" . JText::_('FILE_MAX_SIZE') . ": " . $filesize . "<br /><br />";
							//$results .= "<div style=\"width: 90%; text-align: right;\"><input type='button' value='" . JText::_('OK BUTTON') . "' onclick='document.getElementById(\"div_simplefileuploadmsg\").style.display=\"none\";'></div>";
							$written = 1;
						}
					}
				} else {
					if ($upload_users === "false") {
						$_SESSION["uploaderr$mid"] = 1;
						$results .= JText::_('NOT_ALLOWED_USER');
					}
				}
			} // end for

			// Create Form Fields file
			if ((count($formfieldsval) > 0) && (strlen($upload_formfieldsfile) > 0)) {
				// Write the file but read first if the same file exists from previous set:
				$valfile = "";
				
				$ffFile = $upload_location . $upload_formfieldsfile;
				
				if (file_exists($ffFile)) {
					//RegExp can't handle pipe, make it escaped
					// !! Not needed for explode(), only deprecated split() !!
					//$upload_formfieldsdiv2 = $upload_formfieldsdiv;
					//if ($upload_formfieldsdiv === "|") $upload_formfieldsdiv2 = "\|";
					
					$fileRows = explode("\n", file_get_contents($ffFile));
					for ($cnt = 0; $cnt<count($fileRows); $cnt++) { 
						$rowdata = $fileRows[$cnt];
						//Remove the UTF-8 chars
						//if (substr($rowdata, 0, 2) === chr(255).chr(254)) $rowdata = substr($rowdata, 2);
//echo "rowdata=$rowdata<br/>";
						if (strpos($rowdata, $upload_formfieldsdiv) >= 0) {
							$rowArray = explode($upload_formfieldsdiv, $rowdata);
							if (strlen($rowArray[0]) > 0) {
								$found = false;
								for ($cnt2 = 0; $cnt2<count($formfieldsval); $cnt2++) {
									$ffArray = explode($upload_formfieldsdiv, $formfieldsval[$cnt2]);
//echo "{".$ffArray[0]."}={".$rowArray[0]."}<br/>";
//echo "replace: [".str_replace($ffArray[0], "", $rowArray[0])."]<br/>";
									// Equal on string seems not reliable. Maybe encoding issues but replace does the trick it seems.
									//if ($ffArray[0] === $rowArray[0]) {
									if (strlen(str_replace($ffArray[0], "", $rowArray[0])) == 0) {
//echo "inside!<br/>";									
										$valfile .= $formfieldsval[$cnt2]."\n";
										$formfieldsval[$cnt2] = "";
										$found = true;
										break;
									}
								}
								if (!$found) $valfile .= $rowdata."\n";
							}
						}
					}
				}

				$fh = fopen($ffFile, 'w') or $fileErr = 1;
				if ($fileErr == 1) {
					$results .= JText::_('FAIL_FORMFIELDS_FILE') . "<br />";
				} else {
				
					for ($cnt = 0; $cnt<count($formfieldsval); $cnt++) {
						// Add the new files here
						if (strlen($formfieldsval[$cnt]) > 0)
							$valfile .= $formfieldsval[$cnt]."\n";
					}
					
					// Don't make the file UTF-8 here as it totally messes up the reading of the file!
					// For some mysterious reason PHP refuses to write UTF-8 as UTF-8. Some stupid work-around below found at php.net
					//$valfile = chr(255).chr(254).mb_convert_encoding( $valfile, 'UTF-16LE', 'UTF-8'); 
					
//echo "valfile=$valfile<br/>";
					fwrite($fh, $valfile);
					fclose($fh);
				}
			
			}
			
			// SHOW DIR CONTENT
			if (($upload_showdircontent == 1) && ($fileErr == 0)) {
				$results .= "<br /><div style=\"text-align: left\">";
				if($bib = @opendir($upload_location)) {
					while (false !== ($lfile = readdir($bib))) {
						//if($lfile != "." && $lfile != ".." && !ereg("^\..+", $lfile) && $lfile != "index.html") {
						if($lfile !== "." && $lfile !== ".." && !preg_match("/^\..+/", $lfile) && $lfile !== "index.html") {
							$fil_list[] = "<a href=\"$upload_location/$lfile\" target=\"blank\">$lfile</a>";
						}
					}
					closedir($bib);
					
					if(is_array($fil_list)) {
						$liste = "<li>" . join("</li><li>", $fil_list) . "</li>";
					} else {
						$liste = "<li>" . JText::_('NO_FILES_FOUND') . " " . $upload_location . "</li>";
					}
					$results .=  "<h2>" . JText::_('FILES_IN_DIR') . " (" . $upload_location . "):</h2><ul>" . $liste . "</ul>";
				} else {
					//die("Could not read files in " . $upload_location);
					$results .=  "<h2>" . JText::_('NO_FILES_FOUND') . "</h2><br/>";
				}
				$results .= "</div><br/>";
			}

			// SEND E-MAIL
			if ((strlen($upload_email) > 0) && ($fileErr == 0)) {
				$to = $upload_email;
				$subject = JText::_('MAIL_SUBJECT');
				$infos = explode("|", $fileInfo);
				$text = "";
				$headers = "";
				//Replace space with %20 for URL
				if ($upload_emailhtml == 0) {
					for ($cnt = 0; $cnt<$fileCnt;  $cnt++) {
						if(strlen($_FILES["uploadedfile$mid"]["name"][$cnt]) > 0)
							$text .= $upload_location.$_FILES["uploadedfile$mid"]["name"][$cnt]." (".$baseurl.str_replace(" ", "%20", $_FILES["uploadedfile$mid"]["name"][$cnt]).")\r\n";
						if (count($formfieldsemail) >= $cnt+1) {
							if (strlen($formfieldsemail[$cnt]) > 0)
								$text .= $formfieldsemail[$cnt] . "\r\n\r\n";
						}
					}
					$body = JText::sprintf('MAIL_BODY', $_SERVER["HTTP_HOST"]);
					$body .= "\r\n\r\n".$text;
					$body .= "\r\n\r\n(Find out more about Simple File Upload for Joomla at http://wasen.net/)";
				} else {
					$text = "<br /><br/><table>";
					for ($cnt = 0; $cnt<$fileCnt; $cnt++) {
						if(strlen($_FILES["uploadedfile$mid"]["name"][$cnt]) > 0)
							$text .= "<tr><td>".$upload_location.$_FILES["uploadedfile$mid"]["name"][$cnt]." (".$baseurl.str_replace(" ", "%20", $_FILES["uploadedfile$mid"]["name"][$cnt]).")</td><td>".$infos[$cnt]."</td></tr>";
							if (count($formfieldsemail) >= $cnt+1) {
								if (strlen($formfieldsemail[$cnt]) > 0) {
									$fields = explode("\n", $formfieldsemail[$cnt]);
									foreach ($fields as $f)
										$text .= "<tr><td>" . $f . "</td></tr>";
								}
							}
					}
					$text .= "<table><br />";
					$body = JText::sprintf('MAIL_BODY', $_SERVER["HTTP_HOST"]);
					if (strlen($users_name) < 5) $users_name = "Anonymous (@".$_SERVER['REMOTE_ADDR'].")";
					$body .= " ".JText::sprintf('BY_USER', $users_name);
					$body .= $text;
					$body .= "<br /><br/><small>(Find out more about Simple File Upload for <a href='http://www.joomla.org/'>Joomla</a> at <a href='http://wasen.net/'>http://wasen.net/</a>)</small>";
					// To send HTML mail, the Content-type header must be set
					$headers = 'MIME-Version: 1.0' . "\r\n";
					$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
					// Additional headers
					//$headers .= 'To: ' . $to . "\r\n";
					$headers .= 'From: ' . $upload_mailfrom . "\r\n";
				}

				if (mail($to, $subject, $body, $headers)) {
					if ($upload_emailmsg == 1)
						$results .= "<p>".JText::_('MSG_SENT')."</p>";
				} else {
					if ($upload_emailmsg == 1)
						$results .= "<p>".JText::_('MSG_FAILED')."(To:".$to.")</p>";
				}
			}

			return $results;
		}
		
		
		function gd_get_info() {
			if (extension_loaded('gd') and
				imagetypes() & IMG_PNG and
				imagetypes() & IMG_GIF and
				imagetypes() & IMG_JPG and
				imagetypes() & IMG_WBMP) {
			   
				return true;
			} else {
				return false;
			}
		}

		function getFileSizePP($filesize) {

			$kb=1024;
			$mb=1048576;
			$gb=1073741824;
			$tb=1099511627776;
			
			if(!$filesize)
				$filesize = '0 B';
			elseif($filesize<$kb)
				$filesize = $filesize.' B';
			elseif($filesize<$mb)
				$filesize = round($filesize/$kb, 2).' KB';
			elseif($filesize<$gb)
				$filesize = round($filesize/$mb, 2).' MB';
			elseif($filesize<$tb)
				$filesize = round($filesize/$gb, 2).' GB';
			else
				$filesize = round($filesize/$tb, 2).' TB';
			
			return $filesize;
		}
		
		function errCodeToMessage($code) {
			$message = "";
			
			switch ($code) {
				case UPLOAD_ERR_INI_SIZE:
					$message = JText::_('UPLOAD_ERR_INI_SIZE');	//"The uploaded file exceeds the upload_max_filesize directive in php.ini";
					break;
				case UPLOAD_ERR_FORM_SIZE:
					$message = JText::_('UPLOAD_ERR_FORM_SIZE');	//"The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form";
					break;
				case UPLOAD_ERR_PARTIAL:
					$message = JText::_('UPLOAD_ERR_PARTIAL');	//"The uploaded file was only partially uploaded";
					break;
				case UPLOAD_ERR_NO_FILE:
					$message = JText::_('UPLOAD_ERR_NO_FILE');	//"No file was uploaded";
					break;
				case UPLOAD_ERR_NO_TMP_DIR:
					$message = JText::_('UPLOAD_ERR_NO_TMP_DIR');	//"Missing a temporary folder";
					break;
				case UPLOAD_ERR_CANT_WRITE:
					$message = JText::_('UPLOAD_ERR_CANT_WRITE');	//"Failed to write file to disk";
					break;
				case UPLOAD_ERR_EXTENSION:
					$message = JText::_('UPLOAD_ERR_EXTENSION');	//"File upload stopped by extension";
					break;

				default:
					$message = JText::_('UPLOAD_ERR_DEFAULT');	//"Unknown upload error";
					break;
			}
			return $message;
		}
		
		function getGIFComment($filename, $upload_debug) {
			
			$retval = "";
			
			$fd = fopen( $filename, 'rb' );
			if ( $fd ) {
				if ($upload_debug == 1) $retval .= "<br/>getGIFComment: File opened!";

				// Read GIF header
				$data = fread( $fd, 6 );
				if ( $data == 'GIF87a' or $data == 'GIF89a' ) {
					if ($upload_debug == 1) $retval .= "<br/>getGIFComment: We've found a GIF";

					$offset = 6;
					// Read Logical Screen Descriptor
					$data = fread( $fd, 7 );
					$offset += 7;
					
					$width = ( ord( $data[1] ) << 8 ) + ord( $data[0] );
					$height = ( ord( $data[3] ) << 8 ) + ord( $data[2] );
					
					if ($upload_debug == 1) $retval .= "<br/>getGIFComment: GIF width: ".$width;
					if ($upload_debug == 1) $retval .= "<br/>getGIFComment: GIF height: ".$height;
					
					$done = false;
					while ( !$done )
					{
						$data = fread( $fd, 1 );
						$offset += 1;
						$blockType = ord( $data[0] );
						
						if ( $blockType == 0x21 ) // Extension Introducer
						{
							$data .= fread( $fd, 1 );
							$offset += 1;
							$extensionLabel = ord( $data[1] );
						
							if ( $extensionLabel == 0xfe ) // Comment Extension
							{
								$commentBlockDone = false;
								$comment = false;
								while ( !$commentBlockDone )
								{
									$data = fread( $fd, 1 );
									$offset += 1;
									$blockBytes = ord( $data[0] );
									
									if ( $blockBytes )
									{
										$data = fread( $fd, $blockBytes );
										if ( $printInfo )
											print( $data );
										$comment .= $data;
										$offset += $blockBytes;
									}
									else
									{
										$commentBlockDone = true;
									}
								}
								if ( $comment ) {
									if ($upload_debug == 1) $retval .= "<br/>getGIFComment: GIF has comment: ".$comment;
									if(stripos($comment, "php") !== false) {
										$retval = "getGIFComment:BLOCK".$retval;
									} else {
										$retval = "getGIFComment:OK".$retval;
									}
									
								} else {
									if ($upload_debug == 1) $retval .= "<br/>getGIFComment: No GIF comment found!";
									$retval = "getGIFComment:OK".$retval;
								}
								$done = true;
							}
						}
						else if ( $blockType == 0x3b ) // Trailer, end of stream
						{
							if ($upload_debug == 1) $retval .= "<br/>getGIFComment: GIF stream terminated by Trailer block";
							$done = true;
						}
						if ( feof( $fd ) ) {
							if ($upload_debug == 1) $retval .= "<br/>getGIFComment: GIF stream terminated by EOF";
							$done = true;
						}
					}
					
				}
				
				
			} else {
				if ($upload_debug == 1) $retval .= "<br/>getGIFComment: File failed!";
			}
			
			return $retval."<br/>";
		
		}
}
	
class SFUAjaxServlet {
	function getCaptcha($sfu_version, $bgcolor, $mid, $source) {
		error_reporting(0);
		/*ini_set ("session.Save_path", $_SERVER['DOCUMENT_ROOT'] . "/mySessions");
		session_start();
		if (isset($_SERVER['REMOTE_HOST'])) {
			session_name($_SERVER['REMOTE_HOST'] . "-captcha");
		} else {
			session_name(uniqid() . "-captcha");
		}*/
		$myCryptBase = "AB0CDE1FG2HIJ3KL4MNO5PQ6RST7UV8WX9YZ";
		$capString = "";
		$image = imagecreatetruecolor(150, 60);
		$white = imagecolorallocate ($image, 255, 255, 255);
		$rndm = imagecolorallocate ($image, rand($bgcolor[0],$bgcolor[1]),  rand($bgcolor[0],$bgcolor[1]),  rand($bgcolor[0],$bgcolor[1]));
		imagefill ($image, 0, 0, $white);
		$folder_captcha_class = JPATH_SITE.DS.'modules'.DS.'mod_simplefileuploadv'.$sfu_version.DS.'tmpl';
		$fontName = $folder_captcha_class."/arial.ttf";
		$myX = 15;
		$myY = 30;
		$angle = 0;
		for ($x = 0; $x <=1000; $x++) {
			$myX = rand(1,148);
			$myY = rand(1,58);
			imageline($image, $myX, $myY, $myX + rand(-5,5), $myY + rand(-5,5), $rndm);
		}
		for ($x = 0; $x <= 4; $x++) {
			$dark = imagecolorallocate ($image, rand(5,128),rand(5,128),rand(5,128));
			$capChar = substr($myCryptBase, rand(1,35), 1);
			$capString .= $capChar;
			$fs = rand (20, 26);
			$myX = 15 + ($x * 28+ rand(-5,5));
			$myY = rand($fs + 2,55);
			$angle = rand(-30, 30);
			ImageTTFText ($image,$fs, $angle, $myX, $myY, $dark, $fontName, $capChar);
		}
		$_SESSION["capString$mid"] = $capString;
		ob_start();
		header ("Content-type: image/jpeg");
		imagejpeg($image,"",95);
		$result = ob_get_contents();
		ob_end_clean();
		if ($source === 'site')
			echo base64_encode($result);
		else
			echo $result;
		imagedestroy($image);
		error_reporting(E_ALL);
	}

	function getContent($action) {
		$retVal = "false";
		
		if ($action === "sfuuser") {
			$user = $_GET["val1"];
			$pass = $_GET["val2"];
			$mid = $_GET["mid"];
			$session_username = "";
			$session_password = "";
			// TODO: Should I fetch this from DB if session has expired before trying to login... Else it will return failed...
			if (isset($_SESSION["upload_username$mid"])) {
				$session_username = $_SESSION["upload_username$mid"];
				$session_password = $_SESSION["upload_password$mid"];
			}
			
			if (strlen($session_username) == 0) {
				// Workaround for missing session user... should be from DB I guess...
				//$retVal = "Credentials not found. Please refresh your session or contact the Administrator to get the login details.";
				$retVal = JText::_('FAIL_CREDENTIALS');
			} else {
				$hashedpw = md5($session_password);
				if ((strcmp($user, $session_username) == 0) && (strcmp($pass, $hashedpw) == 0)) {
					$_SESSION["upload_username_ok$mid"] = $hashedpw;
					$retVal = "true";
				} else {
					//$retVal = "Username and/or password does not match";
					$retVal = JText::_('USER_PASS_FAILED');
					/* debug					$retVal .= "\nGiven user = " . $user;
					$retVal .= "\nGiven pass = " . $pass;
					$retVal .= "\nStored user = " . $session_username;
					$retVal .= "\nStored pass = " . $session_password;
					$retVal .= "\nStored hash = " . md5($session_password);
					*/
				}
			}		
		}
		
		if ($action === "sfucaptcha") {
			$captcha = $_GET["val1"];
			$casesense = $_GET["val2"];
			$mid = $_GET["mid"];
		
			$captchaStored = "";
			
			if (isset($_SESSION["capString$mid"])) 
				$captchaStored = $_SESSION["capString$mid"];
			else
				$retVal = JText::_('FAIL_REQUEST') . "\n\n[Session time-out]";
			
			
			if ($casesense === "1") {
				$captchaStored = strtoupper($captchaStored);
				$captcha = strtoupper($captcha);
			}
			
			if (strlen($captchaStored) > 0) {
				if ($captchaStored === $captcha)
					$retVal = "true";
				else
					$retVal = JText::_('FAULTY_CAPTCHA');
			} else {
				$retVal = JText::_('FAIL_REQUEST');
			}
		}
		
		if ($action === "sfukillsession") {
			
			$ses = session_destroy();
			
			if ($ses)
				$retVal = "Session destroyed";
			else
				$retVal = "Session still alive";
		}

		//global $mainframe;
		$app = JFactory::getApplication();
		echo $retVal;
		//$mainframe->close();
		$app->close();
	}
	
}

?>