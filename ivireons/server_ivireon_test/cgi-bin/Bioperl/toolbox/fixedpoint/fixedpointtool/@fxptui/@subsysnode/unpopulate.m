function unpopulate(h)
%UNPOPULATE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:37 $

items = h.hchildren.values.toArray;
for idx = 1:numel(items)
  jfxpblk = items(idx);
  if(isempty(jfxpblk));continue;end
  fxpblk = handle(jfxpblk);
  jfxpblk.releaseReference;
  deletelisteners(fxpblk);
  unpopulate(fxpblk);
  delete(fxpblk);
end
h.hchildren.clear;
h.hchildren = [];
h.PropertyBag.clear;
h.PropertyBag = [];
deletelisteners(h);

%--------------------------------------------------------------------------
function deletelisteners(fxpblk)
for lIdx = 1:numel(fxpblk.listeners)
  delete(fxpblk.listeners(lIdx));
end
fxpblk.listeners = [];

% [EOF]

