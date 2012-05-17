function val = getDisplayIcon(h)
%GETDISPLAYICON

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:46 $$

val = h.userdata.displayicon;
if(isempty(h.userdata.displayicon) && isa(h.daobject, 'DAStudio.Object'))
  val = h.daobject.getDisplayIcon;
  h.userdata.displayicon = val;
end

% [EOF]
