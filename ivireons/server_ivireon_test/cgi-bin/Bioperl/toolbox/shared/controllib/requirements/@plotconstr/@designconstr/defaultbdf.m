function defaultbdf(Constr)
%DEFAULTBDF  Defines default ButtonDown callback.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:54 $

Constr.ButtonDownFcn = {@LocalDefaultBDF Constr};
end

function LocalDefaultBDF(eventSrc,~,Constr)
% Callback
if Constr.isLocked
   HostFig  = get(Constr.Elements.Parent,'Parent');
   SelectionType = get(HostFig, 'SelectionType');
   if ~strcmp(SelectionType,'alt')
      %'Normal' or, 'open' click on locked patch, check whether we want to
      %unlock constraint
      Constr.LockedButtonDownFcn();
   end
else
   Constr.mouseevent('bd',eventSrc);
end
end