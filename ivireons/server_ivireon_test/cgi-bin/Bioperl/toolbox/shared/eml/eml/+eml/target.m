function y = target(varargin)
%EML.TARGET Determine the Embedded MATLAB code-generation target.
%   This function return a string representing the current coding target
%   for Embedded MATLAB. When the function is executed in MATLAB, it
%   returns the empty string.
%
%   Example:
%       if isempty(eml.target)
%           % running in MATLAB
%       else
%           % running in Embedded MATLAB
%       end
%
%   See also eml/ceval.

%   Copyright 2006-2010 The MathWorks, Inc.

y = '';
