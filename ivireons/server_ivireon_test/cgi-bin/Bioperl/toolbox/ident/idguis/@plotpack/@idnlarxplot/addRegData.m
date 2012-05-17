function addRegData(this,mobj)
% add regressor data for new model object (mobj) to the plot object (this)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:43 $


% now update database of per output data
ynames = mobj.Model.yname;
regdata = this.RegressorData;
if isempty(regdata)
    localAddNewRegData(this,mobj);
    return
end

for k = 1:length(ynames)
    robjk = find(this.RegressorData,'OutputName',ynames{k});
    if isempty(robjk) || ~ishandle(robjk)
        % add new one
        localAddNewRegData(this,mobj,ynames{k});
    else
        % update existing on
            % add model name to robjk
        if isempty(robjk.ModelNames) || ~any(strcmp(mobj.ModelName,robjk.ModelNames))
            robjk.ModelNames = [robjk.ModelNames;mobj.ModelName];
        end
        
            % now update robjk's regressors
        this.updateRegInfo(mobj,robjk);
    end
end


%--------------------------------------------------------------------------
function localAddNewRegData(this,mobj,yname)
% add a new regdata object

model = mobj.Model;
ynames = model.yname;
regs = getreg(model);
if length(ynames)==1
    % single output
    regs = {regs};
end

if nargin<3
    Ind = 1:length(ynames);
else
    Ind = find(strcmp(ynames,yname));
    ynames = {yname};
end

robj = handle([]);

for k = 1:length(ynames)
    nl = model.Nonlinearity(Ind(k));
    rangek = nl.RegressorRange;
    thisy = ynames{k};

    regk = regs{Ind(k)}; %regressors for one output
    for i = 1:length(regk)
        oneregrange = rangek(:,i);
        if isempty(oneregrange)
            oneregrange = [-1;1];
        else
            del = diff(oneregrange);
            oneregrange = [oneregrange(1)-0.1*del,oneregrange(2)+0.1*del];
        end
        reginfo(i) = struct('Name',regk{i},'Range',oneregrange,...
            'CenterPoint',mean(oneregrange),'ModelNames',{{mobj.ModelName}});
    end

    robjk = plotpack.regdata;
    robjk.OutputName = thisy;
    robjk.ModelNames = {mobj.ModelName};
    robjk.ComboValue.Reg1 = 1; %todo: could we have no regressors?
    if length(regk)>=2
        reg2combo = 3;
        robjk.is2D = false;
    else
        reg2combo = 1; %2D plot option
        robjk.is2D = true;
    end
    robjk.ComboValue.Reg2 = reg2combo;
    robjk.RegInfo = reginfo;
    clear reginfo;

    robj(k) = robjk;
end %k (per output)

this.RegressorData = [this.RegressorData,robj];

%--------------------------------------------------------------------------
