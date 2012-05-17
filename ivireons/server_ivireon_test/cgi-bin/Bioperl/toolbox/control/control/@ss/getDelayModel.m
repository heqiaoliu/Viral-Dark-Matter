function varargout = getDelayModel(sys,varargin)
%GETDELAYMODEL  State-space representation of internal delays.
%
%   State-space models with internal delays are represented by 
%   differential-algebraic equations of the form:
%      E dx/dt =  A x +  B1 u +  B2 w
%           y  = C1 x + D11 u + D12 w
%           z  = C2 x + D21 u + D22 w
%         w(t) = z(t - tau)
%   or their discrete-time counterparts:
%      E x[k+1] =  A x[k] +  B1 u[k] +  B2 w[k]
%         y[k]  = C1 x[k] + D11 u[k] + D12 w[k]
%         z[k]  = C2 x[k] + D21 u[k] + D22 w[k]
%         w[k]  = z[k - tau]
%   where u,y are the external inputs and outputs, and tau is the vector of 
%   internal delays. These equations correspond to the block diagram:
%
%                    +--------+
%          u ------->|        |-------> y
%                    |  H(s)  |
%             +----->|        |-----+
%             |      +--------+     |
%          w  |                     | z
%             |   +-------------+   |
%             +<--| exp(-tau*s) |<--+
%                 +-------------+   
%
%   where H(s) is the delay-free state-space model mapping [u;w] to [y;z].
%
%   [H,TAU] = GETDELAYMODEL(SYS) returns the state-space model H and vector 
%   TAU of internal delays making up the block diagram above.
%
%   [A,B1,B2,C1,C2,D11,D12,D21,D22,E,TAU] = GETDELAYMODEL(SYS) returns the
%   matrices A,B1,B2,... and vector TAU of internal delays for the 
%   state-space model SYS (see SS and DSS). The E matrix is set to [] for 
%   explicit models with no E matrix.
% 
%   Note that for models without internal delays:
%     * only A,B1,C1,D11 (and possibly E) are non-empty 
%     * TAU is empty and H is equal to SYS.
%
%   See also SS, DSS, DELAYSS, SETDELAYMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/02/08 22:28:32 $
D = sys.Data_;
if ~isscalar(D)
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','getDelayModel')
end
tau = D.Delay.Internal;
no = nargout;
if no>11
   ctrlMsgUtils.error('Control:ltiobject:getDelayModel1')
end

if no<3
   % Return LFT data
   nfd = length(tau);
   D.Delay.Internal = zeros(0,1);
   D.Delay.Input = [D.Delay.Input ; zeros(nfd,1)];
   D.Delay.Output = [D.Delay.Output ; zeros(nfd,1)];
   % Construct H
   H = sys;
   H.Data_ = D;
   H.IOSize_ = iosize(D);
   % Resize Unit property
   if ~isempty(sys.InputUnit_)
      H.InputUnit_ = [sys.InputUnit_ ; repmat({''},[nfd 1])];
   end
   if ~isempty(sys.OutputUnit_)
      H.OutputUnit_ = [sys.OutputUnit_ ; repmat({''},[nfd 1])];
   end
   % Name additional signals wj and zj
   wstr = strseq('w',1:nfd);
   if nfd>0 && isempty(intersect(wstr,sys.InputName_))
      H.InputName_ = [sys.InputName ; wstr];
   end
   zstr = strseq('z',1:nfd);
   if nfd>0 && isempty(intersect(zstr,sys.OutputName_))
      H.OutputName_ = [sys.OutputName ; zstr];
   end
   varargout = {H , tau};
else
   % Return matrices
   [a,b1,b2,c1,c2,d11,d12,d21,d22,~] = getBlockData(D);
   varargout = {a,b1,b2,c1,c2,d11,d12,d21,d22,D.e,tau};
end
