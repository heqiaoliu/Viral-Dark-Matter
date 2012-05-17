function removeModel(this,Name)
%Remove model with name=Name from plot

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/01/29 15:34:11 $

if idIsValidHandle(this.ModelData)
    h = find(this.ModelData,'ModelName',Name);
    if ~idIsValidHandle(h)
        return;
    end
else
    return
end

ynames = h.Model.yname;
this.ModelData(this.ModelData==h) = [];

if isempty(this.ModelData)
    close(this.Figure);
    return
end

% delete lines
c1 = findall(this.MainPanels,'type','line','tag',Name);
c2 = findall(this.MainPanels,'type','surface','tag',Name);
c = [c1;c2];
delete(c)

% delete those panels that have empty axes
Ax = this.getAllAxes;
%Ax = findall(this.MainPanels,'type','axes');
uirem = handle([]);
for k = 1:length(Ax)    
    l1 = findobj(Ax(k),'type','line');
    l2 = findobj(Ax(k),'type','surface');
    l = [l1;l2];
    if isempty(l)
        uirem(end+1) = get(Ax(k),'Parent');
    end
end

for k = 1:length(uirem)
    this.MainPanels(this.MainPanels==uirem(k)) = [];
    delete(uirem(k));
end

% update RegressorData
localRemoveModelFromRegressorData(this,Name,ynames);

% refresh output names
this.OutputNames = this.getOutputNames;

% refresh legends and output combo
this.updateLabelLegendCombo;

% update views
%this.showPlot;

%--------------------------------------------------------------------------
function localRemoveModelFromRegressorData(this,mname,ynames)
% remove info about model with name mname from RegressorData Object

Indk = [];

for k = 1:length(ynames)
    thisy = ynames{k};
    robj = find(this.RegressorData,'OutputName',thisy);
    robj.ModelNames(strcmp(robj.ModelNames,mname)) = [];
    if isempty(robj.ModelNames)
        %this.RegressorData(this.RegressorData==robj) = [];
        Indk(end+1) = find(this.RegressorData==robj);
        continue;
    end
    Indi = [];
    for i = 1:length(robj.RegInfo)
        regi = robj.RegInfo(i); %struct
        regi.ModelNames(strcmp(regi.ModelNames,mname)) = [];
        if isempty(regi.ModelNames)
            Indi(end+1) = i;
            %robj.RegInfo(i) = []; %get rid of regi
            continue; % just in case
        else
            robj.RegInfo(i) = regi;
        end
    end %for i
    robj.RegInfo(Indi) = [];
end % for k

if ~isempty(Indk)
    removableOutputNames =  get(this.RegressorData(Indk),{'OutputName'});
    this.RegressorData(Indk) = [];
    this.OutputNames = setdiff(this.OutputNames,removableOutputNames);
end

% refresh list of active regressors that actually show in the combo boxes
this.updateActiveRegressors;
