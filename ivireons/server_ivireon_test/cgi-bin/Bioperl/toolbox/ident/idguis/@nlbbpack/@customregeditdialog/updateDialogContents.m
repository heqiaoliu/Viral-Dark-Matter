function updateDialogContents(this)
% update the contents of the regressor dialog to agree with the nlarx
% model's chosen output.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:03:56 $

% if this.NlarxPanel.isSingleOutput
%     awtinvoke(this.jMainPanel.getOutputComboPanel,'setVisible(Z)',false);
% else
%     awtinvoke(this.jMainPanel.getOutputComboPanel,'setVisible(Z)',true);
% end   
% this.setOutputCombo;

messenger = nlutilspack.messenger;
unames = messenger.getInputNames;
ynames = messenger.getOutputNames;
names = [unames; ynames];

descr = cell(length(names),1);
for k = 1:length(unames)
    descr{k} = ['Input ',int2str(k)];
end

for k = 1:length(ynames)
    descr{k+length(unames)} = ['Output ',int2str(k)];
end

tabledata  = [names,descr];
this.jOneAtATimeTable.getModel.setData(nlutilspack.matlab2java(tabledata),0,length(names)-1);
% revalidate?

mp = this.jMainPanel.getMaximumPower;
if this.jCrossTermsCheckBox.isSelected
    crossterms = 'on';
else
    crossterms = 'off';
end

R = polyreg(this.RegDialog.ModelCopy,...
    'maxpower',mp,'CrossTerm',crossterms);
if ~this.NlarxPanel.isSingleOutput
    Ind = this.getCurrentOutputIndex;
    R = R{Ind};
end

R = nlutilspack.Reg2Str(R);
this.jBatchTable.getModel.setData(nlutilspack.matlab2java(R),0,length(R)-1);

% put in an example expression:
if length(names)==1
    str = sprintf('sin(%s(t-4))',names{1});
else
    str = sprintf('%s(t-2)*%s(t-1)^2',names{1},names{2});
end
javaMethodEDT('setText',this.jExpressionEdit,str);