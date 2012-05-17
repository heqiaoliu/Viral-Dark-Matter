function sys = setDelayModel(H,tau)
%SETDELAYMODEL  Constructs state-space models with internal delays.
%
%   SETDELAYMODEL is the converse of GETDELAYMODEL and lets you directly 
%   specify the internal representation of state-space models with internal 
%   delays. See GETDELAYMODEL for more details on this internal 
%   representation. SETDELAYMODEL is an advanced operation and is not the 
%   natural way to construct models with internal delays.
%   
%   SYS = SETDELAYMODEL(A,B1,B2,C1,C2,D11,D12,D21,D22,TAU) constructs the
%   state-space model SYS defined by the matrices A,B1,B2,... and the vector 
%   of internal delays TAU.  The resulting model is continuous and can be 
%   made discrete by modifying its sample time.
%
%   SYS = SETDELAYMODEL(H,TAU) constructs the state-space model SYS obtained 
%   by LFT interconnection of the state-space model H with the bank of 
%   internal delays TAU.
%
%   See also GETDELAYMODEL, SS.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/02/08 22:28:49 $
error(nargchk(2,2,nargin))
tau = tau(:);
if ~(isnumeric(tau) && isreal(tau) && all(isfinite(tau)) && all(tau>=0)),
   ctrlMsgUtils.error('Control:ltiobject:setDelayModel1')
end

% Check size compatibility
nfd = length(tau);
s = size(H);
if any(s(1:2)<=nfd)
   ctrlMsgUtils.error('Control:ltiobject:setDelayModel3')
end

% Construct delay bank
try
   D = ss(eye(nfd),'Ts',getTs_(H),'InputDelay',tau);
catch E
   throw(E)
end

% Close LFT
sys = lft(H,D);
