function updatefigures(h)
%UPDATEFIGURES

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2010/07/01 20:42:58 $


keys = h.figures.keySet;
if(isempty(keys)); return; end
keysarray = keys.toArray;
for i = 1:numel(keysarray)
  callback = keysarray(i);
  hfig = h.figures.get(callback);
  if(isempty(hfig)|| ~ishandle(hfig))
    h.figures.remove(callback);
    continue;
  end
  if(h.isplottable(callback))
    if(strcmp('on', get(hfig, 'Visible')))
        % If the callback is plotdiffinfigure, we should update the figure
        % just once. Skip the results from the reference run, the figure has
        % already been updated for the active run.
        if (strcmpi(callback, 'plotdiffinfigure') && strcmpi(h.Run,DAStudio.message('FixedPoint:fixedPointTool:labelReference')))
            continue;
        end
      callback = ['h.' callback '(1)'];
      eval(callback);
    end
  else
    set(hfig, 'Visible', 'off');
  end
end

% [EOF]
