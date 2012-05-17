function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for TREEPARTITION estimators.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vector and matrix.
%
%  Note: "initialization" means non-iterative estimation for TREEPARTITION.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:55:46 $

% Author(s): Anatoli Iouditski

ni=nargin;
error(nargchk(3, 4, ni,'struct'))

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
if nobs<=regdim,
    ctrlMsgUtils.error('Ident:estimation:treeInitShortData')
end
rdim = regdimension(nlobj);
if rdim>0 && rdim~=regdim
    ctrlMsgUtils.error('Ident:idnlfun:DataNLDimMismatch')
end

% if nlobj.NumberOfUnits==0 & strcmpi(nlobj.LinearTerm, 'off')
%     error('When LinearTerm is off, NumberOfUnits cannot be 0.');
% end
if ni==3
    [nlobj, nv]= BuildTree(nlobj, yvec, regmat);
else
    [nlobj, nv]= BuildTree(nlobj, yvec, regmat, algo);
end
ei=[];
covmat=[];
% FILE END
