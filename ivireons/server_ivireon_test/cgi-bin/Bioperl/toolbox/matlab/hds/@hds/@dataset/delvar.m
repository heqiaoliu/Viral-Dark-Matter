function delvar(h,varid)

% Copyright 2005 The MathWorks, Inc.

%% Get the variable and check that it exists and it not a grid variable
v = h.findvar(varid);
if isempty(v)
      return
end
if ~isempty(h.locateGridVar(v))
    error('Cannot remove a grid variable')
end

%% Update the variable cache
ind = (h.Cache_.Variables==v);
h.Cache_.Variables(ind) = [];

%%  Remove the data storage
c = h.getContainer(varid);
h.Data_(h.Data_==c) = [];
delete(c);
delete(h.findprop(varid));


