function [sys,gic] = delay2z(sys)
%DELAY2Z  Replaces delays by poles at z=0 or phase shift.  
%
%   For a discrete-time linear system SYS,
%      SYSND = DELAY2Z(SYS) 
%   maps all time delays to poles at z=0.  Specifically, a delay of k 
%   sampling periods is replaced by (1/z)^k.
%
%   For state-space models,
%      [SYSND,G] = DELAY2Z(SYS)
%   also returns the matrix G mapping initial states of SYS to initial 
%   states of SYSND. If x0 is some initial condition for SYS, the 
%   corresponding initial condition for SYSND is G*x0.
%   
%   For FRD models, DELAY2Z absorbs all time delays into the frequency 
%   response data and is applicable to both continuous- and discrete-time 
%   systems.
%
%   See also HASDELAY, PADE, DYNAMICSYSTEM.

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:45 $
no = nargout;
if no==2 && numsys(sys)~=1
   ctrlMsgUtils.error('Control:transformation:ICMappingModelArrays','delay2z','delay2z')
end

% Map delays
try
   [sys,icmap] = delay2z_(sys);
catch ME
   ltipack.throw(ME,'command','delay2z',class(sys))
end

% IC mapping matrix
if no==2 && ~isempty(icmap)
   % Convert ICMap from vector to matrix map
   nx0 = sum(icmap);
   gic = zeros(length(icmap),nx0);
   gic(icmap,:) = eye(nx0);
else
   gic = [];
end
