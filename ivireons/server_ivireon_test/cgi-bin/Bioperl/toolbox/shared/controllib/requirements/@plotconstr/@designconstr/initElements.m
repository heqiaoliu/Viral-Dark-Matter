function initElements(this,hParent) 
% CREATEELEMENTS initialize the elements property of design constraints
%
 
% Author(s): A. Stothert 02-May-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:48 $

if ~isempty(hParent)
   this.Elements = hggroup('Parent',hParent);
else
   this.Elements = hggroup;
end
set(this.Elements,'Tag','Constraint')
setappdata(this.Elements,'Constraint',this);