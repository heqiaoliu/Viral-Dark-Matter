function deleteConstr(this,Constr)

%   Author(s): A. Stothert
%   Revised:
%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:01 $


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