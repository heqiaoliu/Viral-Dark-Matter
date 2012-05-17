function addToCustomRegTable(this,Ind0)
% called by customregdialog to refresh the custom reg table.
% Ind0: output index in add custom reg dialog

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/05/19 23:04:18 $

Ind = this.getCurrentOutputIndex;
if ((nargin>1) && (Ind~=Ind0))
    % do not update if modified output is not showing
    % note: this condition is unreachable now
    return
end

m = this.ModelCopy; %this.NlarxPanel.NlarxModel;
custreg = get(m,'CustomRegressors');
thisnl = m.nl(Ind);
if ~this.NlarxPanel.isSingleOutput
    if ~isempty(custreg)
        custreg = custreg{Ind};
    end
end

% update custom regressors
if ~isempty(custreg)
    data0 = cell(this.jCustomTableModel.getData);
    if ~isempty(data0)
        flag0 = data0(:,2);
    end
    data2 = cell(length(custreg),2);
    data2(:,1) = nlutilspack.reg2str(custreg);
    if any(this.ActiveRegIndex==[2 3 4]) || isa(thisnl,'linear')
        % custom regressors are not selected for these combo options or
        % when nonlinearity is 'linear'
        
        data2(:,2) =  num2cell(false(length(custreg),1));
    else
        data2(:,2) =  num2cell(true(length(custreg),1));
        if ~isempty(data0)
            data2(1:length(flag0),2) = flag0; %restore status of old flags
        end
    end

    this.jCustomTableModel.setData(nlutilspack.matlab2java(data2),0,java.lang.Integer.MAX_VALUE);
    
    % show custom regressors table (collapsed by default)
    javaMethodEDT('openPage',this.jMainPanel,1);
else
    this.jCustomTableModel.setData({},0,java.lang.Integer.MAX_VALUE);
end
