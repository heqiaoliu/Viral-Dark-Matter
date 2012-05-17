function attachListeners(this)
% Attach listeners to regressor editor dialog widgets

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/10/16 04:56:19 $

% attach listeners to auto-select checkbox

h = handle(this.jModelOutputCombo,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalOutputSelectionChanged(this));

h = handle(this.jOneAtATimeTable.getSelectionModel,'callbackproperties');
L2 = handle.listener(h,'ValueChanged', @(x,y)LocalSelectionChanged(y,this));

h = handle(this.jCreateButton,'CallbackProperties');
L3 = handle.listener(h,'ActionPerformed', @(x,y)LocalAddRegressors(this));

h = handle(this.jRefreshButton,'CallbackProperties');
L4 = handle.listener(h,'ActionPerformed', @(x,y)LocalRefreshBatchTable(this));

h = handle(this.jHelpButton,'CallbackProperties');
L5 = handle.listener(h,'ActionPerformed', @LocalShowHelp);

this.Listeners = [L1,L2,L3,L4,L5];

%--------------------------------------------------------------------------
function LocalSelectionChanged(ed,this)

if strcmpi(get(ed.JavaEvent,'ValueIsAdjusting'),'on')
    return;
end
selRow = this.jOneAtATimeTable.getSelectedRow;
if selRow>=0
    tableData = cell(this.jOneAtATimeTable.getModel.getData);
    str = sprintf('%s(t-?)',tableData{selRow+1,1});
    if ~this.IsExprEditEmpty
        existingstr = this.jExpressionEdit.getText;
        str = [char(existingstr),str];
    end
    javaMethodEDT('setText',this.jExpressionEdit,str);
    
    this.IsExprEditEmpty = false;
end

%--------------------------------------------------------------------------
function LocalOutputSelectionChanged(this)

LocalRefreshBatchTable(this);

%--------------------------------------------------------------------------
function LocalAddRegressors(this)

Mode = this.jButtonGroup.getSelection.getActionCommand;
Ind = this.getCurrentOutputIndex;
m = this.RegDialog.ModelCopy; %this.NlarxPanel.NlarxModel;

msg = '';
if strcmp(Mode,'batch')
    mp = this.jMainPanel.getMaximumPower;
    if this.jCrossTermsCheckBox.isSelected
        ct = 'on';
    else
        ct = 'off';
    end
    
    newC = polyreg(m,'maxpower',mp,'CrossTerm',ct);
    if ~isempty(newC)
        if ~this.NlarxPanel.isSingleOutput
            Ind = this.getCurrentOutputIndex;
            newC = newC{Ind};
        end
    else
        iderrordlg({'No polynomial regressors created because model orders (No. of Terms for input and output variables) are zero.',...
            'Create regressors by choosing the "Enter regressor expression" option.'},...
            'Custom Regressor Creation Failure',this.jMainPanel)
        return
    end
else
    newC = char(this.jExpressionEdit.getText);
    %expr = char(this.jExpressionEdit.getText);
    %[newC,  msg] = nlutilspack.SOstr2cust(m, {expr}); %todo: update this (G336865)
end

try
    m = addreg(m, newC, Ind);
catch E
    iderrordlg(idlasterr(E),'Invalid Custom Regressor Expression',this.jMainPanel);
    return
end

% update the model copy in regedit dialog (not the actual model in
% nlarxpanel)

%this.NlarxPanel.updateModel(m);
this.RegDialog.ModelCopy = []; this.RegDialog.ModelCopy = m;

this.RegDialog.addToCustomRegTable(Ind); %update custom reg table

if strcmp(Mode,'oneatatime')
    this.IsExprEditEmpty = true;
end

%--------------------------------------------------------------------------
function LocalRefreshBatchTable(this)
% refresh batch mode table when refresh table button is pressed

mp = this.jMainPanel.getMaximumPower;
if this.jCrossTermsCheckBox.isSelected
    ct = 'on';
else
    ct = 'off';
end

R = polyreg(this.RegDialog.ModelCopy,'maxpower',mp,'CrossTerm',ct);
if ~this.NlarxPanel.isSingleOutput
    Ind = this.getCurrentOutputIndex;
    R = R{Ind};
end
R = nlutilspack.reg2Str(R);
this.jBatchTable.getModel.setData(nlutilspack.matlab2java(R),0,java.lang.Integer.MAX_VALUE);

%--------------------------------------------------------------------------
function LocalShowHelp(varargin)

iduihelp('nlarx_customreg.htm','Help: Creating Custom Regressors');
