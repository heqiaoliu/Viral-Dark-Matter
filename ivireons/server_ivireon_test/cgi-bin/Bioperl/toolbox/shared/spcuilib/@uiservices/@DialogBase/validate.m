function [stat, exception] = validate(~)
%VALIDATE Validate settings of DialogParameters object
%  Base clase implementation
%
% stat: boolean status, false=fail, true=accept
% err: error message string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/07/23 18:44:29 $

exception = MException.empty;
stat = true;

% [EOF]
