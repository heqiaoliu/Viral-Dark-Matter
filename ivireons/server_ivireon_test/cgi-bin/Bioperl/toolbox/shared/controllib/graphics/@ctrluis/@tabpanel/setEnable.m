function setEnable(this,tf)
% Enables/disables tab

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:11 $
if tf
   set(this.Label,'Enable','inactive','HitTest','on')   
else
   set(this.Label,'Enable','off','HitTest','off')
end
