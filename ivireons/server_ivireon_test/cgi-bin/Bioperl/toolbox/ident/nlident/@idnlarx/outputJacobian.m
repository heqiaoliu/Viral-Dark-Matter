function [ydata, initFilt, jcb] = outputJacobian(sys, data, initFilt)
%outputJacobian output and Jacobian of IDNLARX model.
%
%  [yhat, initFilt, jcb] = outputJacobian(sys, data, initFilt)
%  yhat: nobs-by-ny matrix
%  jcb: ny-by-1 cell array of nobs-by-np Jacobian matrices
%  data: iddata object
%  initFilt: pipeline for MaxSize
%  This method is for model estimation with Focus='Simulation'.
%
%Note: multi-experiment data being handled in the caller, data is
%single experiment here.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/11/09 16:23:55 $

% Author(s): Qinghua Zhang

if nargout>2
    computePsi = true;
else
    computePsi = false;
end

%Retrieve Center-Radius from data.UserData stored from focsimestimate.m
CR = pvget(data, 'UserData');
%HalfExtend = CR.Radius*(1.3 + iter*2/max(maxiter, 20)); % iter-dependent
HalfExtend = CR.Radius*1.3;
maxbound =  CR.Center + HalfExtend;
minbound =  CR.Center - HalfExtend;

na = pvget(sys, 'na');
nb = pvget(sys, 'nb');
nk = pvget(sys, 'nk');
[ny, nu] = size(sys);

custreg = pvget(sys, 'CustomRegressors');
if isempty(custreg)
    custreg = cell(ny,1);
elseif ~iscell(custreg)
    custreg = {custreg};
end

maxidelay = reginfo(na, nb, nk, custreg);
maxd = max(maxidelay);

anyoutcreg =  anyoutputcustomreg(custreg, ny);
if anyoutcreg
    % Compute ycustind, the indices of the custom regressors involving output
    % and mxind, the indices in mxdata corresponding to customreg function arguments.
    nstandreg = sum([na, nb], 2);
    custregflagvec = false(ny,1);
    ycustind = cell(ny,1);
    mxind = cell(ny,1);
    xcell = cell(ny,1);
    for ky=1:ny
        if ~isempty(custreg{ky}) && isa(custreg{ky},'customreg')
            custregflagvec(ky) = true;
            ncr = numel(custreg{ky});
            yflag = false(1, ncr);  % For row vectors ycustind{ky}, (1,ncr) instead of (ncr,1)
            xcell{ky} = cell(ncr,1);
            mxind{ky} = cell(ncr,1);
            for kcr=1:ncr
                if any(custreg{ky}(kcr).ChannelIndices<=ny)
                    yflag(kcr) = true;
                    mxind{ky}{kcr} = sub2ind([maxd+1, ny+nu], ...
                        maxd+1-custreg{ky}(kcr).Delays, ...
                        custreg{ky}(kcr).ChannelIndices);
                end
            end
            ycustind{ky} = find(yflag);
        end
    end
end

nobs0 = size(data,1); % Original nbos

if ~isempty(initFilt)
    % This is only part of initFilt
    data = [initFilt.data; data];
    initDataPad = true;
else
    initDataPad = false;
end
nobs = size(data,1); % possibly nbos0+maxd

% Memory initialization

currentyhat = zeros(1, ny);
if computePsi
    dy_y = cell(ny,ny);
    xistack = false(maxd,ny);
    %xiallstack = false(nobs,ny);  %ODS (activate lines marked "ODS" for output derivative saturation)
    Jacob = cell(ny,ny);
    psi = cell(ny,1);
    for ky=1:ny
        for iy=1:ny
            % ky: channels, iy: parameters (parameters are distinct per output)
            Jacob{ky,iy} = zeros(nobs, length(getParameterVector(sys.Nonlinearity(iy))));
        end
    end
    
    % Second part of initFilt
    if ~isempty(initFilt)
        for kyy=1:ny*ny
            Jacob{kyy}(1:maxd,:) = initFilt.Jacob{kyy};
        end
        xistack = initFilt.xistack;
    end
end


ydata = data.y;
if anyoutcreg
    udata = data.u;
end

[yvec, regmat] = makeregmat(sys, data);

% equalize the lengths of yvec and regmat for different output
for ky=1:ny
    yvec{ky} = yvec{ky}((maxd-maxidelay(ky)+1):end,:);
    regmat{ky} = regmat{ky}((maxd-maxidelay(ky)+1):end,:);
end

% Prepare indices for standard regressor update
% Note: yindkk corresponds to, but is different from Xyind of predict.m
% which operates on Xydata (state variables), not on ydata.
tosumnaky = cell(ny,1);
yindkk = cell(ny,1);
for ky=1:ny
    tosumnaky{ky} = 1:sum(na(ky,:));
    yindkk{ky} = zeros(1,sum(na(ky,:),2));
    pt = 0;
    for kky=1:ny
        nseq = 1:na(ky,kky);
        yindkk{ky}(1,pt+nseq) = repmat(1+maxd, 1,na(ky,kky))-nseq ...
            + nobs*(kky-1);  % This is to convert subscripts to linear index
        % Linear index is used to extract elements of ydata
        % not forming a sub-matrix.
        pt = pt+na(ky,kky);
    end
end

for kk=maxd+1:nobs;
    for ky=1:ny
        if computePsi
            [yhatk, dy_th, dy_x] = getJacobian(sys.Nonlinearity(ky), regmat{ky}(kk-maxd,:));
            psi{ky} = dy_th;
            
            pt = 0;
            for jy=1:ny
                dy_y{ky,jy} = zeros(1,maxd);
                dy_y{ky,jy}(1:na(ky,jy)) = dy_x(pt+1:pt+na(ky,jy));
                pt = pt + na(ky,jy);
            end
            
            if anyoutcreg && custregflagvec(ky)
                mxdata = [ydata(kk-maxd:kk,:), udata(kk-maxd:kk,:)];
                for kcr=ycustind{ky} % loop over custom regressors involving outputs only
                    crjac = numjac(custreg{ky}(kcr), mxdata(mxind{ky}{kcr}));
                    channels = custreg{ky}(kcr).ChannelIndices;
                    delays = custreg{ky}(kcr).Delays;
                    for kch=1:length(channels)
                        if channels(kch)<=ny %if the variable is an output
                             dy_y{ky,channels(kch)}(delays(kch)) = dy_y{ky,channels(kch)}(delays(kch)) + ...
                                dy_x(nstandreg(ky)+kcr)*crjac(kch);
                        end
                    end
                end
            end
            
        else
            yhatk = soevaluate(sys.Nonlinearity(ky), regmat{ky}(kk-maxd,:));
        end
        currentyhat(ky) = yhatk;
        
    end
    
    if computePsi
        for ky=1:ny
            for iy=1:ny
                if iy==ky
                    Jacob{ky,iy}(kk,:) = psi{ky};
                else
                    Jacob{ky,iy}(kk,:) = zeros(size(psi{iy}));
                end
                
                for jy=1:ny
                    Jacob{ky,iy}(kk,:) = Jacob{ky,iy}(kk,:) ...
                        + dy_y{ky,jy}.*(xistack(:,jy))' ...
                        * Jacob{ky,iy}((kk-1):(-1):(kk-maxd),:);
                end
            end
        end
    end
    
    xi1 = currentyhat<maxbound;
    xi2 = currentyhat>minbound;
    xi = xi1 & xi2; %indicator of being within constraints
    
    if computePsi
        xistack(2:maxd,:) = xistack(1:maxd-1,:);
        xistack(1,:) = xi;
        %xiallstack(kk,:) = xi;   %ODS
    end
    
    currentyhat = currentyhat.*double(xi) + maxbound.*double(~xi1) + minbound.*double(~xi2);
    ydata(kk, :) = currentyhat;
    
    for ky=1:ny;
        % Standard regressor update
        regmat{ky}(kk-maxd+1, tosumnaky{ky}) = ydata(kk-maxd+yindkk{ky});
        
        % Custom regressor update
        if kk<nobs && anyoutcreg && custregflagvec(ky)
            mxdata = [ydata(kk-maxd+1:kk+1,:), udata(kk-maxd+1:kk+1,:)];
            for kcr=ycustind{ky} % loop over custom regressors involving outputs only
                xcell{ky}{kcr} = num2cell(mxdata(mxind{ky}{kcr}));
                regval = custreg{ky}(kcr).Function(xcell{ky}{kcr}{:});
                regmat{ky}(kk-maxd+1, nstandreg(ky)+kcr) = regval;
            end
        end;
    end;
    
end; %for kk

% Make up initFilt for maxsize blocks
if computePsi && (nobs>=maxd)
    hw = ctrlMsgUtils.SuspendWarnings; % Turning off warnings
    initFilt.data = data(nobs-maxd+1:nobs);
    initFilt.data.y = ydata(nobs-maxd+1:nobs,:);
    delete(hw) % Restore warnings status
    initJacob = cell(ny,ny);
    for kyy=1:ny*ny
        initJacob{kyy} = Jacob{kyy}(nobs-maxd+1:nobs,:);
    end
    initFilt.Jacob = initJacob;
    initFilt.xistack = xistack;
end

% Pack up jcb and reduce to initial data sample size (if initDataPad)
if computePsi
    jcb = cell(ny,1);
    for ky=1:ny
        if initDataPad
            for iy=1:ny
                Jacob{ky,iy} = Jacob{ky,iy}(nobs-nobs0+1:nobs,:);
            end
        end
        jcb{ky} = [Jacob{ky,:}];
        %jcb{ky} = bsxfun(@times, [Jacob{ky,:}], xiallstack(:,ky));  % ODS
    end
end

if initDataPad
    ydata = ydata(nobs-nobs0+1:nobs,:);
end

% FILE END