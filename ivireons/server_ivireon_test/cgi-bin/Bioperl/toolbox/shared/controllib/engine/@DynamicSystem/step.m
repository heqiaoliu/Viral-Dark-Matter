function [y,t,x] = step(varargin)
%STEP  Step response of dynamic systems.
%
%   STEP(SYS) plots the step response of the dynamic system SYS. For 
%   multi-input models, independent step commands are applied to each 
%   input channel. The time range and number of points are chosen 
%   automatically.
%
%   STEP(SYS,TFINAL) simulates the step response from t=0 to the 
%   final time t=TFINAL. For discrete-time models with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   STEP(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf 
%   where Ts is the sample time.  For continuous-time models,
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time for the discrete approximation to the continuous system.  The
%   step input is always assumed to start at t=0 (regardless of Ti).
%
%   STEP(SYS1,SYS2,...,T) plots the step response of several systems
%   SYS1,SYS2,... on a single plot. The time vector T is optional. You 
%   can also specify a color, line style, and marker for each system, for
%   example:
%      step(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [Y,T] = STEP(SYS) returns the output response Y and the time vector T 
%   used for simulation. No plot is drawn on the screen. If SYS has NY 
%   outputs and NU inputs, and LT = length(T), Y is an array of size 
%   [LT NY NU] where Y(:,:,j) gives the step response of the j-th input 
%   channel.
%
%   [Y,T,X] = STEP(SYS) also returns, for a state-space model SYS, the
%   state trajectory X, a LT-by-NX-by-NU array if SYS has NX states.
%
%   See STEPPLOT for additional graphical options for step response plots.
%
%   See also STEPPLOT, IMPULSE, INITIAL, LSIM, LTIVIEW, DYNAMICSYSTEM.

%   Author(s): J.N. Little, 4-21-85
%   Revised:   A.C.W.Grace, 9-7-89, 5-21-92
%   Revised:   P. Gahinet, 4-18-96
%   Revised:   A. DiVergilio, 6-16-00
%   Revised:   B. Eryilmaz, 6-6-01
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:07 $
ni = nargin;
no = nargout;

% Simulate the step response
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
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','step');
   end

   if no<3
      % No state vector requested
      [y,t,focus] = timeresp(getPrivateData(sys),'step',tspec);
      x = [];
   else
      [y,t,focus,x] = timeresp(getPrivateData(sys),'step',tspec);
   end
   % Clip to FOCUS
   [t,y,x] = roundfocus('time',focus,t,y,x);

else
   % Step response plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
   try
      stepplot(varargin{:});
   catch E
      throw(E)
   end

end
