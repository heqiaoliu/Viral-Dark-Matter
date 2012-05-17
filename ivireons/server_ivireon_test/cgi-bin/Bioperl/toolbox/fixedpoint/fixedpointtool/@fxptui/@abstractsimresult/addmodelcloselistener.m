function addmodelcloselistener(h, ds)
%ADDMODELCLOSELISTENER add the modelcloselistener.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:44 $

h.listeners(end+1) = handle.listener(h.daobject, 'ModelCloseEvent', @(s,e)savedata(h,ds));

%--------------------------------------------------------------------------
function savedata(h, ds)
if(isempty(h.Signal)); return; end
s.Run = fxptui.str2run(h.Run);
s.Path = h.Path;
s.PathItem = h.PathItem;
s.isMdlRef = 0;
s.ModelReference = '';
s.Signal = h.Signal;
if(numel(ds.data2save) == 0)
  ds.data2save = s;
else
  ds.data2save(end+1) = s;
end

% [EOF]
