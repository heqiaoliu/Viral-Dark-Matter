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
%        a time-domain IDDATA object, or as a real matrix. Multi-experiment
%        IDDATA cannot be used.
%
%   UMIN, UMAX: The input range of the input for the approximation. An
%        equivalent input is generated as white noise within this rectangular
%        range. The sample length of this signal is NSAMPLE (default
%        1024). For multi-input models, UMIN and UMAX should be specified
%        as vectors of Nu elements (Nu = no. of inputs).
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
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:10 $

% Author(s): Qinghua Zhang

nin = nargin;
error(nargchk(2, 4, nin, 'struct'));

if ~isestimated(nlsys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','linapp','nlarx')
end

[ny, nu] = size(nlsys);
na = nlsys.na;
nb = nlsys.nb;

if nu==0
    ctrlMsgUtils.error('Ident:transformation:linappTSModel')
end

npp1 = sum(na(:))+sum(nb(:))+1; % number of parameters plus 1

if nin<4
    nsample = 1024; % Default sample length
    if nsample<npp1
        nsample = npp1 + 1;
    end
elseif ~isposintscalar(nsample)
    ctrlMsgUtils.error('Ident:transformation:linappCheck1')
end
if nin<3
    if isa(u1, 'iddata')
        if size(u1,'ne')>1
            ctrlMsgUtils.error('Ident:analysis:findappMultiExpDataNotSupported')
        elseif ~strcmpi(u1.Domain,'Time')
            ctrlMsgUtils.error('Ident:analysis:findappFreqDomainData')
        end
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

if (size(u,1)-max([na(:);nb(:)]))*ny<npp1
    ctrlMsgUtils.error('Ident:general:tooFewDataSamples','findapp')
end

yhat=sim(nlsys,u);
linsys = arx([yhat u], [nlsys.na, nlsys.nb, nlsys.nk]);

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
    linsys = pvset(linsys, 'Notes', 'Best linear ARX approximation of an IDNLARX model');
else
    linsys = pvset(linsys, 'Notes', ['Best linear ARX approximation of ', iargnanme]);
end

% FILE END
