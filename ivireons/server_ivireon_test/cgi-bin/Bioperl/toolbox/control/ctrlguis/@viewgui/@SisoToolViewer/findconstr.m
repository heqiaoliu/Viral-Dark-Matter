function Constraints = findconstr(this)
%

%FINDCONSTR Finds all active design constraints objects attached to a
%viewer

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2008/05/31 23:16:22 $

Constraints = [];
for ct = 1:numel(this.Views)
   if ishandle(this.Views(ct))
      Constraints = [Constraints; this.Views(ct).findconstr];
   end
end