function sys = initnln(sys, data)
%INITNLN Hammerstein-Wiener model initialization

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.16 $ $Date: 2009/11/09 16:24:05 $

% Author(s): Qinghua Zhang

nf = pvget(sys,'nf');
nb = pvget(sys,'nb');
nk = pvget(sys,'nk');
[ny, nu] = size(sys);

isestimatedflag = isestimated(sys);

% Linear init

Bc = pvget(sys, 'b');
Fc = pvget(sys, 'f');
lmdlcell = cell(ny,1);

initStateMode = pvget(sys, 'InitialState');
if isempty(initStateMode)
    initStateMode = 'z';
elseif isnumeric(initStateMode)
    initStateMode = 'e';
end
was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF'); %#ok<NASGU>
for ky = 1:ny
    
    % Check if the linear model for output ky contains NaN.
    nanflag  = false;
    for ku=1:nu
        if any(isnan(Bc{ky,ku}(:))) || any(isnan(Fc{ky,ku}(:)))
            nanflag = true;
            break
        end
    end
    nanflag = nanflag && ~isestimatedflag; % for the case of changed nk.
    
    if nanflag
        % Linear model not initialized yet. Initialization by OE.
    
            warnAll = ctrlMsgUtils.SuspendWarnings;
    
            lmdl = oe(data(:,ky,:), [nb(ky,:), nf(ky,:), nk(ky,:)], ...
                'CovarianceMatrix', 'none', 'init',initStateMode);
    
            delete(warnAll)
        
        B = pvget(lmdl,'b');
        F = pvget(lmdl,'f');
        
        for ku=1:nu
            Bc{ky,ku} = B(ku,1:(nk(ky,ku)+nb(ky,ku)));
            Fc{ky,ku} = F(ku,1:(1+nf(ky,ku)));
        end
        
    else
        % Linear model already initialized. Put it in lmdl.
        B = zeros(nu, max(cellfun(@numel, Bc(ky,:))));
        F = zeros(nu, max(cellfun(@numel, Fc(ky,:))));
        for ku=1:nu
            B(ku,1:length(Bc{ky,ku})) = Bc{ky,ku};
            F(ku,1:length(Fc{ky,ku})) = Fc{ky,ku};
        end
        lmdl = idpoly(1,B,1,1,F);
    end
    
    lmdlcell{ky} = lmdl;
end

% Note: either the linear model was initialized or not before calling initnln,
% lmdl is created with default Algorithm fields, with oe or idpoly command.

% Normalize the largest coefficient of the initial B if necessary.
[ncindmat, Bc] = ncindconfig(sys, Bc);

for ky=1:ny
    B = pvget(lmdlcell{ky},'b');
    for ku=1:nu
        B(ku,1:(nk(ky,ku)+nb(ky,ku))) = Bc{ky,ku};
    end
    lmdlcell{ky}.b = B;
end

algo = pvget(sys, 'Algorithm');
algo.IterWavenet = 'on';

% Extract single exp data (if multi-exp).
nobs = size(data,1);
if length(nobs)>1
    [nobs, ind] = max(nobs);
    data = getexp(data, ind);
end
% From now on data is a single exp data.

% Input nonlinearity initialization

wstate = ctrlMsgUtils.SuspendWarnings;

marx = arx([data.u data.y], [eye(nu,nu), ones(nu,ny) zeros(nu,ny)]);
vdata = predict(marx,[data.u data.y],1,'InitialState','e');
if iscell(vdata)
    vdata = vdata{1};
end

delete(wstate)

udatacell = num2cell(data.u,1);

inputmdl = pvget(sys, 'InputNonlinearity');
if ~isinitialized(inputmdl)
    vdatacell = num2cell(vdata,1);
    inputmdl = initialize(inputmdl, vdatacell, udatacell, algo, true);
    inputmdl = linestimate(inputmdl, vdatacell, udatacell);
end

% Input binary data warnings
uselessnls = false(nu,1);
for ku=1:nu
    uselessnls(ku) = ~isa(inputmdl(ku), 'unitgain') && idfewdatalevels(udatacell{ku},2);
end
uselessnls = find(uselessnls);
nwarns = length(uselessnls);
if nwarns==1 && nu==1
    ctrlMsgUtils.warning('Ident:estimation:NlhwBinaryData1')
elseif nwarns==1 && nu>1
    ctrlMsgUtils.warning('Ident:estimation:NlhwBinaryData2',uselessnls);
elseif nwarns>1
    ctrlMsgUtils.warning('Ident:estimation:NlhwBinaryData3',mat2str(uselessnls))
end

% Output nonlinearity initialization

% Recompute vdata through initialized inputmdl
vdata = evaluate(inputmdl, udatacell);

wdata = zeros(nobs,ny);

wstate = ctrlMsgUtils.SuspendWarnings;

for ky=1:ny
    % Compute output of linear model driven by vdata
    % This is to estimate the center of the input range of outputmdl
    wdata(:,ky) = sim(lmdlcell{ky}, vdata);
end

delete(wstate);

% Set output coef of inputmdl to zero if possible
for ku=1:nu
    inputmdl(ku) = soreinit(inputmdl(ku), 0);
end
% Recompute vdata through zero inputmdl
vdata = evaluate(inputmdl, udatacell);

% Compute output of linear model driven by new vdata for wdata mean correction

wstate = ctrlMsgUtils.SuspendWarnings;

for ky=1:ny
    wdk = sim(lmdlcell{ky}, vdata);
    wdata(:,ky) = wdata(:,ky) + (mean(wdk) - mean(wdata(:,ky))); % correcting mean
end

delete(wstate);

outputmdl = pvget(sys, 'OutputNonlinearity');
if ~isinitialized(outputmdl)
    wdatacell = num2cell(wdata,1);
    ydatacell = num2cell(data.y,1);
    outputmdl = initialize(outputmdl, ydatacell, wdatacell, algo, true);
    outputmdl = linestimate(outputmdl, ydatacell, wdatacell);
end

sys = pvset(sys, 'InputNonlinearity', inputmdl, 'OutputNonlinearity', outputmdl, ...
    'b', Bc, 'f', Fc, 'ncind', ncindmat);

% FILE END

