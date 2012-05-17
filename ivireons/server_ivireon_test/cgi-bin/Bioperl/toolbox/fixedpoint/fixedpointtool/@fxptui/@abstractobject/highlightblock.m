function highlightblock(h)
%HIGHLIGHTBLOCK highlight this results daobject in the containing system

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/08 12:52:45 $

try
  me = fxptui.getexplorer;
  % Put the UI to sleep to prevent it from responding to events needlessly.
  me.sleep;
  mdl = h.getbdroot;
  bd = get_param(mdl, 'Object');
  bd.hilite('off');
  open_system(mdl, 'force');
  hilite_system(h.daobject.getFullName);
  % wake the UI.
  me.wake;
catch e %#ok<NASGU>
  % Wake the UI in case of an error.  
  me.wake;
  %consume errors if the attempted operations fail
end

% [EOF]
