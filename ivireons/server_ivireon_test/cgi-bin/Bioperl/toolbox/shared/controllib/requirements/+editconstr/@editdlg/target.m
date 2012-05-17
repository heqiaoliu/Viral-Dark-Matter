function target(this,Constr)
%TARGET  Points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Revised: A. Stothert, support multiple constraints
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:07 $

%Update list of constraints
if isempty(this.ConstraintList)
    this.ConstraintList = Constr;
    idx = 1;
    addlistener(Constr,'ObjectBeingDestroyed',@(hSrc,hData) localDeletedConstr(this,hSrc));
else
    idx = this.ConstraintList == Constr;
    if ~any(idx)
        addlistener(Constr,'ObjectBeingDestroyed',@(hSrc,hData) localDeletedConstr(this,hSrc));
        this.ConstraintList = [this.ConstraintList; Constr];
        idx = numel(this.ConstraintList);
    end
end

% Set target (edited constraint) - fires PostSet property event
this.Constraint = this.ConstraintList(idx);
end

function localDeletedConstr(this,Constr)

idx = this.ConstraintList==Constr;
this.ConstraintList(idx) = [];

if isempty(this.ConstraintList)
    %No more constraints to show, close dialog
    this.close
elseif this.Constraint == Constr
    %Deleted the currently visible constraint, retarget to next constraint
    %in list
    idx = min(find(idx),numel(this.ConstraintList));
    this.Constraint = this.ConstraintList(idx);
else
    %Deleted constraint not shown in dialog, update dialog constraint
    %combobox
    this.refresh
end
end



