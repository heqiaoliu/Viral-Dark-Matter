function sys = upsample(sys,L)
%UPSAMPLE  Upsample discrete-time dynamic system.
%
%   SYSL = UPSAMPLE(SYS,L) resamples the discrete-time dynamic system SYS 
%   at an L-times faster rate where L is a positive integer. If SYS has 
%   sampling time Ts0 and transfer function H(z), the sampling time and 
%   transfer function of SYSL are Ts0/L and H(z^L).
%
%   The time responses of SYS and SYSL match at multiples of Ts0, and the
%   frequency responses of SYS and SYSL match up to the Nyquist frequency
%   pi/Ts0. Note that SYSL has L times as many states as SYS.
%
%   See also D2D, D2C, C2D, DYNAMICSYSTEM.

%   Author: Murad Abu-Khalaf, April 30, 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:37:13 $
ni = nargin;
error(nargchk(2,2,ni));

% Check for a positive integer upsampling factor
if ~(isnumeric(L) && isscalar(L) && round(L)==L && L>0)
   ctrlMsgUtils.error('Control:transformation:upsample01')
elseif ~isdt(sys)
   ctrlMsgUtils.error('Control:transformation:FirstArgDiscreteModel','upsample')
elseif L==1
   return
end

% Convert model
% REVISIT: Written for single rate system as is
Ts0 = getTs_(sys);
if Ts0<0
   % Unspecified sample time
   ctrlMsgUtils.error('Control:transformation:upsample02')
end
% Convert each model
try
   sys = upsample_(sys,L);
catch E
   ltipack.throw(E,'command','upsample',class(sys))
end

% Clear notes, userdata, etc
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];

