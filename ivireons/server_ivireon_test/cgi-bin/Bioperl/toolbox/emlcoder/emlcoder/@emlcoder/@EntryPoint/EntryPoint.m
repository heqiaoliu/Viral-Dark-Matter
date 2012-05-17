function this = EntryPoint(varargin)
%ENTRYPOINT   Constructor for EntryPoint object.
%   E = EntryPoint creates an entry-point with all default values.
%
%   Example:
%     e = emlcoder.EntryPoint('myfcn')
%
%   See also emlcoder.ConfigSet, emlcoder.HardwareImplementation, 
%   emlcoder.Project, emlcoder.RTWConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.EntryPoint(varargin{:});
