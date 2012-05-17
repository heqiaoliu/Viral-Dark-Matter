function M = mpower(M,k)
%MPOWER  Repeated products of input/output model.
%
%   MPOWER(M,K) is invoked by M^K and returns
%     * if K>0, M * ... * M (K times) 
%     * if K<0, INV(M) * ... * INV(M) (K times)
%     * if K=0, EYE(SIZE(M)).
%   K must be an integer and M can be any model with the same number 
%   of inputs and outputs.    
%
%   For dynamic systems SYS, the syntax SYS^K is useful to specify 
%   transfer functions as expressions in the variable s or z. For 
%   example, you can specify
%             - (s+2) (s+3)
%      H(s) = ------------
%             s^2 + 2s + 2
%   by typing
%      s = tf('s')
%      H = -(s+2)*(s+3)/(s^2+2*s+2) .
%
%   See also INPUTOUTPUTMODEL/MTIMES, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:29 $
error(nargchk(1,2,nargin))
[ny,nu] = iosize(M);

% Error checking
if ny~=nu
   ctrlMsgUtils.error('Control:transformation:mpower1')
elseif ~(isnumeric(k) && isscalar(k) && k==round(k))
   ctrlMsgUtils.error('Control:transformation:mpower2')
end

% Update data
try
   M = mpower_(M,k);
catch E
   ltipack.throw(E,'expression','M^k','M',class(M))
end