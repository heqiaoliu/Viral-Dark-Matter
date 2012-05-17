function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for UNITGAIN estimator.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 06:14:56 $

% Author(s): Qinghua Zhang


if iscell(regmat)
    % Tolerate cellarray data
    regmat = regmat{1};
end
if size(regmat,2)~=1
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','UNITGAIN')
end

ei = [];
nv = [];
covmat = [];

% FILE END
