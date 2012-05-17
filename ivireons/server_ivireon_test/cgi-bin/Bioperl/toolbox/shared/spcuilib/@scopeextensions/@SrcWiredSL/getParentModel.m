function hRoot = getParentModel(this)
%GETPARENTMODEL Gets the root model which contains the block. This is the
%main model.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/18 02:14:09 $

if ishandle(this.BlockHandle)
    par = this.BlockHandle.Parent;
    indx = strfind(par,'/');
    if ~isempty(indx)
        par = par(1:indx-1);
    end
    hRoot = get_param(par,'Object');
else
    hRoot = '';
end

% [EOF]
