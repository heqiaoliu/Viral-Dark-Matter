function M = inv(M)
%INV  Computes the inverse of an input/output model.
%
%   MI = INV(M) computes the inverse model MI such that
%
%       y = M * u   <---->   u = MI * y 
%
%   The model M must have as many inputs as outputs.
%   
%   See also INPUTOUTPUTMODEL/MLDIVIDE, INPUTOUTPUTMODEL/MRDIVIDE, 
%   INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/31 18:37:27 $
sizes = size(M);
if any(sizes==0),
   M = M.';  return
elseif sizes(1)~=sizes(2),
   ctrlMsgUtils.error('Control:transformation:inv5')
end
try
   M = inv_(M);
catch E
   ltipack.throw(E,'command','inv',class(M))
end