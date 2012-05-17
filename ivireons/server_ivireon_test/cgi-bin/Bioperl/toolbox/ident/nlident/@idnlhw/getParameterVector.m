function th = getParameterVector(sys)
%getParameterVector returns the parameter vector of IDNLHW model.
%
%  vector = getParameterVector(sys)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:48:16 $

% Author(s): Qinghua Zhang

if isempty(sys.ncind) % Non initialized model has empty ncind
  th = [];
  return
end

x0 = pvget(sys, 'InitialState');
th = [getParameterVector(pvget(sys, 'InputNonlinearity'));
      bf2vec(pvget(sys, 'b'), sys.f, pvget(sys, 'ncind'), pvget(sys, 'nb'), pvget(sys, 'nf'), sys.nk);
      getParameterVector(pvget(sys, 'OutputNonlinearity'));
      x0(:)];
   %Note: pvget(sys, 'InitialState')=[] if not estimated.
     
% FILE END