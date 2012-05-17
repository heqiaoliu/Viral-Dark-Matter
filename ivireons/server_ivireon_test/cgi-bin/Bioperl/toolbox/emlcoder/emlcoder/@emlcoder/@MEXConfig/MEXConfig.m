function this = MEXConfig(varargin)
%MEXConfig   Constructor for MEXConfig object.
%   Syntax:
%     M = MEXConfig
%
%   Description:
%     M = MEXConfig creates MEX configurations options with all default
%     values.
%
%   Example:
%     m = emlcoder.MEXConfig
%     open m  % Shows configuration dialog.
%     emlmex -s m foo % Uses options to compile foo.m
%
%   See also emlc, emlcoder.HardwareImplementation, emlcoder.RTWConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.MEXConfig(varargin{:});
