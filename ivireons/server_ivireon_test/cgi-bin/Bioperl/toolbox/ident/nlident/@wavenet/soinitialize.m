function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for WAVENET estimators.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vector and matrix.
%
%  Initialize means non-iterative estimation for WAVENET.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/11/09 16:24:16 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(4, 4, ni,'struct'))

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
    ctrlMsgUtils.error('Ident:estimation:soinitialize1')
end
nobsd = size(yvec,1);
[nobs, regdim]=size(regmat);
if nobsd~=nobs
    ctrlMsgUtils.error('Ident:estimation:soinitialize2')
end

rdim = regdimension(nlobj);
if rdim>0 && rdim~=regdim
    ctrlMsgUtils.error('Ident:idnlfun:DataNLDimMismatch')
end

if strcmpi(nlobj.LinearTerm, 'off') && ...
        isnumeric(nlobj.NumberOfUnits) && nlobj.NumberOfUnits==0
    ctrlMsgUtils.error('Ident:idnlfun:NumUnitsLinearTerm')
end

[nlobj, nv, ei]= initwnet(nlobj, yvec, regmat, algo);
covmat = [];

% Oct2009
% FILE END
