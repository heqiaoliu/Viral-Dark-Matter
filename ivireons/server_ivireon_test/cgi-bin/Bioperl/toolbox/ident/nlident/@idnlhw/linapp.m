function linsys = linapp(nlsys, u1, u2, nsample)
%LINAPP: best linear approximation of IDNLARX or IDNLHW model for given input.
%
%   LM = LINAPP(NLMODEL,U)
%   LM = LINAPP(NLMODEL,UMIN,UMAX,NSAMPLE)
%
%   NLMODEL: the nonlinear model to be linearized, an IDNLARX or IDNLHW object.
%
%   LM:  The linearized model. The object class of LM depends on NLMODEL.
%        If NLMODEL is a single output IDNLARX object, LM is an IDPOLY object.
%        If NLMODEL is a multi-output IDNLARX object, LM is an IARX object.
%        If NLMODEL is a single output IDNLHW object, LM is an IDPOLY object.
%        If NLMODEL is a multi-output IDNLHW object, LM is an IDSS object.
%
%        LM may be converted into an LTI object of Control System Toolbox
%        by using TF, ZPK and SS commands. Example: SYS = SS(LM).
%
%   U:   Input signal of appropriate dimension. Given as the input data in
%        an IDDATA object, or as a real matrix.
%
%   [UMIN, UMAX]: The input range of the input for the approximation. An
%        equivalent input is generated as white noise within this rectangular
%        range. The sample length of this signal is NSAMPLE (default 1024).
%
%   LINAPP computes the best linear approximation (in an MSE sense) for the
%   given input U or a randomly generated input signal within the given range
%   [UMIN, UMAX]. LM should be a reasonable approximation over the range of
%   the chosen input. It differs from the linearization in a small neighbourhood
%   of a constant input, which is obtained by series expansion
%   ("linearization by tangent", see LINEARIZE).
%
%   See also IDNLARX/LINEARIZE, IDNLHW/LINEARIZE.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:54:13 $

% Author(s): Qinghua Zhang

nin=nargin;
error(nargchk(2, 4, nin,'struct'));

if ~isa(nlsys, 'idnlhw')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','linapp','IDNLHW')
end

if ~isestimated(nlsys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','linapp','nlhw')
end

[ny, nu] = size(nlsys);

if nin<4
    nsample = 1024; % Default sample length
end

if nin<3
    if isa(u1, 'iddata')
        u = u1.u;
    else
        u = u1;
    end
    if ~isrealmat(u)
        ctrlMsgUtils.error('Ident:transformation:linappCheck2')
    elseif size(u,2)~=nu
        ctrlMsgUtils.error('Ident:transformation:linappCheck3')
    end
else
    if ~isrealvec(u1)
        ctrlMsgUtils.error('Ident:transformation:linappCheck4','UMIN')
    end
    u1 = u1(:)';
    if length(u1)~=nu
        ctrlMsgUtils.error('Ident:transformation:linappCheck5','UMIN')
    end
    
    if ~isrealvec(u2)
        ctrlMsgUtils.error('Ident:transformation:linappCheck4','UMAX')
    end
    u2 = u2(:)';
    if length(u2)~=nu
        ctrlMsgUtils.error('Ident:transformation:linappCheck5','UMAX')
    end
    if any(u1>=u2)
        ctrlMsgUtils.error('Ident:transformation:linappCheck6')
    end
    
    u = rand(nsample, nu) * diag(u2-u1) + u1(ones(nsample,1),:);
end

% warnstate = warning;
% warning off
yhat = sim(nlsys,u);
if ny==1
    linsys = oe(iddata(yhat, u), [pvget(nlsys,'nb'), pvget(nlsys,'nf'), pvget(nlsys,'nk')]);
else
    linsys = pem(iddata(yhat, u), size(pvget(getlinmod(nlsys),'A'),1), ...
        'DisturbanceModel', 'None');
end
% warning(warnstate);

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
    linsys = pvset(linsys, 'Notes', 'Best linear OE approximation of an IDNLHW model');
else
    linsys = pvset(linsys, 'Notes', ['Best linear OE approximation of ', iargnanme]);
end

% FILE END
