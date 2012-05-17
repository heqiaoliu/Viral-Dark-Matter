function sys = setDelayModel(a,b1,b2,c1,c2,d11,d12,d21,d22,tau)
%SETDELAYMODEL  Constructs state-space models with internal delays.
%
%   SETDELAYMODEL is the converse of GETDELAYMODEL and lets you
%   directly specify the internal representation of state-space 
%   models with internal delays.  See GETDELAYMODEL for more details
%   on this internal representation.  SETDELAYMODEL is an advanced 
%   operation and is not the natural way to construct models with 
%   internal delays.
%   
%   SYS = SETDELAYMODEL(A,B1,B2,C1,C2,D11,D12,D21,D22,TAU) constructs
%   the state-space model SYS defined by the matrices A,B1,B2,... and
%   the vector of internal delays TAU.  The resulting model is continuous
%   and can be made discrete by modifying its sample time.
%
%   SYS = SETDELAYMODEL(H,TAU) constructs the state-space model SYS
%   obtained by LFT interconnection of the state-space model H with
%   the bank of internal delays TAU.
%
%   See also SS/GETDELAYMODEL, SS.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/12/14 14:23:06 $
error(nargchk(10,10,nargin))
try
   H = ss(a,[b1 b2],[c1;c2],[d11 d12;d21 d22]);
catch
    ctrlMsgUtils.error('Control:ltiobject:setDelayModel2')
end
% Call ss method
try
   sys = setDelayModel(H,tau);
catch E
   throw(E)
end
