function  nlobj = linestimate(nlobj, yvec, regmat)
%LINESTIMATE estimates the linear coeffients of nonlinearity estimator
%
% nlobj = linestimate(nlobj, yvec, regmat)
%

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:35 $

% Author(s): Qinghua Zhang

if isscalar(nlobj) && isreal(yvec) && isreal(regmat)
  nlobj = solinestimate(nlobj, yvec, regmat);
  return
end

idnlfunVecFlag = isa(nlobj,'idnlfunVector');
ny = numel(nlobj);

if iscell(yvec) && iscell(regmat) && numel(yvec)==ny && numel(regmat)==ny
  for ky=1:ny
    %if idnlfunVecFlag && isa(nlobj.ObjVector{ky}, 'ridgenet')
    if idnlfunVecFlag
      nlobj.ObjVector{ky} = linestimate(nlobj.ObjVector{ky}, yvec{ky}, regmat{ky});
    %elseif ~idnlfunVecFlag && isa(nlobj(ky), 'ridgenet')
    else
      nlobj(ky) = linestimate(nlobj(ky), yvec{ky}, regmat{ky});
    end
  end
else
  ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
end

% FILE END