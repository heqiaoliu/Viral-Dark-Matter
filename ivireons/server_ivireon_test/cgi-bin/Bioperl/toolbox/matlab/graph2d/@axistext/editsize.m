function aObj = editsize(aObj, varargin)
%AXISTEXT/EDITSIZE Edit font size for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 1.10.4.3 $  $Date: 2007/08/27 17:07:00 $

t = aObj;
try
   size = str2double(varargin{1});
   aObj = set(aObj,'FontSize',size);
catch
   error('MATLAB:editsize:InvalidAction', 'Unable to set font size');
end

