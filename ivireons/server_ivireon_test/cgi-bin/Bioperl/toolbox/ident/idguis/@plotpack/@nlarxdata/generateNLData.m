function [rangeout,y,thisnl] = generateNLData(this,robj,num)
% generate nonlinearity response for Model's output = robj.OutputName
% robj: regressor data object for one output (but potentially many models)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:51:05 $

model = this.Model;
yname = robj.OutputName;
ynames = model.yname;
k = find(strcmp(yname,ynames));
y = []; rangeout = []; thisnl = [];

%-----------------------------------------------
% check if this model is applicable
if isempty(k)
    % output yname does not belong to this model
    return;
end

% selected regressors:
robjcell = struct2cell(robj.RegInfo);
reglist = robj.ActiveRegressors;

selInd1 = robj.ComboValue.Reg1; %reg1 = robj.RegInfo(selInd1);
reg1name = reglist{selInd1};
reg1 = robj.RegInfo(strcmp(squeeze(robjcell(1,:,:)),reg1name));
if ~any(strcmp(this.ModelName,reg1.ModelNames))
    return
end
if ~robj.is2D
    selInd2 = robj.ComboValue.Reg2-1;
    reg2name = reglist{selInd2}; %reg2 = robj.RegInfo(selInd2);
    reg2 = robj.RegInfo(strcmp(squeeze(robjcell(1,:,:)),reg2name));
    if ~any(strcmp(this.ModelName,reg2.ModelNames))
        return
    end
end
%-----------------------------------------------

% reg1 (and reg2 if 3D) now definitely belong to the model
% find the indices of these regressors in the model for current output (k)
rr = getreg(model); 
if size(model,'ny') >1 %multi-output
    rr = rr{k};
end

selInd1 = find(strcmp(reg1.Name,{robj.RegInfo.Name})); %find(strcmp(reg1.Name,rr));
if ~robj.is2D
    selInd2 = find(strcmp(reg2.Name,{robj.RegInfo.Name})); %find(strcmp(reg2.Name,rr));
end

nl = get(model,'Nonlinearity');
thisnl = nl(k);
cpt = zeros(length(rr),1);
%cpt =  cat(1,robj.RegInfo.CenterPoint); % a vector of all center points
for k2 = 1:length(robj.RegInfo)
    if any(strcmp(this.ModelName,robj.RegInfo(k2).ModelNames))
        Ind = strcmp(rr,robj.RegInfo(k2).Name);
        cpt(Ind,1) = robj.RegInfo(k2).CenterPoint;
    end
end

Lr = length(cpt);

%need a "range" value for all regressors; range for unselected regressors
%is just a constant representing cross-section location
range = cell(1,Lr);

% first selected regressor
LocInModel1 = find(strcmp(reg1.Name,rr));
range{LocInModel1} = localObtainRange(robj.RegInfo(selInd1).Range,num);
rangeout{1} = range{LocInModel1};

%[LocInModel, selInd1, selInd2]
if ~robj.is2D
    %selInd = [selInd1,selInd2];
    %disp(sprintf('%s range: [%s] for %s',model.Name,num2str(robj.RegInfo(selInd2).Range),robj.RegInfo(selInd2).Name));
    LocInModel2 = find(strcmp(reg2.Name,rr));
    range{LocInModel2} =  localObtainRange(robj.RegInfo(selInd2).Range,num);
    rangeout{2} = range{LocInModel2};
   
    othersId =  setdiff(1:Lr,[LocInModel1,LocInModel2]); 
    for i = othersId
        range{i} = cpt(i);
    end

    len = cellfun('length',range);
    x(:,1) = range{1};
    for i = 2:length(range)
        n1 = size(x,1);
        xnew = range{i};
        L = length(xnew);
        x = repmat(x,L,1);
        xn = repmat(xnew',n1,1);
        x = [x,xn(:)];
    end
    y = evaluate(thisnl,x);
    y = squeeze(reshape(y,len));
else
    % 2D plot 
    x = repmat(cpt',length(rangeout{1}),1);
    reg1Ind = find(strcmp(reg1.Name,rr)); %location of chosen regressor in the model's own regressor list
    x(:,reg1Ind) = rangeout{1}; 
    %x = [range{1},repmat(cpt',length(range{1}),1)];
    y = evaluate(thisnl,x);
end


%--------------------------------------------------------------------------
function range = localObtainRange(val,num)
% range is now just [min max]; grid is generated using this.NumSample

range = linspace(val(1),val(2),num); 
range = range(:);
