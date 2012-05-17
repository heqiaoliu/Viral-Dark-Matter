function nlobj = init1d(nlobj, y, x)
%INIT1D: 1D RIDGENET initialization called from IDNLHW.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/07/09 20:52:33 $

% Author(s): Qinghua Zhang

numunits = nlobj.NumberOfUnits;
if ~isnonnegintscalar(numunits)
    ctrlMsgUtils.error('Ident:general:positiveIntPropVal','NumberOfUnits')
end

if isempty(numunits) || ischar(numunits)
    numunits =10; % Default value
    nlobj = pvset(nlobj, 'NumberOfUnits', numunits);
end

nobs= size(x, 1);

if isempty(x) % Initialization without data
    xmin = -1;
    xmax = 1;
    
    regmean = 0;
    ymean = 0;
    pct = [];
    lct = [];
else
    regmean = mean(x,1);
    x = x - regmean(ones(nobs,1), :);  %  regmat mean removal
    
    xmin = min(x);
    xmax = max(x);
    if xmax-xmin<(numunits+1)*eps
        xmin = xmin - 1;
        xmax = xmax + 1;
    end
    ymean = mean(y,1);
    
    % Nonlinear regressors
    pct = 1;
    
    % Linear regressors
    if strcmpi(nlobj.LinearTerm, 'on')
        lct = 1;
    else
        lct = zeros(1, 0);
    end
end

[f, g, rad] = unitfcn(nlobj, 0);

param = nlobj.Parameters;

param.RegressorMean = regmean;
param.NonLinearSubspace = pct;
param.LinearSubspace = lct;
param.LinearCoef = zeros(size(lct,2), 1);

if numunits==0
    param.Dilation = zeros(1,0);
    param.Translation = zeros(1,0);
    param.OutputCoef = zeros(0,1);
else
    
    if nobs<numunits+2 || idfewdatalevels(x)
        %= equi-spaced initialization =
        xri = 0.5*(xmax-xmin)/numunits;
        dila = 2*rad/xri;
        param.Dilation = ones(1,numunits) * dila;
        param.Translation = -dila * linspace(xmin+xri, xmax-xri, numunits);
        param.OutputCoef = zeros(numunits, 1);
        
    else
        %= non equi-spaced =
        xs = sort(x);
        mindila = 0.1*(xs(end)-xs(1))/numunits;
        mindila = max(mindila, sqrt(eps));
        pav = (length(xs)-1)/numunits;
        ubs = zeros(1, numunits+1);
        ubs(1) = xs(1);
        for k=2:numunits
            kpav = (k-1)*pav;
            ikpav = floor(kpav);
            ubs(k) = xs(ikpav+1) + (kpav-ikpav)*(xs(ikpav+2)-xs(ikpav+1));
        end
        ubs(numunits+1) = xs(end);
        
        param.Dilation = zeros(1,numunits);
        param.Translation = zeros(1,numunits);
        param.OutputCoef = zeros(numunits, 1);
        for k=1:numunits
            dila = 8*rad/max(ubs(k+1)-ubs(k), mindila);
            param.Dilation(k) = dila;
            param.Translation(k) = -dila * 0.5*(ubs(k+1)+ubs(k));
        end
        % Handle repeated translation values due to repeated x values.
        ind=find(~diff(param.Dilation));
        if ~isempty(ind)
            for k=1:length(ind)
                param.Dilation(ind(k)+1) = param.Dilation(ind(k)) + 0.5*mindila/numunits;
            end
        end
        %= End non equi-spaced =
    end
    
end

param.OutputOffset = ymean;
nlobj.Parameters = param;

% FILE END

