function [v,idx] = findvar(this,varid,AccessFlag)
%FINDVAR  Locates variable with given name.
%
%   V = FINDVAR(D,VARNAME) searches the root-level node for a 
%   variable with name VARNAME and returns the corresponding 
%   @variable object V.
%
%   V = FINDVAR(D,VARNAME,ACCESSFLAG) further specifies how
%   deep to search for this variable. Options for ACCESSFLAG 
%   include:
%     'Root'          Searches only among root-level 
%                     variables (default)
%     'Transparent'   Extends search to variables of linked 
%                     data sets with Transparency='on'     

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:13:21 $
if nargin<3
   AccessFlag = 'root';
end

% Get variable list
switch lower(AccessFlag(1))
   case 'r'
      vars = getvars(this);
   case 't'
      vars = utGetVisibleVars(this);
end

% Find variable in this list
if ~isa(varid,'hds.variable')
   h = hds.VariableManager;
   varid = h.findvar(varid);
end
idx = find(vars==varid);

if isempty(idx)
   v = [];
else
   v = vars(idx);
end