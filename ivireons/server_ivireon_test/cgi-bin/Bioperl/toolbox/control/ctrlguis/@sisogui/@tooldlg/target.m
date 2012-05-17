function target(h, Container, Constr)
%TARGET  Points dialog to a particular container/constraint.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2009/02/06 14:16:38 $

% RE: Target sets targeted container/constraint w/o bringing editor upfront

ni = nargin;

% Set target container (will also set ConstraintList and related listeners)
if ni<2,  % no container specified
    ContainerList = h.getlist('ActiveContainers');
    if isempty(ContainerList)
        h.close;
        return
    else
        Container = ContainerList(1);
    end
end
h.Container = Container;
    
% Update constraint list (constraints may be added and deleted in container)
ConstrList = h.getlist('Constraints');
if isempty(ConstrList)
    h.close;
    return
elseif ~isequal(h.ConstraintList,ConstrList)
    h.ConstraintList = ConstrList;
    % Force refresh of constraint list
    h.Constraint = [];
end
    
% Set target constraint
if ni<3,  % no constraint specified
    %SelectedConstr = find(h.ConstraintList,'-depth',0,'Selected','on');
    idx = [h.ConstraintList.Selected];
    SelectedConstr = h.ConstraintList(idx);
    if length(SelectedConstr)==1
        Constr = SelectedConstr(1);
    else 
        Constr = h.ConstraintList(1); % default to 1st if none or more than one selected
    end
end
h.Constraint = Constr;

