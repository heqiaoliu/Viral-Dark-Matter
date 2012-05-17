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

/**
 * Optimizing css/js class for rendering T3 template
 *
 * @package JAT3.Core
 */
class T3Head extends JObject
{
    /**
     * Array folder & file js ignore when minify
     *
     * @var array
     */
    private static $js_ignore_list = array(
        'media/system/js/',
        'media/media/js/',
        '/jquery.min.js'
    );

    /**
     * Execute css/js optimizing base on joomla document object
     *
     * @return void
     */
    public function proccess()
    {
        $document =& JFactory::getDocument();
        //proccess stylesheets
        $themes = T3Common::get_active_themes();
        //$themes[] = array('core', 'default'); //default now move to template root folder
        //$themes[] = array('engine', 'default');
        $themes = array_reverse($themes);

        $scripts = array();
        $css_urls = array();
        $css_urls['site'] = array();
        foreach ($themes as $theme) {
            $css_urls[$theme[0].'.'.$theme[1]] = array();
        }
        foreach ($themes as $theme) {
            $css_urls[$theme[0].'.'.$theme[1].'-browser'] = array();
        }

        if (T3Common::isRTL()) {
            foreach ($themes as $theme) {
                $css_urls[$theme[0].'.'.$theme[1].'-rtl'] = array();
            }
        }

        $bname = T3Common::getBrowserSortName();
        $bver = T3Common::getBrowserMajorVersion();
        $optimize_css = T3Parameter::get('optimize_css', 2);
        $optimize_js = T3Parameter::get('optimize_js', 2);
        foreach ($document->_styleSheets as $strSrc => $strAttr) {
            $path = T3Head::cleanUrl($strSrc);
            if (!$path || !preg_match('#\.css$#', $path)) {
                //External url
                $css_urls['site'][] = array ('', $strSrc);
                continue;
            }

            $intemplate = false;
            if (preg_match('/^templates\/' . T3_ACTIVE_TEMPLATE . '\//', $path)) {
                $path = preg_replace('/^templates\/' . T3_ACTIVE_TEMPLATE . '\//', '', $path);
                $intemplate = true;
            }
            /*
            if (!$intemplate && $optimize_css < 2) // don't read file content => keep original link
            {
                $css_urls['site'][] = array ('', $strSrc);
                continue;
            }
            */
            $paths = array();
            //$paths[] = array ('', $path, $strSrc); //The third element is the original url
            $paths[] = array('', $path); // Fix when source code in subfolder
            //if ($intemplate) {
                //only load other css files if in T3v2 template
            $ext = '';
            if (preg_match('#\.[^.]+$#', $path, $matches)) {
                $ext = $matches[0];
            }
                //$file_info = pathinfo($path);
                //$ext = $file_info['extension'];
            if ($ext) {
                $paths[] = array('-browser', str_replace($ext, "-$bname$ext", $path));
                $paths[] = array('-browser', str_replace($ext, "-$bname$bver$ext", $path));
                if (T3Common::isRTL()) {
                    $paths[] = array('-rtl', str_replace($ext, "-rtl$ext", $path));
                    $paths[] = array('-rtl', str_replace($ext, "-$bname-rtl$ext", $path));
                    $paths[] = array('-rtl', str_replace($ext, "-$bname$bver-rtl$ext", $path));
                }
            }
            //}

            foreach ($paths as $path) {
                //
                if ($intemplate) {
                    $urls = T3Path::get($path[1], true);
                    if ($urls) {
                        foreach ($urls as $theme=>$url) {
                            $url[] = $strAttr;
                            $css_urls [$theme.$path[0]][$url[0]] = $url;
                        }
                    }
                } else {
                    if (is_file(T3Path::path($path[1]))) {
                        $css_urls['site'][T3Path::path($path[1])] = array (
                            T3Path::path($path[1]),
                            count($path) > 2 ? $path[2] : T3Path::url($path[1]),
                            $strAttr
                        ); //use original url ($path[2]) if exists
                    }
                }
            }
        }
        // Remove current stylesheets
        $document->_styleSheets = array();
        foreach ($document->_scripts as $strSrc => $strType) {
            $srcurl = T3Head::cleanUrl($strSrc);
            if (!$srcurl || !preg_match('#\.js$#', $srcurl)) {
                $scrips[] = array ('', $strSrc);
                continue;
            }

            if (preg_match('/^templates\/'.T3_ACTIVE_TEMPLATE.'\//', $srcurl)) {
                //in template
                $srcurl = preg_replace('/^templates\/'.T3_ACTIVE_TEMPLATE.'\//', '', $srcurl);
                $path   = str_replace('/', DS, $srcurl);
                $url = T3Path::get($path);
                if ($url) {
                    $scrips[] = $url;
                }
            } else {
                // Don't read file content => keep original link
                if ($optimize_js < 1) {
                    $scrips[] = array ('', $strSrc);
                    continue;
                }
                $path = str_replace('/', DS, $srcurl);
                $scrips[] = array (JPATH_SITE.DS.$path, JURI::base(true).'/'.$srcurl);
            }
        }
        //remove current scripts
        $document->_scripts = array();

        $tmp_css_urls = false;

        do {
            $tmp_css_urls = T3Head::optimizecss($css_urls);
        } while ($tmp_css_urls === false);

        $css_urls = $tmp_css_urls;
        //if ($url) $css_urls = array(array(array('', $url)));

        //re-add stylesheet to head
        foreach ($css_urls as $urls) {
            foreach ($urls as $url) {
                if (count($url) > 2) {
                    $attrs = $url[2];
                    $document->addStylesheet($url[1], $attrs['mime'], $attrs['media'], $attrs['attribs']);
                } else {
                    $document->addStylesheet($url[1]);
                }
            }
        }

        $tmp_scrips = false;
        do {
            $tmp_scrips = T3Head::optimizejs($scrips);
        } while ($tmp_scrips === false);

        $scrips = $tmp_scrips;
        //re-add stylesheet to head
        foreach ($scrips as $url) {
            $document->addScript($url[1]);
        }
    }

    /**
     * Check and make URL more clean
     *
     * @param string $strSrc  URL
     *
     * @return string clean URL
     */
    function cleanUrl($strSrc)
    {
        $strSrc = preg_replace('#[?\#]+.*$#', '', $strSrc);
        //if (!preg_match ('#\.(css|js)$#', $strSrc)) return false; //not static file
        if (preg_match('/^https?\:/', $strSrc)) {
            if (! preg_match('#^' . preg_quote(JURI::base()) . '#', $strSrc)) {
                // External css
                return false;
            }
            $strSrc = str_replace(JURI::base(), '', $strSrc);
        } elseif (preg_match('/^\//', $strSrc) && JURI::base(true)) {
            if (!preg_match('#^' . preg_quote(JURI::base(true)) . '#', $strSrc)) {
                // Same server, but outsite website
                return false;
            }
            $strSrc = preg_replace('#^' . preg_quote(JURI::base(true)) . '#', '', $strSrc);
        }
        $strSrc = str_replace('//', '/', $strSrc); //replace double slash by one
        $strSrc = preg_replace('/^\//', '', $strSrc); //remove first slash
        return $strSrc;
    }

    /**
     * Check if someone is optimizing css or js
     * loop in 1/100 second
     * if waiting more 5 seconds, we will hot release lock
     *
     * @param string $cache_path  Cache path
     * @param string $lock_file   Lock file name
     *
     * @return bool  TRUE if still lock, otherwise FALSE
     */
    function optimizeCheckLock($cache_path, $lock_file)
    {
        $waiting = false;
        $counter = 0;
        while (file_exists($cache_path . DS . $lock_file)) {
            usleep(10000);
            $waiting = true;
            $counter++;
            if ($counter > 500) {
                T3Head::optimizeReleaseLock($cache_path, $lock_file);
                break;
            }
        }
        return $waiting;
    }

    /**
     * Create lock before optimizing js or cs
     * This process is only finish if and only if can write something to this file
     *
     * @param string $cache_path  Cache path
     * @param string $lock_file   Lock file name
     *
     * @return bool TRUE if create success, otherwise FALSE
     */
    function optimizeCreateLock($cache_path, $lock_file)
    {
        if (!is_dir($cache_path)) {
            // Cannot create cache folder for js/css optimize
            if (!@JFolder::create($cache_path)) {
                return false;
            }
        }
        /*
        $file = @fopen($cache_path .  DS . $lock_file, "x");
        if($file)
        {
            fclose($file);
            return true;
        }
        return false;
        */
        // # Fix when ftp & web server use 2 diferent accounts.
        $data = 'lock';
        return JFile::write($cache_path .  DS . $lock_file, $data);
    }

    /**
     * Release lock file
     *
     * @param string $cache_path  Cache path
     * @param string $lock_file   Lock file name
     *
     * @return bool  TRUE if success, otherwise FALSE
     */
    function optimizeReleaseLock($cache_path, $lock_file)
    {
        if (file_exists($cache_path . DS . $lock_file)) {
            try {
                //unlink($cache_path . DS . $lock_file);
                //return true;

                // # Fix when ftp & web server use 2 diferent accounts.
                return @JFile::delete($cache_path . DS . $lock_file);
            } catch (Exception $e) {
            }
        }
        return false;
    }

    /**
     * Optimize js base on list js
     *
     * @param array $js_urls  List of js file
     *
     * @return array  List of optimized js file
     */
    function optimizejs($js_urls)
    {
        $content = '';
        $optimize_js = T3Parameter::get('optimize_js', 1);
        if (!$optimize_js) {
            return $js_urls;
        }

        //# Fix when optimized_folder is un-writeable
        $cachepath = T3Path::path(T3Parameter::get('optimize_folder', 't3-assets'));
        $cachepath .= DS . 'js';
        if (!T3Common::checkWriteable($cachepath)) {
            return $js_urls;
        }

        $output = array();
        $optimize_exclude = trim(T3Parameter::get('optimize_exclude', ''));
        $optimize_exclude_regex = null;
        if ($optimize_exclude) {
            $optimize_exclude_regex = '#' . preg_replace('#[\r\n]+#', '|', preg_quote($optimize_exclude)) . '#';
        }

        $files = array();

        //# Check lock file before start checking update
        $lock_file = "optimize.js.lock";
        $waiting = T3Head::optimizeCheckLock($cachepath, $lock_file);

        $lock_file_file = null;

        $needupdate = false;
        $need_optimize = false;
        $required_optimize_list = array();
        $files_array = array();

        jimport('joomla.filesystem.file');
        foreach ($js_urls as $url) {
            if (!$url[0] || !preg_match('#\.js$#', $url[0])
                || ($optimize_exclude_regex && preg_match($optimize_exclude_regex, $url[1]))
            ) {
                //ignore if not a local file or not a static js file
                //output to file
                if (count($files)) {
                    $files_array[] = array('files' => $files, 'needupdate' => $needupdate);
                }
                //put this ignore file into ouput
                //$output[] = $url;
                // Ignore file however must follow by order
                $files_array[] = array('files' => $url, 'ignore' => true);

                //reset the flag for file update
                $needupdate = false;
                $files = array();
            } else {
                //for static local file
                if ($optimize_js > 1) {
                    // Check js file was minified
                    $ignore_compress = false;
                    foreach (self::$js_ignore_list as $js_ignore) {
                        if (strpos($url[1], $js_ignore)) {
                            $ignore_compress = true;
                            break;
                        }
                    }

                    if ($ignore_compress) {
                        $files[] = array($url[0], '');
                    } else {
                        // Need optimized
                        // Check if this file is changed from the last optimized
                        // This file is changed/modified after cached
                        $cfile = $cachepath . DS . 'js_' . md5($url[0]) . '.' . basename($url[0]);
                        if (!file_exists($cfile) || @filemtime($url[0]) > @filemtime($cfile)) {
                            $required_optimize_list[] = array('cfile' => $cfile, 'url0' => $url[0], 'url1' => $url[1]);
                            $needupdate = true;
                            $need_optimize = true;
                        }
                        $files[] = array($cfile, '');
                    }
                } else {
                    //just keep original
                    $files[] = $url;
                }
            }
        }

        if ($need_optimize) {
            //# Only create lock if and only if require optimize
            if (!T3Head::optimizeCreateLock($cachepath, $lock_file)) {
                return false;
            }

            foreach ($required_optimize_list as $required_optimize) {
                $data = T3Head::compressjs(@JFile::read($required_optimize['url0']), $required_optimize['url1']);
                @JFile::write($required_optimize['cfile'], $data);
            }
        }

        if (!file_exists($cachepath)) {
            @JFolder::create($cachepath);
        }

        //$file = fopen($cachepath . DS . session_id() . "txt", "a");
        if (count($files)) {
            $files_array[] = array('files' => $files, 'needupdate' => $needupdate);
        }

        foreach ($files_array as $group_files) {
            // Check ignore file
            if (!isset($group_files['ignore'])) {
                $ourl = T3Head::store_file2($group_files['files'], 'js', $group_files['needupdate']);
                // Check result
                if (!$ourl) {
                    return $js_urls;
                }
                // Put result into output
                $output[] = array('', $ourl);
            } else {
                //$ourl = $group_files['files'];
                $output[] = $group_files['files'];
            }
        }
        //# Release lock
        T3Head::optimizeReleaseLock($cachepath, $lock_file);
        return $output;
    }

    /**
     * Optimize css base on list css
     *
     * @param array $css_urls  List of css file
     *
     * @return array  List of optimized css file
     */
    function optimizecss($css_urls)
    {
        $content = '';
        $optimize_css = T3Parameter::get('optimize_css', 2);
        if (!$optimize_css) {
            return $css_urls; //no optimize css
        }

        // # Fix when optimized_folder is un-writeable
        $cachepath = T3Path::path(T3Parameter::get('optimize_folder', 't3-assets'));
        $cachepath .= DS . 'css';
        //$parentpath = dirname($cachepath);
        if (!T3Common::checkWriteable($cachepath)) {
            return $css_urls;
        }

        $output = array();
        $optimize_exclude = trim(T3Parameter::get('optimize_exclude', ''));
        $optimize_exclude_regex = null;
        if ($optimize_exclude) {
            $optimize_exclude_regex = '#' . preg_replace('#[\r\n]+#', '|', preg_quote($optimize_exclude)) . '#';
        }

        $files = array();

        // # Check lock file before start checking update
        $lock_file = "optimize.js.lock";
        $waiting = T3Head::optimizeCheckLock($cachepath, $lock_file);

        $lock_file_file = null;
        $needupdate = false;
        $need_optimize = false;
        $required_optimize_list = array();
        $files_array = array();

        // Limit files import into a css file (in IE7, only first 30 css files are loaded). other case, load unlimited
        $filelimit = ($optimize_css == 1)?20:999;
        $filecount = 0;

        jimport('joomla.filesystem.file');
        foreach ($css_urls as $theme=>$urls) {
            foreach ($urls as $url) {
                $ignore = false;
                $import = false;
                $importupdate = false;
                // check ignore to optimize
                // - not a local file
                // - not a css file
                // - in ignore list
                if (!$url[0]) {
                    $ignore = true;
                } elseif (!preg_match('#\.css$#', $url[0])) {
                    $ignore = true; //ignore dynamic css file
                } elseif (($optimize_exclude_regex && preg_match($optimize_exclude_regex, $url[1]))) {
                    $ignore = true;
                }

                if (!$ignore && $optimize_css > 1) {
                    //check if need update. for css, the cache should be [filename] or [filename]-import
                    //[filename]-import - for the case there's @import inside
                    //in the ignore of @import, file still optimize but will be put into a sigle file
                    $cfile = $cachepath . DS . 'css_' . md5($url[0]).'.'.basename($url[0]);
                    if (!(file_exists($cfile) && @filemtime($url[0]) < @filemtime($cfile))
                        && !(file_exists($cfile.'-import') && @filemtime($url[0]) < @filemtime($cfile.'-import'))
                    ) {
                        $required_optimize_list[] = array('cfile' => $cfile, 'url0' => $url[0], 'url1' => $url[1]);
                        //Need update
                        $data = @JFile::read($url[0]);
                        if (preg_match('#@import\s+.+#', $data)) {
                            $import = true;
                            $importupdate = true;
                            $cfile = $cfile.'-import';
                        }
                        $needupdate = true;
                        $need_optimize = true;
                    } elseif (is_file($cfile.'-import')) {
                        $import = true;
                        $importupdate = false;
                        $cfile = $cfile.'-import';
                    }
                }
                //match ignore file, or import file, or reach the limit: flush previous files out
                if ($ignore || $import || count($files)==$filelimit) {
                    if (count($files)) {
                        $files_array[] = array('files' => $files, 'needupdate' => $needupdate);
                    }
                    //reset the flag for file update
                    $needupdate = false;
                    $files = array();
                }
                //write out the @import file
                if ($ignore) {
                    //$output[] = $url;
                    // Ignore file however must follow by order
                    $files_array[] = array('files' => $url, 'ignore' => true);
                } else {
                    if ($optimize_css > 1) {
                        $files[] = array($cfile,'', $url[2]);
                    } else {
                        $files[] = $url;
                    }
                }
            }
        }

        if ($need_optimize) {
            //# Only create lock if and only if require optimize
            if (!T3Head::optimizeCreateLock($cachepath, $lock_file)) {
                return false;
            }

            foreach ($required_optimize_list as $required_optimize) {
                $data = T3Head::compresscss(@JFile::read($required_optimize['url0']), $required_optimize['url1']);
                if (preg_match('#@import\s+.+#', $data)) {
                    $import = true;
                    $importupdate = true;
                    $required_optimize['cfile'] = $required_optimize['cfile'] . '-import';
                }
                @JFile::delete($required_optimize['cfile']);
                @JFile::delete($required_optimize['cfile'] . '-import');
                @JFile::write($required_optimize['cfile'], $data);
                $needupdate = true;
            }
        }

        if (count($files)) {
            $files_array[] = array('files' => $files, 'needupdate' => $needupdate);
        }

        foreach ($files_array as $group_files) {
            // Check ignore file
            if (!isset($group_files['ignore'])) {
                $ourl = T3Head::store_file2($group_files['files'], 'css', $group_files['needupdate']);
                if (!$ourl) {
                    return $css_urls;
                }
                $output[] = array('', $ourl);
            } else {
                $output[] = $group_files['files'];
            }
        }
        // # Release lock
        T3Head::optimizeReleaseLock($cachepath, $lock_file);
        return array($output);
    }

    /**
     * Compress css file
     *
     * @param string $data  CSS data
     * @param string $url   CSS URL
     *
     * @return string  Compressed css data
     */
    function compresscss($data, $url)
    {
        global $current_css_url;
        //if ($url[0] == '/') $url = JURI::root(false, '').substr($url, 1);
        $current_css_url = $url;
        /* remove comments */
        $data = preg_replace('!/\*[^*]*\*+([^/][^*]*\*+)*/!', '', $data);
        /* remove tabs, spaces, new lines, etc. */
        $data = str_replace(array("\r\n", "\r", "\n", "\t", '  ', '    ', '    '), ' ', $data);
        /* remove unnecessary spaces */
        $data = preg_replace('/[ ]+([{};,:])/', '\1', $data);
        $data = preg_replace('/([{};,:])[ ]+/', '\1', $data);
        /* remove empty class */
        $data = preg_replace('/(\}([^\}]*\{\})+)/', '}', $data);
        /* replace url*/
        $data = preg_replace_callback('/url\(([^\)]*)\)/', array('T3Head', 'replaceurl'), $data);
        return $data;
    }

    /**
     * Compress js file
     *
     * @param string $data  JS data
     * @param string $url   JS URL
     *
     * @return string  Compressed js data
     */
    function compressjs($data, $url)
    {
        $optimize_js = T3Parameter::get('optimize_js', 1);
        if ($optimize_js < 2) {
            return $data; //no compress
        }
        //compress using jsmin
        t3import('core.libs.jsmin');

        return JSMin::minify($data);
    }

    /**
     * Replace URL for suitable mode
     *
     * @param array $matches  Matches of URL
     *
     * @return string  Replaced URL
     */
    function replaceurl($matches)
    {
        $url = str_replace(array('"', '\''), '', $matches[1]);
        global $current_css_url;
        $url = T3Head::converturl($url, $current_css_url);
        return "url('$url')";
    }

    /**
     * Convert URL for suitable mode
     *
     * @param string $_url      URL
     * @param string $cssurl    CSS URL
     *
     * @return string  Converted URL
     */
    function converturl($_url, $cssurl)
    {
        $url = $_url;
        $base = dirname($cssurl);
        $base = str_replace(JURI::base(), JURI::base(true) . '/', $base);
        $optimize_css = T3Parameter::get('optimize_css', 2);
        if ($optimize_css < 3) {
            //compress - using absolute path
            //not compress - convert to relative path
            $base = T3Head::cleanUrl($base);
            $cache_path = T3Parameter::get('optimize_folder', 't3-assets');
            while ($cache_path && $cache_path != '.') {
                $cache_path = dirname($cache_path);
                $base = '../' . $base;
            }
        }
        if (preg_match('/^(\/|http)/', $url)) {
            return $url; /*absolute or root*/
        }
        while (preg_match('/^\.\.\//', $url)) {
            $base = dirname($base);
            $url = substr($url, 3);
        }

        //if ($base === '\\' || $base === '/') $base = '';
        $url = $base . '/' . $url;
        if ($url[0] == '\\' || $url[0] == '/') {
            $url = ltrim($url, '\\/');
            $url = '/' . $url;
        }

        return $url;
    }

    //
    /**
     * Use a shorter and readable filename. use version to tell the browser that the file content is change.
     * Read content from array of files $files and write to one cached file if need update $needupdate or cached file not exists
     *
     * @param array  $files       List of file
     * @param string $ext         Extension
     * @param bool   $needupdate  Indicate need to update file or not
     *
     * @return The new file url
     */
    function store_file2($files, $ext, $needupdate)
    {
        $cache_path = T3Parameter::get('optimize_folder', 't3-assets');
        $optimize_level = T3Parameter::get('optimize_' . $ext, 1);
        $path = T3Path::path($cache_path);
        if (!is_dir($path)) {
            if (!@JFolder::create($path)) {
                return false; //cannot create cache folder for js/css optimize
            }
        }
        if (!is_file($path . DS . 'index.html')) {
            $indexcontent = '<html><body></body></html>';
            if (!@JFile::write($path . DS . 'index.html', $indexcontent)) {
                return false; //cannot create blank index.html to prevent list files
            }
        }

        static $filemap = array();
        //data.php contain filename maps
        $datafile = $path.'/data.php';
        if (is_file($datafile)) {
            include_once $datafile;
        }
        //get a salt
        if (!isset($filemap['salt']) || !$filemap['salt']) {
            $filemap['salt'] = rand();
        }
        //build destination file
        $file = md5($filemap['salt'] . serialize($files));
        $filename = $ext . '_' . substr($file, 0, 5) . ".$ext";
        $destfile = $path . DS . $filename;

        //re-populate $needupdate in case $destfile exists & keep original (not minify)
        if ($optimize_level == 1 && is_file($destfile)) {
            foreach ($files as $f) {
                if (@filemtime($f[0]) > @filemtime($destfile)) {
                    $needupdate = true;
                    break;
                }
            }
        }
        //check if need update
        if (!$needupdate && is_file($destfile)) {
            $fileversion = isset($filemap[$ext]) && isset($filemap[$ext][$file]) ? $filemap[$ext][$file] : 1;
            $fileversion = $fileversion == 1 ? "" : "?v=" . $filemap[$ext][$file];
            if ($optimize_level < 3) {
                return T3Path::url($cache_path) . '/' . $filename . $fileversion;
            } else {
                //$url = JRoute::_("index.php?jat3action=gzip&jat3type=$ext&jat3file=".urlencode ($cache_path.'/'.$filename).$fileversion);
                $url = "jat3action=gzip&amp;jat3type=$ext&amp;jat3file=" . urlencode($cache_path . '/' . $filename) . $fileversion;
                // Fix when enable languagefilter plugin
                $url = self::buildURL($url);
                return $url;
            }
        }

        //get files content
        $content = '';
        foreach ($files as $f) {
            $media = count($f) > 2 ? trim($f[2]['media']) : "";
            if ($ext == 'css') {
                if ($optimize_level == 1) {
                    $content .= "@import url(\"{$f[1]}\") {$media};\n";
                } elseif (!empty($media)) {
                    $content .= "/* " . substr(basename($f[0]), 33) . " */\n" . "@media " . $f[2]['media'] . " {\n" . @JFile::read($f[0]) . "\n}\n\n";
                } else {
                    $content .= "/* " . substr(basename($f[0]), 33) . " */\n" . @JFile::read($f[0]) . "\n\n";
                }
            } else {
                $content .= "/* " . substr(basename($f[0]), 33) . " */\n" . @JFile::read($f[0]) . "\n\n";
            }
        }

        if (!isset($filemap[$ext])) {
            $filemap[$ext] = array();
        }
        if (!isset($filemap[$ext][$file])) {
            $filemap[$ext][$file] = 0; //store file version
        }
        //update file version
        $filemap[$ext][$file] = $filemap[$ext][$file] + 1;
        $fileversion = $filemap[$ext][$file]==1?"":"?v=".$filemap[$ext][$file];
        //update datafile
        $filemapdata = '<?php $filemap = ' . var_export($filemap, true) . '; ?>';
        @JFile::write($datafile, $filemapdata);

        //create new file
        if (! @JFile::write($destfile, $content)) {
            return false; // Cannot create file
        }

        //return result
        //check if need compress
        if ($optimize_level == 3) { //compress
            //$url = JRoute::_("index.php?jat3action=gzip&type=$ext&file=".urlencode ($cache_path.'/'.$filename).$fileversion);
            $url = "jat3action=gzip&amp;jat3type=$ext&amp;jat3file=" . urlencode($cache_path . '/' . $filename) . $fileversion;
            // Fix when enable languagefilter plugin
            $url = self::buildURL($url);
            return $url;
        }

        return T3Path::url($cache_path) . '/' . $filename . $fileversion;
    }

    /**
     * Build URL for suitable language filter & sef mode in Joomla 1.7
     *
     * @param string $url  URL
     *
     * @return string  Built URL
     */
    function buildURL($url)
    {
        if (JPluginHelper::isEnabled('system', 'languagefilter')) {
            $lang_codes = JLanguageHelper::getLanguages('lang_code');
            $default_lang = JComponentHelper::getParams('com_languages')->get('site', 'en-GB');
            $default_sef = $lang_codes[$default_lang]->sef;
            $app = JFactory::getApplication();
            $router = $app->getRouter();
            if ($router->getMode() == JROUTER_MODE_SEF) {
                if ($app->getCfg('sef_rewrite')) {
                    $url = JURI::base(true) . "/en/?$url";
                } else {
                    $url = JURI::base(true) . "/index.php/en/?$url";
                }
            } else {
                $url = JURI::base(true) . "/index.php?lang=$default_sef&$url";
            }
        } else {
            $url = JURI::base(true) . "/index.php?$url";
        }
        return $url;
    }
}