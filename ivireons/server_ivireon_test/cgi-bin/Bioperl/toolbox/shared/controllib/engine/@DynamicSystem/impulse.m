function [y,t,x] = impulse(varargin)
%IMPULSE  Impulse response of dynamic systems.
%
%   IMPULSE(SYS) plots the impulse response of the dynamic system SYS.  
%   For multi-input models, independent impulse commands are applied to 
%   each input channel. The time range and number of points are chosen 
%   automatically. For continuous systems with direct feedthrough, the 
%   infinite pulse at t=0 is ignored.
%
%   IMPULSE(SYS,TFINAL) simulates the impulse response from t=0 to the 
%   final time t=TFINAL.  For discrete-time systems with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   IMPULSE(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf  
%   where Ts is the sample time.  For continuous-time models, 
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time of a discrete approximation to the continuous system.  The
%   impulse is always assumed to arise at t=0 (regardless of Ti).
%
%   IMPULSE(SYS1,SYS2,...,T) plots the step response of several systems
%   SYS1,SYS2,... on a single plot. The time vector T is optional. You can 
%   also specify a color, line style, and marker for each system, for 
%   example:
%      impulse(sys1,'r',sys2,'y--',sys3,'gx').
%
%   When invoked with left-hand arguments,
%      [Y,T] = IMPULSE(SYS) 
%   returns the output response Y and the time vector T used for simulation.  
%   No plot is drawn on the screen. If SYS has NY outputs and NU inputs, 
%   and LT=length(T), Y is an array of size [LT NY NU] where Y(:,:,j) gives 
%   the impulse response of the j-th input channel.
%
%   For state-space models, 
%      [Y,T,X] = IMPULSE(SYS, ...) 
%   also returns the state trajectory X which is an LT-by-NX-by-NU 
%   array if SYS has NX states.
%
%   See IMPULSEPLOT for additional options for impulse response plots.
%
%   See also IMPULSEPLOT, STEP, INITIAL, LSIM, LTIVIEW, DYNAMICSYSTEM.

%	J.N. Little 4-21-85
%	Revised: 8-1-90  Clay M. Thompson, 2-20-92 ACWG, 10-1-94 
%	Revised: P. Gahinet, 4-24-96
%	Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-01-01
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:41 $
ni = nargin;
no = nargout;

% Simulate the impulse response
if no
   % Call with output arguments. Parse input list
   try
      [sysList,Extras] = DynamicSystem.parseRespFcnInputs(varargin);
      [sysList,tspec] = DynamicSystem.checkStepInputs(sysList,Extras);
   catch E
      throw(E)
   end
   sys = sysList(1).System;
   if (numel(sysList)>1 || numsys(sys)~=1),
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','impulse');
   end
   
   if no<3
      % No state vector requested
      [y,t,focus] = timeresp(getPrivateData(sys),'impulse',tspec);
      x = [];
   else
      [y,t,focus,x] = timeresp(getPrivateData(sys),'impulse',tspec);
   end
   % Clip to FOCUS
   [t,y,x] = roundfocus('time',focus,t,y,x);

else
   % Impulse response plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
   try
      impulseplot(varargin{:});
   catch E
      throw(E)
   end
end
