function deletefigures(h)
%DELETEFIGURES   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:27 $

if(isempty(h.figures)); return; end
keys = h.figures.keySet;
if(isempty(keys)); return; end
keysarray = keys.toArray;
for i = 1:numel(keysarray)
  callback = keysarray(i);
  hfig = h.figures.remove(callback);
  if(ishandle(hfig) && hfig ~= 0)
    delete(hfig);
  end
end

% [EOF]
