function this = CompilerOptions(varargin)
%COMPILEROPTIONS   Constructor for CompilerOptions object.
%   Syntax:
%     O = CompilerOptions
%
%   Description:
%     O = CompilerOptions creates compiler options with all default values.
%
%   Example:
%     o = emlcoder.CompilerOptions
%     open o         % Shows configuration dialog.
%     emlc -s o foo  % Uses options to compile foo.m
%
%   See also emlc, emlmex, emlcoder.HardwareImplementation,   
%   emlcoder.MEXConfig, emlcoder.RTWConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.CompilerOptions(varargin{:});
