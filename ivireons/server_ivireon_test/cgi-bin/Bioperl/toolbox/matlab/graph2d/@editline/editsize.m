function aObj = editsize(aObj, varargin)
%EDITLINE/EDITSIZE Edit editline linewidth
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 1.10.4.3 $  $Date: 2007/08/27 17:07:03 $


t = aObj;
try
   size = str2double(varargin{1});
   aObj = set(aObj,'LineWidth',size);
catch
    error('MATLAB:editsize:InvalidAction', 'Unable to set line size');
end
