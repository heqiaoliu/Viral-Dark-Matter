function yhat = soevaluate(nlobj, regmat)
%SOEVALUATE: Single output evaluate method, return the value of LINEAR at given input.
%
%  yhat = soevaluate(nlobj, regmat)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:54:52 $

% Author(s): Qinghua Zhang

%no=nargout; 
ni=nargin;
error(nargchk(2,2,ni,'struct'))

if isempty(nlobj.Network)
  ctrlMsgUtils.error('Ident:idnlfun:emptyNetwork')
end

if ~isinitialized(nlobj)
  ctrlMsgUtils.error('Ident:idnlmodel:uninitializedEstimator')
end
  
if iscell(regmat) && numel(regmat)==1
  % Tolerate cellarray data
  regmat = regmat{1};
end

if isempty(regmat)
  yhat = zeros(size(regmat));
  return
end

if regdimension(nlobj)~=size(regmat,2)
  ctrlMsgUtils.error('Ident:analysis:incorrectNLDataDim')
end

yhat = sim(nlobj.Network, regmat')'; % regmat must be transposed

% FILE END

