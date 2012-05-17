function clearfigureaxes(h)
%CLEARFIGUREAXES

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:24 $


keys = h.figures.keySet;
if(isempty(keys)); return; end
keysarray = keys.toArray;
for i = 1:numel(keysarray)
  callback = keysarray(i);
  hfig = h.figures.get(callback);
  if(isempty(hfig) || ~ishandle(hfig))
    h.figures.remove(callback);
    continue;
  else
    haxes = findall(hfig, 'Type', 'Axes');
    for a = 1:numel(haxes)
      cla(haxes(a));
    end
  end
end

% [EOF]
