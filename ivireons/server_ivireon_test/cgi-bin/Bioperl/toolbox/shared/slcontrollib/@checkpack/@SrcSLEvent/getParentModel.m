function hRoot = getParentModel(this)
%GETPARENTMODEL Gets the root model which contains the block. This is the
%main model.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:01 $

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
end