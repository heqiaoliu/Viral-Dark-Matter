function pathitem = getpathitem(d)
%GETPATHITEM   Get the pathitem from an element of FixPtSimRanges or 
%							 from a dataset record.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:56:51 $

pathitem = '';
if(isempty(d)); return ; end

% SignalName exists for any blocks that have multiple qreport quantities
if(isfield(d, 'SignalName') && ~isfield(d, 'isStateflow'))
	pathitem = d.SignalName;
end

% if we're handed a record from the dataset return the PathItem
if(isfield(d, 'PathItem') && ~isempty(d.PathItem))
	pathitem = d.PathItem;
end

if(isnumeric(pathitem))
	pathitem = num2str(pathitem);
end
%create a display name
if(isempty(pathitem))
  pathitem = '1';
end
pathitem = fxptds.getpath(pathitem);

% [EOF]
