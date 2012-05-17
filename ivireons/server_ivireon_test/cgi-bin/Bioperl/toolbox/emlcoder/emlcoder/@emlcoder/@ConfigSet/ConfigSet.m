function this = ConfigSet(varargin)
%CONFIGSET   Constructor for ConfigSet object.
%   C = ConfigSet creates a configuration set with all default values.
%
%   Example:
%     c = emlcoder.ConfigSet
%
%   See also emlcoder.EntryPoint, emlcoder.HardwareImplementation, 
%     emlcoder.Project, emlcoder.RTWConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.ConfigSet(varargin{:});
