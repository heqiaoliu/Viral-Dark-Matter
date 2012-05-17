function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for POLY1D estimators.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vectors.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/10/02 18:55:04 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(3, 4, ni,'struct'))
ei.LossFcn = NaN;
ei.Iterations = NaN;
nv = [];
covmat = [];

if isempty(yvec) || isempty(regmat)
    ctrlMsgUtils.error('Ident:estimation:emptyData')
end
if iscell(yvec)
    % Tolerate cellarray data
    yvec = yvec{1};
end
if iscell(regmat)
    % Tolerate cellarray data
    regmat = regmat{1};
end

if ~isreal(yvec) || ~isreal(regmat) || ndims(yvec)~=2 || ndims(regmat)~=2
    ctrlMsgUtils.error('Ident:estimation:poly1dinit1')
end
nobsd = size(yvec,1);
[nobs, regdim]=size(regmat);
if nobsd~=nobs
    ctrlMsgUtils.error('Ident:estimation:poly1dinit2')
end

if regdim~=1
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','POLY1D')
end

degree = nlobj.Degree;
nobs = size(regmat,1);

jcb = ones(nobs, degree+1);
for kd = degree:-1:1
    jcb(:,kd) = regmat.*jcb(:,kd+1);
end

[Q,R, perm] = qr(jcb,0);
ws = warning('off','all');
try
    nlobj.Coefficients(perm) = (R\(Q'*yvec))';
catch
    warning(ws);
    ctrlMsgUtils.error('Ident:estimation:poly1dInitFailed')
end
warning(ws);

% FILE END
