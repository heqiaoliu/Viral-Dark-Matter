function updateRegInfo(this,mobj,robj)
% update information about mobj in regressor object robj
% update RegInfo property only
% RegInfo fields to be updated: Name, Range, CenterPoint, ModelNames

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:08 $

model = mobj.Model;
modelname = mobj.ModelName;
modelreg = getreg(model);
nl = model.Nonlinearity;
if size(model,'ny')>1
    %multi-output case
    thisy = robj.OutputName;
    Ind  = find(strcmp(thisy,model.yname));
    modelreg = modelreg{Ind};
    nl = nl(Ind);
end

% now modelreg must be a cell array of Nreg elements (for one output only)
Lr = length(modelreg);
for i = 1:Lr
    thisreg = modelreg{i}; %a string
    range = nl.RegressorRange(:,i);
    if isempty(range)
        range = [-1 1];
    else
        del = abs(diff(range));
        range = [range(1)-0.1*del,range(2)+0.1*del];
    end

    % find if thisreg exists in robj (if present, there should be one instance only)
    Ind = find(arrayfun(@(x)strcmp(x.Name,thisreg),robj.RegInfo));
    if isempty(Ind)
        %thisreg is new; add it to the list
        newreginfo = struct('Name',thisreg,'Range',range,...
            'CenterPoint',mean(range),'ModelNames',{{modelname}});
        robj.RegInfo(end+1) = newreginfo;
    else
        % update info about existing reg: Range, ModelNames
        thisregstruct = robj.RegInfo(Ind);
        newnames = unique([thisregstruct.ModelNames;mobj.ModelName]); % why do "unique"?
        range0 = thisregstruct.Range;
        range = [min(range(1),range0(1)), max(range(2),range0(2))];
        
        thisregstruct.Range = range;
        thisregstruct.CenterPoint = mean(range);
        thisregstruct.ModelNames = newnames;
        robj.RegInfo(Ind) = thisregstruct;
    end
end

