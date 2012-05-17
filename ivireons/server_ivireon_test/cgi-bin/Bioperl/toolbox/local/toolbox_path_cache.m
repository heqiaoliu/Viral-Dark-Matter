%TOOLBOX_PATH_CACHE   MATLAB Toolbox Path Cache
%
%   In order to reduce startup time, MATLAB caches toolbox directory
%   information across sessions. This technique can result in
%   substantially quicker startup, particularly when launching MATLAB
%   from a network server.
%
%   To enable this feature,
%   
%           * Start MATLAB
%           * Open the Preferences Dialog under the File menu
%           * Click on the word "General"
%           * Check the "Enable toolbox cache" item
%   
%   The next time you start MATLAB, you should see a reduction in startup 
%   time.
%   
%   As with any caching technique, there are a few caveats to be aware of
%   when using this feature.  If you install a new toolbox or update from
%   The MathWorks, MATLAB will detect that the cache is stale and issue a
%   warning at startup of the form:
%   
%        MATLAB Toolbox Path Cache is out of date and is not being used.
%
%   You should only see this message once per update, as the first time
%   you run MATLAB afterward, a new cache file will automatically be
%   generated.
%
%   If you add or remove files from toolbox directories, you will need
%   to force MATLAB to update the cache file.  This can be done using the
%   "Update toolbox cache" option in the Preferences/General dialog or
%   by issuing the command "rehash toolboxcache" at the MATLAB prompt.
%   
%   You can disable usage of this feature by going to the preferences dialog
%   and un-checking the "Enable toolbox cache" item.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2005/12/22 18:12:57 $
