function figureclose(s,e,hfig)
%FIGURECLOSE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 21:49:21 $

if(~ishandle(hfig))
  delete(s);
  return;
end
set(hfig, 'Visible', 'off');
zoom(hfig, 'out');

% [EOF]
