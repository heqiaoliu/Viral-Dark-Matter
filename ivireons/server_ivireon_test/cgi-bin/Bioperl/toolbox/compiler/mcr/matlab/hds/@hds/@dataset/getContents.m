function s = getContents(this,Vars)
%GETCONTENTS  Returns structure of variable and link values.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:43 $
if nargin==1
   Vars = [getvars(this); getlinks(this)];
end
s = struct;
for ct=1:length(Vars)
   vn = Vars(ct).Name;
   s.(vn) = this.(vn);
end

% AllVars = getvars(this);
% AllLinks = getlinks(this);
% if nargin==1
%    Vars = [AllVars;AllLinks];
% end
% 
% % Initialize output
% nvars = length(Vars);
% s = cell2struct(cell(nvars,1),get(Vars,{'Name'}),1);
% 
% % Collect variable values
% [ia,ib] = utIntersect(Vars,AllVars);
% GridDim = utGridVarMap(this,Vars(ia));
% GridSize = getGridSize(this);
% for ct=1:length(ia)
%    A = getArray(this.Data_(ib(ct)));
%    if ~isempty(A) && GridDim(ct)>0 && all(GridSize>0)
%       % Replicate to grid size
%       A = this.utGridFill(A,GridSize,GridDim(ct));
%    end
%    s.(Vars(ia(ct)).Name) = A;
% end
% 
% % Collect link values
% [ia,ib] = utIntersect(Vars,AllLinks);
% for ct=1:length(ia)
%    s.(Vars(ia(ct)).Name) = this.Children_(ib(ct)).Links;
% end
