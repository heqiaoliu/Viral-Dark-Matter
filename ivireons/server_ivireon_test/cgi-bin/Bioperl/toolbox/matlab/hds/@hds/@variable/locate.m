function idx = locate(VarPool,vars)
%LOCATE  Locates variables in a given list.
%
%   IDX = LOCATE(VARPOOL,VARS) returns an index vector IDX
%   such that VARS = VARPOOL(IDX).  VARPOOL is a vector of
%   @variable objects, and VARS can be specified as a list 
%   of names or vector of @variable handles.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:58 $
nvars = length(vars);
if ~isa(vars,'handle')
   % Convert variable names to handles
   h = hds.VariableManager;
   vars = h.findvar(vars);
end
nvars = length(vars);

% Handle- based matching
[ia,ib] = utIntersect(VarPool,vars);
[ib,is] = sort(ib);
idx = ia(is);

if length(idx)~=nvars
   iv = 1:nvars;
   iv(ib) = [];
   error('Unknown variable %s.',vars(iv(1)).Name)
end