function [success, errorMessage] = sf_mk_dir(parentDirName,childDirName)
% Copyright 2003-2005 The MathWorks, Inc.

% Just a wrapper around mkdir in case we need to do something in future
[success, errorMessage] = mkdir(parentDirName,childDirName);
