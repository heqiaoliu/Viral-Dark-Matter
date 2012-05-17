function updateModelforActiveOutput(this)
% When user changes output selection or hits close button, the
% nonlinearity info for Active (previous) output must be saved into the
% model.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/10/16 04:56:20 $

m0 = this.NlarxPanel.NlarxModel;
m = this.ModelCopy;
Ind = this.ActiveOutputIndex;

selopt = this.ActiveRegIndex; %max(1,this.jRegTypesCombo.getSelectedIndex+1);
this.ActiveOutputIndex = this.getCurrentOutputIndex;

was = warning('off','Ident:idnlmodel:idnlarxUselessNlreg');
if (selopt~=7)
    m0.CustomReg = m.CustomReg;
    if (selopt==6)
        % if combo-box selection is for search, then second column is not
        % visible; model has to be updated explicitly to use nlr='search'
        m.NonlinearReg = repmat({'search'},size(m,'ny'),1);
    else
        % (note: customreg modification resets nlr to "all" - g354604)
        % hence the nlreg can't be read directly from model m.
        switch selopt
            case 1
                regindstr = 'all';
            case 2
                regindstr = 'input';
            case 3
                regindstr = 'output';
            case 4
                regindstr = 'standard';
            case 5
                regindstr = 'custom';
        end
        if this.NlarxPanel.isSingleOutput
            m.NonlinearRegressors = regindstr;
        else
            m.NonlinearRegressors{Ind} = regindstr;
        end
    end
    m0.NonlinearReg = m.NonlinearReg; 
    this.NlarxPanel.updateModel(m0);
    warning(was);
    return;
end

% if selopt==7 (manual mode), read table data
regind = [];
tabledata = cell(this.jStdTableModel.getData);
flag = [];
if ~isempty(tabledata)
    flag = cell2mat(tabledata(:,2));
    regind = find(flag);
end

tabledata2 = cell(this.jCustomTableModel.getData);
if ~isempty(tabledata2)
    flag2 = cell2mat(tabledata2(:,2));
    regind2 = find(flag2);
    regind = [regind;regind2+length(flag)];
end

if this.NlarxPanel.isSingleOutput
    m.NonlinearRegressors = regind(:).';
else
    m.NonlinearRegressors{Ind} = regind(:).';
end

this.ModelCopy = []; this.ModelCopy = m;
m0.CustomReg = m.CustomReg;
m0.NonlinearReg = m.NonlinearReg; 

this.NlarxPanel.updateModel(m0);

warning(was);