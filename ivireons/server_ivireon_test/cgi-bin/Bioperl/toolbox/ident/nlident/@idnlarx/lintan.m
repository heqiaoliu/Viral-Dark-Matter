function [linsys, ybar] = lintan(nlsys, u0, y0, opt)
%LINTAN Tangent linearization of IDNLARX models.
%This function is now obsolete. Use LINEARIZE instead.

% Old help content:
%   LM = LINTAN(NLMODEL)
%   [LM,Y] = LINTAN(NLMODEL,U,Y0,OPT)
%   LM = LINTAN(NLMODEL,U,Y,'nosearch')
%
%   NLMODEL: the nonlinear model to be linearized, an IDNLARX object.
%   LMODEL:  the linearized model, an IDPOLY object for single output model,
%          or an IDARX object for multi-output model. The linearization is
%          carried out around an equilibrium point (Y,U), such that the
%          output from NL model is a constant Y if the input is a constant U.
%   Y0, U: The equilibrium is determined for the constant input U. The value
%          Y of the equilibrium point (Y,U) is searched for around the given
%          Y0 vaue. Default Y0 = U = 0.
%   OPT:   The search for equilibrium is carried out by optimization using
%          fzero or fminsearch. OPT contains the options for this search.
%          (see OPTIMSET). Default OPT = [];
%   With the 'nosearch' option, the linearization is carried out around
%   given (Y,U) pair, even if this is not an equilibrium.
%
%   The function requires the Nonlinearity estimator of NLMODEL to be
%   differentiable, and no custom regressors are allowed.
%   LINTAN provides a linear model that is the best linear approximation
%   for inputs that vary in a small (infinitesemal) neighbourhood of a
%   constant input u(t) = U. This is the common linearization based on
%   function expansion. For linear approximations that should reasonable
%   over larger input ranges, it might be better to use the command LINAPP.
%
%   See also LINAPP.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:53:12 $

% Author(s): Qinghua Zhang

ctrlMsgUtils.warning('Ident:utility:lintanObsolete')

%{
[ny,nu] = size(nlsys);

if nargin<3
    u0 = zeros(1,nu);
else
    u0 = varargin{2};
end

if nargin<2
    y0 = zeros(1,ny);
else
    y0 = varargin{1};
end

[x0,u0,report] = findop(nlsys,'steady',u0,y0,'display','off');

linsys = linearize(nlsys,u0,x0);

if nargout>1
    ybar = report.SignalLevels.Output;
end
%}

nin=nargin;
error(nargchk(1,4, nin, 'struct'));

if ~isa(nlsys, 'idnlarx')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','lintan','IDNLARX')
end

if nin<2
    u0 = [];
end
if nin<3
    y0 = [];
end
if nin<4
    opt = [];
end

if ~(ischar(opt) || isempty(opt))
    msg = SubValidopt(opt);
    error(msg);
end

y0 = y0(:)';
u0 = u0(:)';

na=pvget(nlsys, 'na');
nb=pvget(nlsys, 'nb');
nk=pvget(nlsys, 'nk');
[ny, nu] = size(nlsys);

nlobj = pvget(nlsys, 'Nonlinearity');

for ky = 1:ny
    if ~isdifferentiable(nlobj(ky))
        ctrlMsgUtils.error('Ident:transformation:idnlarxLintan1',upper(class(nlobj(ky))));
    end
end

cusreg = pvget(nlsys, 'CustomRegressors');
if ~isempty(cusreg)
    if ny==1
        ctrlMsgUtils.error('Ident:transformation:idnlarxLintan2')
    end
    for ky=1:length(cusreg)
        if ~isempty(cusreg{ky})
            ctrlMsgUtils.error('Ident:transformation:idnlarxLintan2')
        end
    end
end

if isempty(y0)
    y0 = zeros(1, ny);
elseif length(y0)~=ny
    ctrlMsgUtils.error('Ident:analysis:lintanDimY')
end

if isempty(u0)
    u0 = zeros(1, nu);
elseif length(u0)~=nu
    ctrlMsgUtils.error('Ident:analysis:lintanDimU','lintan(NLMODEL, U,...)')
end

z0 = [y0 u0];

maxidelay = reginfo(na, nb, nk, cusreg);
maxdp1 = max(maxidelay)+1; %maxd plus 1

if  ischar(opt) && opt(1)=='n'  % no search, use the given point
    ybar = y0;
    equierr = [];
    
else  % search for the equilibrium point
    if ny==1
        [yvec, regmat] = makeregmat(nlsys, z0(ones(maxdp1,1),:));
        x0 = regmat{1}(1,:); % take the first row only if more rows are generated
        xu0 = x0(1, (na+1):end);
        [ybar, equierr] = fzero(@SubEqmSO, y0, opt, xu0, nlobj,na);
        
    else % ny>1
        xu0 = cell(ny,1);
        [yvec, regmat] = makeregmat(nlsys, z0(ones(maxdp1,1),:));
        for kk=1:ny
            x0 = regmat{kk};
            xu0{kk} = x0(1, (sum(na(kk,:),2)+1):end);
        end
        if isempty(opt) % modify default opt
            opt = optimset('fminsearch');
            opt = optimset(opt, 'TolFun', 1e-10, 'TolX', 1e-10);
        end
        ybar = fminsearch(@SubSqfv, y0, opt, xu0, nlobj, na);
        equierr = SubEqmMO(ybar, xu0, nlobj, na);
    end
    
    ftol = optimget(opt, 'TolFun', 1e-10);
    if any(abs(equierr)>ftol)
        eqr = equierr(:)';
        ctrlMsgUtils.warning('Ident:analysis:lintanErrorExceedTol', mat2str(eqr))
    end
end

z0 = [ybar u0];

if  ny==1 % single output, return idpoly object
    [yvec, regmat] = makeregmat(nlsys, z0(ones(maxdp1,1),:));
    x0 = regmat{1}(1,:); % take the first row only if more rows are generated
    [yhat0, Dy_nlpm, Dy_xv]=getJacobian(nlobj, x0);
    
    drift = yhat0 - Dy_xv*x0';
    
    ap = [1, -Dy_xv(1:na)];
    bp = zeros(nu, max(nb+nk));
    
    pt = na;
    for kk=1:nu
        bp(kk, (nk(kk)+1):(nk(kk)+nb(kk))) = Dy_xv((pt+1):(pt+nb(kk)));
        pt = pt + nb(kk);
    end
    
    linsys = idpoly(ap, bp);
    
else   % multiple output, return idarx object
    ndy = max(max(na));
    ndu = max(max((nb+nk-1)));
    
    A = zeros(ny,ny,ndy+1);
    A(:,:,1) = -eye(ny,ny);
    B = zeros(ny,nu,ndu+1);
    
    drift = zeros(ny, 1);
    
    [yvec, regmat] = makeregmat(nlsys, z0(ones(maxdp1,1),:));
    for kk=1:ny
        x0 = regmat{kk}(1, :);
        [yhat0, Dy_nlpm, Dy_xv]=getJacobian(nlobj(kk), x0);
        drift(kk) = yhat0 - Dy_xv*x0';
        
        pt = 0;
        for jj=1:ny
            nakj = na(kk,jj);
            A(kk,jj, 1+(1:nakj)) = Dy_xv(pt+(1:nakj));
            pt = pt + nakj;
        end
        
        for jj=1:nu
            nbkj = nb(kk,jj);
            nkkj = nk(kk,jj);
            B(kk,jj, nkkj+(1:nbkj)) = Dy_xv(pt+(1:nbkj));
            pt = pt + nbkj; % added 22/11/06
        end
    end
    A = -A;  % because A0 y(k) = -A1 y(k-1) - ...
    
    linsys = idarx(A, B);
end

% Mark Utility
ut = pvget(linsys, 'Utility');
ut.Drift = drift;
ut.EquilibriumError = equierr;
linsys = pvset(linsys, 'Utility', ut);

%Copy properties
Ts = pvget(nlsys, 'Ts');
tunit = pvget(nlsys, 'TimeUnit');
iname = pvget(nlsys, 'InputName');
iunit = pvget(nlsys, 'InputUnit');
oname = pvget(nlsys, 'OutputName');
ounit = pvget(nlsys, 'OutputUnit');

linsys = pvset(linsys, 'Ts', Ts, 'TimeUnit', tunit, 'InputName', iname, ...
    'InputUnit', iunit, 'OutputName', oname, 'OutputUnit', ounit);

iargnanme = inputname(1);
if isempty(iargnanme)
    linsys = pvset(linsys, 'Notes', 'Tangent linearization of a IDNLARX model');
else
    linsys = pvset(linsys, 'Notes', ['Tangent linearization of ', iargnanme]);
end

%===== Sub functions ====================================
function fv = SubEqmSO(y, xu0, nlobj, na)
%Equilibrium equation function, single output

fv = y - evaluate(nlobj, [y(ones(1,na)), xu0]);

%-----------------------------------------
function fv = SubEqmMO(y, xu0, nlobj, na)
%Equilibrium equation function, multi-output

ny = size(na,1);
fv = zeros(ny, 1);

for kk=1:ny
    xyu = zeros(sum(na(kk,:))+length(xu0{kk}),1);
    pt = 0;
    for jj=1:ny
        xyu(pt+(1:na(kk,jj))) = y(jj)*ones(1,na(kk,jj));
        pt = pt + na(kk,jj);
    end
    xyu(pt+1:end) = xu0{kk};
    fv(kk) = y(kk) - evaluate(nlobj(kk), xyu(:)');
end

%-----------------------------------------
function s = SubSqfv(y, xu0, nlobj, na)
% square of SubEqmMO
fv = SubEqmMO(y, xu0, nlobj, na);
fv = fv(:);
s = fv'*fv;

%-----------------------------------------
function msg = SubValidopt(opt)
% test optimization option validity
if ~isstruct(opt) || ~isequal(opt, optimset(opt))
    msg = sprintf('Invalid optimization options structure specified for "%s" command.','lintan');
    msg = struct('identifier','Ident:transformation:lintanInvalidOptimOpt',...
        'message',msg);
else
    msg = struct([]);
end


% FILE END
