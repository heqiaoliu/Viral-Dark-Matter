function refresh(this, isInput, Index)
% refresh the contents of the poly1d editor

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:05:05 $

this.Parameters.Index = Index;
this.Parameters.isInput = isInput;

if isInput
    nlobj = this.Parameters.Panel.NlhwModel.InputNonlinearity(Index);
else
    nlobj = this.Parameters.Panel.NlhwModel.OutputNonlinearity(Index);
end

C = nlobj.Coefficients;
if ~isempty(C)
    this.Parameters.Coefficients = C;
else
    this.Parameters.Coefficients = [];
end

this.Degree = nlobj.Degree;

LocalSetText(this.Handles.CoeffEdit,this.getStr);

m = this.Parameters.Panel.NlhwModel;
if isInput
    iostr = 'input';
    name = m.uname{Index};
else
    iostr = 'output';
    name = m.yname{Index};
end

LocalSetText(this.Handles.iLabel,sprintf('Degree of polynomial for %s ''%s'': %d',...
    iostr,name,this.Degree));
LocalSetText(this.Handles.StatusLabel,'');

javaMethodEDT('show',this.Handles.Dialog);


%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);
