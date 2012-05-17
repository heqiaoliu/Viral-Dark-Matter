function [yhat, initFilt, jcb] = outputJacobian(sys, data, initFilt, allParamNums, DB, DF)
%outputJacobian output and Jacobian of IDNLHW model.
%
%  [yhat, initFilt, jcb] = outputJacobian(sys, data, initFilt, DB, DF)
%  yhat: nobs-by-ny matrix
%  jcb: ny-by-1 cell array of nobs-by-np Jacobian matrices
%  data: iddata object
%  initFilt: pipeline for MaxSize
%  DB, DF: differentialted filter parameters
%
%Note: multi-experiment data being handled in the caller, data is
%single experiment here.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:54:16 $

% Author(s): Qinghua Zhang

if ~(isa(data, 'iddata') && size(data, 'ne')==1)
    ctrlMsgUtils.error('Ident:idnlmodel:outputJacCheck1')
end

doJacobian = nargout>2;

nobs = size(data, 1);
[ny, nu] = size(sys);

x0 = pvget(sys, 'InitialState');
initTerm = zeros(nobs, ny); % C*A^k*x0, created in any case.

if ~isempty(x0)
    initEstimate = true;
    [A,Bx,C] = ssdata(getlinmod(sys));
    [nx, nex] = size(x0);
    if nx~=size(A, 1)
        ctrlMsgUtils.error('Ident:idnlmodel:outputJacCheck2')
    end
    
    kex = data.UserData.kex;
    indkexnx = ((kex-1)*nx+1):(kex*nx);
    
    stableModel = all(abs(eig(A))<1);
    
    y_x0 = cell(ny,1);
    if stableModel
        x0kex = x0(:,kex);
        
        for ky=1:ny
            y_x0{ky} = zeros(nobs, nx);
            cakt = C(ky,:) * A^(data.UserData.FirstSample-1);
            for kt=1:nobs
                y_x0{ky}(kt,:) = cakt;
                cakt = cakt * A;
            end
            initTerm(:,ky) = y_x0{ky}*x0kex;
        end
    else
        for ky=1:ny
            y_x0{ky} = zeros(nobs, nx);
        end
    end
    
else
    initEstimate = false;
end

B = pvget(sys, 'b');
F = pvget(sys, 'f');
ncind = pvget(sys, 'ncind');
nb = pvget(sys, 'nb');
nf = pvget(sys, 'nf');

unlobj = pvget(sys, 'InputNonlinearity');
ynlobj = pvget(sys, 'OutputNonlinearity');

sumnumuparam = allParamNums.sumnumuparam;
numyparam = allParamNums.numyparam;
sumnumyparam = allParamNums.sumnumyparam;
numlparam = allParamNums.numlparam;       % Note: This does not count x0.
sumnumlparam = allParamNums.sumnumlparam;

% numallparam = sumnumuparam + sumnumyparam + sumnumlparam;

% InputNonlinearity
v = zeros(nobs, nu);

if doJacobian
    
    v_phi = cell(1,nu);
    for ku=1:nu
        [v(:,ku),v_phi{ku}] = getJacobian(unlobj(ku), data.u(:,ku));
    end
else
    for ku=1:nu
        v(:,ku) = getJacobian(unlobj(ku), data.u(:,ku));
    end
end

if isempty(initFilt)
    initFilt.xx = cell(ny, nu);
    initFilt.x_thDB = cell(ny);
    initFilt.x_thDF = cell(ny);
    for ky=1:ny
        initFilt.x_thDB{ky} = cell(1,numlparam(ky));
        initFilt.x_thDF{ky} = cell(1,numlparam(ky));
    end
    initFilt.x_phi = cell(ny, nu);
end

xx = cell(ny,1);
for ky=1:ny
    xx{ky} = zeros(nobs, nu); % Note: x{ky} = sum(xx{ky},2)
    for ku=1:nu
        [xx{ky}(:,ku), initFilt.xx{ky,ku}] = ...
            filter(B{ky,ku},F{ky,ku}, v(:,ku), initFilt.xx{ky,ku});
    end
end

if doJacobian
    x_phi = cell(ny,nu);
    x_th = cell(ny,1);
    for ky=1:ny
        x_th{ky} = zeros(nobs,numlparam(ky));
        kd = 0;
        for ku=1:nu
            for kk=1:nf(ky,ku)+nb(ky,ku)-double(ncind(ky,ku)~=0)
                kd = kd+1;
                [dum1, initFilt.x_thDB{ky}{kd}] = filter(DB{ky}{kd},F{ky,ku}, v(:,ku), initFilt.x_thDB{ky}{kd});
                [dum2, initFilt.x_thDF{ky}{kd}] = filter(DF{ky}{kd},F{ky,ku}, xx{ky}(:,ku), initFilt.x_thDF{ky}{kd});
                x_th{ky}(:,kd) = dum1 - dum2;
            end
            
            [x_phi{ky,ku}, initFilt.x_phi{ky,ku}] = ...
                filter(B{ky,ku},F{ky,ku}, v_phi{ku}, initFilt.x_phi{ky,ku});
        end
    end
end

yhat = zeros(nobs,ny);

if doJacobian
    y_psi = cell(ny,1);
    y_x = cell(ny,1);
    for ky=1:ny
        [yhat(:,ky), y_psi{ky}, y_x{ky}] = getJacobian(ynlobj(ky), sum(xx{ky},2)+initTerm(:,ky));
    end
else
    for ky=1:ny
        yhat(:,ky) = getJacobian(ynlobj(ky), sum(xx{ky},2)+initTerm(:,ky));
    end
end

if ~doJacobian
    return
end

jcb = cell(ny,1);
for ky=1:ny
    y_th = zeros(nobs,sumnumlparam); %Note: it is necessary to reset y_th to zero in each iteration.
    left = sum(numlparam(1:ky-1));
    y_th(:,left+1:left+numlparam(ky)) = y_x{ky}(:,ones(1,numlparam(ky))).*x_th{ky};
    
    y_allpsi = zeros(nobs,sumnumyparam); % Note: it is necessary to reset y_allpsi to zero in each iteration.
    left = sum(numyparam(1:ky-1));
    y_allpsi(:,left+1:left+numyparam(ky)) = y_psi{ky};
    
    if initEstimate
        y_allx0 = zeros(nobs, nex*nx); % Note: it is necessary to reset y_allx0 to zero in each iteration.
        y_allx0(:,indkexnx) = y_x{ky}(:,ones(1,nx)) .* y_x0{ky};
    else
        y_allx0 = [];
    end
    
    jcb{ky} = [y_x{ky}(:,ones(1,sumnumuparam)).*[x_phi{ky,:}], ...   % phi
        y_th, ...                                           % th
        y_allpsi, ...                                       % psi
        y_allx0];                                           % x0
end

% FILE END

