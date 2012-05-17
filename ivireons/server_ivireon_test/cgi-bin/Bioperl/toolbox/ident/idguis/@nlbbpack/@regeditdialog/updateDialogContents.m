function updateDialogContents(this,UpdateModelFirst)
% update the contents of the regressor dialog to agree with the nlarx
% model's chosen output.
% UpdateModelFirst: if true, copy nlarxpanel.Model into this.ModelCopy

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/07/09 20:52:21 $

if nargin<2
    UpdateModelFirst = true;
end

if UpdateModelFirst
    m = this.NlarxPanel.NlarxModel;
    this.ModelCopy = []; this.ModelCopy = m;
else
    m = this.ModelCopy;
end

Ind = this.getCurrentOutputIndex;

thisnl = m.Nonlinearity;

regind = get(m,'NonlinearRegressors');
allreg = getreg(m);
%allStdRegInd = nlregstr2ind(m, 'standard');
custreg = get(m,'CustomRegressors');
if ~this.NlarxPanel.isSingleOutput
    %allStdRegInd = allStdRegInd{Ind};
    allreg = allreg{Ind};
    custreg = custreg{Ind};
    regind = regind{Ind};
    thisnl = thisnl(Ind);
end
L = length(allreg) - length(custreg); % number of standard regressors in Ind'th output

% Correction for neuralnet and linear
if isa(thisnl,'neuralnet')
    regind = 'all'; %todo: not clear why NLR is ignored for neural net
    this.jMainPanel.setRegressorSelectability(false); %event thread
elseif isa(thisnl,'linear')
    regind = [];
    this.jMainPanel.setRegressorSelectability(false);
else
    this.jMainPanel.setRegressorSelectability(true);
end

if ischar(regind)
    % identifier string
    switch lower(regind)
        case {'all','search'}
            stdRegInd = 1:L; %allStdRegInd;
            %stdRegInd = 1:length(stdreg); %nlregstr2ind(m, 'standard');
            custRegInd = 1:length(custreg); %nlregstr2ind(m, 'custom');
            if strcmpi(regind,'all')
                selInd = 1;
            else
                selInd = 6;
            end
        case {'input','output'}
            % these are subsets of std reg (no custom)
            stdRegInd = nlregstr2ind(m, regind);
            custRegInd = [];
            if strcmpi(regind,'input')
                selInd = 2;
            else
                selInd = 3;
            end
        case 'standard'
            stdRegInd = 1:L; %allStdRegInd;
            %stdRegInd = 1:length(stdreg); %nlregstr2ind(m, regind);
            custRegInd = [];
            selInd = 4;
        case 'custom'
            custRegInd = 1:length(custreg); %nlregstr2ind(m, 'custom');
            stdRegInd = [];
            selInd = 5;
    end
    
    if iscell(stdRegInd)
        stdRegInd = stdRegInd{Ind};
    end
    
    if iscell(custRegInd)
        custRegInd = custRegInd{Ind};
    end

else
    selInd = 7;
    % numeric
    stdRegInd = regind(regind<=L); %regind(1:end-L);
    custRegInd = regind(regind>L)-L;
    
end

% update output info
yname = m.yname{Ind};
thisnlname = nlbbpack.getNlarxNonlinTypes('name',class(thisnl));
this.jMainPanel.setOutputInfo(yname,thisnlname); %event thread method

% update reg selection type combo
javaMethodEDT('setSelectedIndex',this.jRegTypesCombo,selInd-1);

% update std regressors
if (L>0)
    stdreg = allreg(1:L);
    data1 = cell(L,2);
    data1(:,1) = stdreg;
    flag = false(L,1);
    flag(stdRegInd) = true;
    data1(:,2) = num2cell(flag);
    this.jStdTableModel.setData(nlutilspack.matlab2java(data1),0,java.lang.Integer.MAX_VALUE);
else
    this.jStdTableModel.setData({},0,java.lang.Integer.MAX_VALUE);
end

% update custom regressors
if ~isempty(custreg)
    data2 = cell(length(custreg),2);
    data2(:,1) = nlutilspack.reg2str(custreg);
    flag = false(size(custreg));
    flag(custRegInd) = true;
    data2(:,2) = num2cell(flag);
    this.jCustomTableModel.setData(nlutilspack.matlab2java(data2),0,java.lang.Integer.MAX_VALUE);
    % show custom regressors table (collapsed by default)
    javaMethodEDT('openPage',this.jMainPanel,1);
else
    this.jCustomTableModel.setData({},0,java.lang.Integer.MAX_VALUE);
end

