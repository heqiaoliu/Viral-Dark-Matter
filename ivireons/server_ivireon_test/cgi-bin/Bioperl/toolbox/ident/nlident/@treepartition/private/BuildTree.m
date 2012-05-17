function [nlobj, sigma2] = BuildTree(nlobj, y, x, algo)
%BUILDTREE: compute treepartition

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/11/09 16:24:13 $

% Author(s): Anatoli Iouditski

ni=nargin;

nunits = nlobj.NumberOfUnits;
lstab=nlobj.Options.Stabilizer;
fcell=nlobj.Options.FinestCell;
%rdtol=nlobj.Options.RegDimensionTol;
if ni==4,
    if strcmpi(algo.Display, 'full')
        smprintf displayon
    else
        smprintf displayoff
    end
end

[nobs,regdim] = size(x);
regmean = mean(x,1);
x = x - regmean(ones(nobs,1), :);  %  regmat mean removal
xminmax=[min(x);max(x)]';

% Linear Model Extension
hth = nlobj.Parameters;
if ~isempty(hth.LinearCoef) && ~isinitialized(nlobj) % The 2nd condition checks empty fields.
  extlin = [hth.LinearCoef; zeros(regdim-length(hth.LinearCoef),1)];
  % Note: the trailing zeros of extlin are eventually for custom regressors.
else
    extlin = [];
end

outoffset = mean(y,1);
y = y - outoffset;  % yvec has now zero mean

nonlble = nlobj.NonlinearRegressors;

if ischar(nonlble) && strcmpi(nonlble, 'all')
    nonlble = 1:regdim;
elseif max(nonlble)>regdim,
    ctrlMsgUtils.error('Ident:estimation:nlregDataDimMismatch')
elseif isempty(nonlble),
    nonlble = 1:regdim;
end

nonlin=0; nodata=0;
% Treat the case of a purely linear model or too small dataset
if isempty(nonlble), nonlin=1;
else
    if ischar(fcell) && strcmpi(fcell,'Auto')
        fcell=2;
    end
    
    if  nobs<=2*fcell*(regdim+1), nodata=1; end
end
if nonlin||nodata||(isnumeric(nunits)&&~nunits) % modification of nunits 09-28-09
    % managing LinearCoef property (added on 09-27-09)
    if isempty(extlin)
        xx=[ones(nobs,1),x];
        xmat=xx'*xx;
        xmat=xmat+(regdim+1)*norm(xmat)*lstab*eye(regdim+1);
        sxy=y'*xx;
        xmat=pinv(xmat);
        coeflin=xmat*sxy';
        sigma2=norm(y-xx*coeflin)^2/(nobs-regdim-1);
        coeflin=coeflin(2:end);
    else
        coeflin=extlin;
        sigma2=norm(y-x*coeflin)^2/(nobs-regdim);
    end
    ht=[];
    % Set the actual NumberOfUnits
    nlobj.NumberOfUnits=1;
    if ni==4,
        ctrlMsgUtils.warning('Ident:idnlmodel:emptyTree')
        if nodata
            ctrlMsgUtils.warning('Ident:idnlmodel:treeShortRegData')
        end
    end
else
    pmatrix=zeros(regdim,1);
    pmatrix(nonlble)=1;
    pmatrix=diag(pmatrix);
    
    % Compute Treepartition itself
    
    [ht,ns]=sieve([y x],pmatrix,fcell,nunits,lstab,extlin);
    coeflin=ht.LocalParVector(1,2:end)';
    sigma2=ns^2;
    % Set the actual NumberOfUnits
    nlobj.NumberOfUnits =length(ht.TreeLevelPntr);
    if ni==4,
        smprintf('\nNumber of treepartition units: %d\n', length(ht.TreeLevelPntr));
        smprintf('Number of treepartition levels: %d\n', ht.TreeLevelPntr(end));
    end
end
if isempty(ht),
    hth=pstructure([]);
end
% Dereference outputs
hth.RegressorMean = regmean;
hth.RegressorMinMax = xminmax;
hth.OutputOffset = outoffset;
hth.LinearCoef = coeflin;
hth.SampleLength=nobs;
hth.NoiseVariance=sigma2;
if ~isempty(ht)
    hth.Tree=ht;
end

% Note: Parameters must be the last property of nlobj to be set,
% otherwise the other property settings may clear Parameters.
nlobj.Parameters = hth;

% Oct2009
% FILE END

