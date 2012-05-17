function this = nlhwdata(model,name,isActive)
%nlhwdata object constructor

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:49 $

this = plotpack.nlhwdata;

this.Model = model;
this.ModelName = name;

if nargin>2
    this.isActive = isActive;
end
