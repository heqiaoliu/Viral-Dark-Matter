function [y,t,x] = initial(varargin)
%INITIAL  Initial condition response of state-space models.
%
%   INITIAL(SYS,X0) plots the undriven response of the state-space 
%   model SYS (created with SS) with initial condition X0 on the 
%   states.  This response is characterized by the equations
%                        .
%     Continuous time:   x = A x ,  y = C x ,  x(0) = x0 
%
%     Discrete time:  x[k+1] = A x[k],  y[k] = C x[k],  x[0] = x0 .
%
%   The time range and number of points are chosen automatically.  
%
%   INITIAL(SYS,X0,TFINAL) simulates the time response from t=0 to the 
%   final time t=TFINAL.  For discrete-time models with unspecified sample 
%   time, TFINAL should be the number of samples.
%
%   INITIAL(SYS,X0,T) specifies a time vector T to be used for simulation.  
%   For discrete systems, T should be of the form 0:Ts:Tf where Ts is the 
%   sample time. For continuous-time models, T should be of the form 
%   0:dt:Tf where dt will become the sample time of a discrete approximation 
%   of the continuous model.
%
%   INITIAL(SYS1,SYS2,...,X0,T) plots the response of several systems
%   SYS1,SYS2,... on a single plot. The time vector T is optional. You can 
%   also specify a color, line style, and marker for each system, for 
%   example:
%      initial(sys1,'r',sys2,'y--',sys3,'gx',x0).
%
%   When invoked with left hand arguments,
%      [Y,T,X] = INITIAL(SYS,X0)
%   returns the output response Y, the time vector T used for simulation, 
%   and the state trajectories X. No plot is drawn on the screen. The
%   matrix Y has LENGTH(T) rows and as many columns as outputs in SYS.
%   Similarly, X has LENGTH(T) rows and as many columns as states.
%	
%   See also INITIALPLOT, IMPULSE, STEP, LSIM, LTIVIEW, DYNAMICSYSTEM.

%	Clay M. Thompson  7-6-90
%	Revised: ACWG 6-21-92
%	Revised: PG 4-25-96
%       Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-02-01
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:42 $
ni = nargin;
no = nargout;

% Simulate the initial response
if no
   % Call with output arguments. Parse input list
   try
      [sysList,Extras] = DynamicSystem.parseRespFcnInputs(varargin);
      [sysList,t,x0] = DynamicSystem.checkInitialInputs(sysList,Extras);
   catch E
      throw(E)
   end
   sys = sysList(1).System;
   if (numel(sysList)>1 || numsys(sys)~=1),
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','initial');
   end
   
   if no<3
      % No state vector requested
      [y,t,focus] = timeresp(getPrivateData(sys),'initial',t,x0);
      x = [];
   else
      [y,t,focus,x] = timeresp(getPrivateData(sys),'initial',t,x0);
   end
   % Clip to FOCUS
   [t,y,x] = roundfocus('time',focus,t,y,x);

else
   % Initial response plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   varargin = argname2sysname(varargin,ArgNames);
   try
      initialplot(varargin{:});
   catch E
      throw(E)
   end
end
