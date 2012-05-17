function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for LINEAR estimator.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vector and matrix.
%
%  Note: "initialization" means non-iterative estimation for LINEAR.

% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2010/04/11 20:32:42 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(4, 4, ni,'struct'))

if isempty(yvec) || isempty(regmat)
    ctrlMsgUtils.error('Ident:estimation:emptyData')
end

if iscell(yvec)
    % Tolerate cell array data
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

net = nlobj.Network;
if isempty(net)
    ctrlMsgUtils.error('Ident:idnlfun:emptyNetwork')
end

if rdim<0
    % net.inputs{1}.range is not specified yet, use data range.
    if isempty(regmat)
        regrange = [-1, 1];
    else
        regrange = [min(regmat,[],1)' max(regmat,[],1)'];
    end
    net.inputs{1}.range = regrange;
end

% Replace default [-Inf Inf] with true output range.
if all(isinf(net.outputs{net.outputConnect}.range))
   net.outputs{net.outputConnect}.range = [min(yvec), max(yvec)];
end  

if ~isinitialized(nlobj)
    net = init(net);
end

net = train(net, regmat', yvec');

nlobj.Network = net;
nlobj.Initialized = true;

ei.LossFcn = 1;
nv = 1;
covmat = [];

% FILE END
