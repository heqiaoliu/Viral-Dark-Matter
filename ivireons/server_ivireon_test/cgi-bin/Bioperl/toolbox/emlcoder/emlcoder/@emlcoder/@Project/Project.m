function this = Project(varargin)
%PROJECT   Constructor for PROJECT object.
%   P = PROJECT creates a project with all default values.
%
%   Example:
%     p = emlcoder.Project('myproj')
%
%   See also emlcoder.ConfigSet, emlcoder.EntryPoint, 
%   emlcoder.HardwareImplementation, emlcoder.RTWConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.Project(varargin{:});
