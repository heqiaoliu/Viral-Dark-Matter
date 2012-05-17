function attachListeners(this)
% Attach listeners to regressor editor dialog widgets

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2008/07/14 17:07:22 $

jh = this.jMainPanel; 

% h = handle(this.jModelOutputCombo,'CallbackProperties');
% L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalOutputSelectionChanged(y,this));

h = handle(jh.getAddCustomRegButton,'CallbackProperties');
L2 = handle.listener(h,'ActionPerformed', @(x,y)LocalShowCustomRegressorDialog(this));

h = handle(jh.getDeleteCustomRegButton,'CallbackProperties');
L3 = handle.listener(h,'ActionPerformed', @(x,y)LocalDeleteCustomRegressor(this));

h = handle(jh.getCancelButton,'CallbackProperties');
L4 = handle.listener(h,'ActionPerformed', @(x,y)LocalCancelDialog(this));

h = handle(jh.getImportCustomRegButton,'CallbackProperties');
L5 = handle.listener(h,'ActionPerformed', @(x,y)LocalImportCustReg(this));

h = handle(jh.getRegTypesCombo,'CallbackProperties');
L6 = handle.listener(h,'ActionPerformed', @(x,y)LocalRegTypeSelectionCallback(y,this));

h = handle(this.jStdTableModel,'CallbackProperties');
L7 = handle.listener(h,'TableChanged', @(x,y)LocalRegTableChanged(y,this));

h = handle(this.jCustomTableModel,'CallbackProperties');
L8 = handle.listener(h,'TableChanged', @(x,y)LocalRegTableChanged(y,this));

h = handle(jh.getApplyButton,'CallbackProperties');
L9 = handle.listener(h,'ActionPerformed', @(x,y)LocalApplyDialog(this));

h = handle(jh.getOKButton,'CallbackProperties');
L10 = handle.listener(h,'ActionPerformed', @(x,y)LocalOKDialog(this));

h = handle(jh.getHelpButton,'CallbackProperties');
L11 = handle.listener(h,'ActionPerformed', @LocalShowHelp);

this.Listeners = [L2,L3,L4,L5,L6,L7,L8,L9,L10,L11];

%{
%--------------------------------------------------------------------------
function LocalOutputSelectionChanged(ed,this)
% not used anymore

Ind = max(1,ed.JavaEvent.getSource.getSelectedIndex+1);

if (Ind==this.ActiveOutputIndex) || (Ind<1)
    return;
end

%1a. first update the model for ActiveOutputIndex output
%1b. update ActiveOutputIndex
this.updateModelforActiveOutput;

%3. refresh the contents of the dialog for current output
this.updateDialogContents(false);
%}

%-------------------------------------------------------------------------
function LocalShowCustomRegressorDialog(this)
% show regressor dialog

this.CustomRegEditDialog.show;

%-------------------------------------------------------------------------
function LocalDeleteCustomRegressor(this)

selRows = this.jCustomRegTable.getSelectedRows+1;
if isempty(selRows)
    return
end
Ind = this.getCurrentOutputIndex;
m = this.ModelCopy; %this.NlarxPanel.NlarxModel;

%note: deletion causes nlreg to become "all", but the table selection
%remains unchanged. This difference is reconciled when Apply is pressed.

if ~this.NlarxPanel.isSingleOutput
    m.CustomRegressors{Ind}(selRows) = [];
else
    m.CustomRegressors(selRows) = [];
end

%this.NlarxPanel.NlarxModel = []; this.NlarxPanel.NlarxModel = m;
this.ModelCopy = []; this.ModelCopy = m;

% now update table
data2 = cell(this.jCustomTableModel.getData);
data2(selRows,:) = [];

if ~isempty(data2)
    this.jCustomTableModel.setData(nlutilspack.matlab2java(data2),0,...
        java.lang.Integer.MAX_VALUE);
else
    this.jCustomTableModel.setData({},0,java.lang.Integer.MAX_VALUE);
end


%--------------------------------------------------------------------------
function LocalCancelDialog(this)
% make dialog invisible

%this.updateModelforActiveOutput; % not needed because "estimate" does this
javaMethodEDT('setVisible',this.jMainPanel,false);


%--------------------------------------------------------------------------
function LocalApplyDialog(this)
% apply changes to current output

% set custom reg related note in main reg panel of nlarxpanel
d = cell(this.jCustomTableModel.getData);
if isempty(d)
    if this.NlarxPanel.isSingleOutput
        msg = 'Note: Model has no custom regressors.';
    else
        msg = 'Note: Model has no custom regressors for this output.';
    end
else
    msg = 'Note: Custom regressors exist for this output. Click on Edit Regressors... to view/modify them.';
end

this.NlarxPanel.jMainPanel.setCutomRegNote(msg); %event-thread method

this.updateModelforActiveOutput;

%--------------------------------------------------------------------------
function LocalOKDialog(this)
% apply changes to current output and close dialog

LocalApplyDialog(this);
LocalCancelDialog(this);

%--------------------------------------------------------------------------
function LocalImportCustReg(this)
% import dialog for custom reg

if isempty(this.CustomImportdlg) || ~ishandle(this.CustomImportdlg)
    this.CustomImportdlg = nlutilspack.varimportdialog;
    this.CustomImportdlg.initialize(this.jMainPanel,this,'customreg');
end

this.CustomImportdlg.workbrowser.open([1 NaN; NaN 1]);
javaMethodEDT('setVisible',this.CustomImportdlg.Frame,true);

%--------------------------------------------------------------------------
function LocalRegTypeSelectionCallback(ed,this)

selopt = max(1,ed.JavaEvent.getSource.getSelectedIndex+1);

if (selopt==this.ActiveRegIndex)
    return
end

Ind = this.getCurrentOutputIndex;
m = this.ModelCopy; %this.NlarxPanel.NlarxModel;
regind0 = get(m,'NonlinearRegressors');

if ~this.NlarxPanel.isSingleOutput
    regind0 = regind0{Ind};
end

%update model and call updateDialogContents to refresh dialog
switch selopt
    case 1
        regind = 'all';
    case 2
        regind = 'input';
    case 3
        regind = 'output';
    case 4
        regind = 'standard';
    case 5
        regind = 'custom';
    case 6
        regind = 'search';
    case 7
        % manual selection 
        
        %{
        tabledata = this.jStdTableModel.getData;
        flag = cell2mat(cell(tabledata(:,2)));
        regind = find(flag);
        %}
        
        if ischar(regind0)
            if strcmpi(regind0,'search')
                regind0 = 'all';
            end
            regind = nlregstr2ind(m, regind0);
        else
            regind = regind0;
        end
        
        if iscell(regind) %multi-output case
            regind = regind{Ind};
        end
        
    otherwise
        disp('Invalid reg-type selection in Regressor Editor.')
        return;
end

was = warning('off','Ident:idnlmodel:idnlarxUselessNlreg');
if this.NlarxPanel.isSingleOutput 
    m.NonlinearRegressors = regind;
else
    nlr = m.NonlinearRegressors;
    fInd = cellfun(@(x)strcmpi(x,'search'),nlr);
    
    if ~strcmp(regind,'search')
        fInd(Ind) = false; 
        % check if any of the exisiting nlreg are search
        if any(fInd)
            ct = find(fInd);
            if length(ct)==1
                msg = sprintf('The regressor selection for output %d will be changed to include ALL regressors.\n',ct);
            else
                msg = sprintf('The regressor selection for outputs [%s] will changed to include ALL regressors.',num2str(ct));
            end
            msg = {msg, 'Note that the option to search for regressors must be applied simultaneously to all the outputs.'};
            warndlg(msg,'Regressor Selection Change','modal');
            [nlr{fInd}] = deal('all');
        end
        nlr{Ind} = regind;
        m.NonlinearRegressors = nlr;
    else
        % all must be search
        fInd(Ind) = true; 
        if any(~fInd)
            warndlg('Regressors for all outputs will be set to be searched automatically.','Regressor Selection Change','modal');
        end
        m.NonlinearRegressors = repmat({'search'},size(m,'ny'),1);
    end
end
warning(was);

% this.NlarxPanel.NlarxModel = [];
% this.NlarxPanel.NlarxModel = m;
this.ModelCopy = []; this.ModelCopy = m;
this.ActiveRegIndex = selopt;

UpdateModelFirst = false;
this.updateDialogContents(UpdateModelFirst);

%--------------------------------------------------------------------------
function LocalRegTableChanged(ed,this)
% update reg type combo (select last entry) if user touched the table 

selInd = 7;
if (this.ActiveRegIndex==selInd)
    return;
end

col = ed.JavaEvent.getColumn   + 1;

% React only to table cell changes by the user.
if ~(col==2)
  return;
end

% set active reg index to have combobox callback abort update
this.ActiveRegIndex = selInd;

% update reg selection type combo
javaMethodEDT('setSelectedIndex',this.jRegTypesCombo,selInd-1);

%--------------------------------------------------------------------------
function LocalShowHelp(varargin)

iduihelp('nlarx_regconfig.htm','Help: Configuring Regressors for Nonlinear ARX Model');
