function this = HardwareImplementation(varargin)
%HARDWAREIMPLEMENTATION   Constructor for HardwareImplementation object.
%   Syntax:
%     H = HardwareImplementation
%
%   Description:
%     H = HardwareImplementation creates hardware implementation options 
%     with all default values.
%
%   Example:
%     h = emlcoder.HardwareImplementation
%     open h  % Shows configuration dialog.
%
%   See also emlc, emlmex, emlcoder.MEXConfig, emlcoder.RTWConfig.

%   Copyright 2005-2009 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.HardwareImplementation(varargin{:});
