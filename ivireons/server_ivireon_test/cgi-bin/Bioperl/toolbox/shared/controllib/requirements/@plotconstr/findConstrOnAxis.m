function List = findConstrOnAxis(hAx) 
% FINDCONSTRONAXIS return all the constraint objects displayed on an axis
%
 
% Author(s): A. Stothert 02-May-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:12 $

List = [];
GList = hAx.find('-depth', 1, '-isa', 'hggroup', 'Tag','Constraint');
for ct=1:numel(GList)
   hConstr = getappdata(GList(ct),'Constraint');
   if hConstr.Activated
      List = [List; hConstr];
   end
end
end