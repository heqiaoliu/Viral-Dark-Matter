function this = RTWConfig(varargin)
%RTWCONFIG   Constructor for RTWConfig object.
%   Syntax:
%     R = RTWConfig
%     R = RTWConfig('grt')
%     R = RTWConfig('ert')
%
%   Description:
%     R = RTWConfig creates an RTW configuration object with all default
%     values.
%
%     R = RTWConfig('grt') creates an RTW configuration object with all 
%     default values. This is equivalent to R = RTWConfig.
%
%     R = RTWConfig('ert') creates an RTW configuration object with all 
%     default values for use when a Real-Time Workshop Embedded Coder
%     license is available. Use of this object enables additional
%     features when compiling M-code.
%
%   Examples:
%     r = emlcoder.RTWConfig('ert')
%     open r                % Shows configuration dialog.
%     emlc -T RTW -s r foo  % Uses options to compile foo.m
%
%   See also emlc, emlcoder.HardwareImplementation, emlcoder.MEXConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.RTWConfig(varargin{:});
