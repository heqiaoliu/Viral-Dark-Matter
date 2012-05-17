function this = nlarxdata(model,name,isActive)
%nlarxdata constructor

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:47 $

this = plotpack.nlarxdata;

this.Model = model;
this.ModelName = name;
if nargin>2
    this.isActive = isActive;
end

%Note: colors are assigned by idnlarxplot object
