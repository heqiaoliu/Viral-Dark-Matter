function refresh(this, isInput, Index)
% refresh the contents of the pwlinear editor

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:05:08 $

this.Parameters.Index = Index;
this.Parameters.isInput = isInput;

if isInput
    nlobj = this.Parameters.Panel.NlhwModel.InputNonlinearity(Index);
else
    nlobj = this.Parameters.Panel.NlhwModel.OutputNonlinearity(Index);
end

BP = nlobj.BreakPoints;
if size(BP,1)==1
    this.Parameters.x = BP;
    this.Parameters.y = [];
    this.isXonly = true;
elseif size(BP,1)==2
    this.Parameters.x = BP(1,:);
    this.Parameters.y = BP(2,:);
    this.isXonly = false;
else
    % empty BP
    this.isXonly = true;
    this.Parameters.x = [];
    this.Parameters.y = [];
end

this.NumUnits = nlobj.NumberOfUnits;

if this.isXonly
    javaMethodEDT('doClick',this.Handles.rx);
else
    javaMethodEDT('doClick',this.Handles.ry);
end

LocalSetText(this.Handles.XEdit,this.getStr('x'));
LocalSetText(this.Handles.YEdit,this.getStr('y'));

m = this.Parameters.Panel.NlhwModel;
if isInput
    iostr = 'input';
    name = m.uname{Index};
else
    iostr = 'output';
    name = m.yname{Index};
end


LocalSetText(this.Handles.iLabel,sprintf('Number of break points in nonlinearity for %s ''%s'': %d',...
    iostr,name,this.NumUnits));
LocalSetText(this.Handles.StatusLabel,'');

this.refreshWidgets;
javaMethodEDT('show',this.Handles.Dialog);


%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);
