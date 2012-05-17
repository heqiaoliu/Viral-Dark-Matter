function [fullname, path, pathitem] = getfxptfullname(data)
%GETFXPTFULLNAME   Get the fxptfullname (path : pathitem).

%
%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:33:23 $

%throw an error if the data isn't valid
if(~isfield(data, 'Path'))
  DAStudio.error('FixedPoint:fixedPointTool:errorArgHasNoPath');
end
%straighten out the path if it is mangled
path = fxptds.getpath(data.Path);
%append the Stateflow dataName if it exists
if(isfield(data, 'dataName') && ~isempty(data.dataName))
  path = [path '/' data.dataName];
end
%get the pathitem from data if it is specified
pathitem = fxptds.getpathitem(data);
fullname = [path ' : ' pathitem];

% [EOF]
