function [ys,ts,xs] = lsim(varargin)
%LSIM  Simulate time response of dynamic systems to arbitrary inputs.
%
%   LSIM(SYS,U,T) plots the time response of the dynamic system SYS to the
%   input signal described by U and T.  The time vector T consists of 
%   regularly spaced time samples and U is a matrix with as many columns 
%   as inputs and whose i-th row specifies the input value at time T(i).
%   For example, 
%           t = 0:0.01:5;   u = sin(t);   lsim(sys,u,t)  
%   simulates the response of a single-input model SYS to the input 
%   u(t)=sin(t) during 5 seconds.
%
%   For discrete-time models, U should be sampled at the same rate as SYS
%   (T is then redundant and can be omitted or set to the empty matrix).
%   For continuous-time models, choose the sampling period T(2)-T(1) small 
%   enough to accurately describe the input U.  LSIM issues a warning when
%   U is undersampled and hidden oscillations may occur.
%         
%   LSIM(SYS,U,T,X0) specifies the initial state vector X0 at time T(1) 
%   (for state-space models only). X0 is set to zero when omitted.
%
%   LSIM(SYS1,SYS2,...,U,T,X0) simulates the response of several systems
%   SYS1,SYS2,... on a single plot. The initial condition X0 is optional.
%   You can also specify a color, line style, and marker for each system, 
%   for example
%      lsim(sys1,'r',sys2,'y--',sys3,'gx',u,t).
%
%   Y = LSIM(SYS,U,T) returns the output history Y.  No plot is drawn on 
%   the screen.  The matrix Y has LENGTH(T) rows and as many columns as 
%   outputs in SYS.  For state-space models, 
%      [Y,T,X] = LSIM(SYS,U,T,X0) 
%   also returns the state trajectory X, a matrix with LENGTH(T) rows
%   and as many columns as states.
%
%   For continuous-time models,
%      LSIM(SYS,U,T,X0,'zoh')  or  LSIM(SYS,U,T,X0,'foh') 
%   explicitly specifies how the input values should be interpolated 
%   between samples (zero-order hold or linear interpolation). By default, 
%   LSIM selects the interpolation method automatically based on the 
%   smoothness of the signal U.
%
%   See LSIMPLOT for additional graphical options for LSIM plots.
%
%   See also LSIMPLOT, GENSIG, STEP, IMPULSE, INITIAL, DYNAMICSYSTEM.

%   To compute the time response of continuous-time systems, LSIM uses linear 
%   interpolation of the input between samples for smooth signals, and 
%   zero-order hold for rapidly changing signals like steps or square waves. 

%	J.N. Little 4-21-85
%	Revised 7-31-90  Clay M. Thompson
%       Revised A.C.W.Grace 8-27-89 (added first order hold)
%	                    1-21-91 (test to see whether to use foh or zoh)
%	Revised 12-5-95 Andy Potvin
%       Revised 5-8-96  P. Gahinet
%       Revised 6-16-00 A. DiVergilio
%	Copyright 1986-2007 The MathWorks, Inc. 
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:44 $
ni = nargin;
no = nargout;

% Simulate the time response to input U
% Use try/catch due to local error checking on initial condition
if no>0
   % Call with output arguments. Parse input list:
   try
      [sysList,Extras] = DynamicSystem.parseRespFcnInputs(varargin);
      [sysList,t,x0,u,InterpRule] = DynamicSystem.checkLsimInputs(sysList,Extras);
   catch E
      throw(E)
   end
   sys = sysList(1).System;
   if (numel(sysList)>1 || numsys(sys)~=1),
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','lsim');
   elseif isempty(t) || max(size(u))==0
      ctrlMsgUtils.error('Control:analysis:lsim3');
   end

   % Compute response
   if no>2
      % State vector required
      [ys,xs] = lsim(getPrivateData(sys),u,t,x0,InterpRule);
   else
      ys = lsim(getPrivateData(sys),u,t,x0,InterpRule);
      xs = [];
   end
   ts = t;

else
   % LSIM plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   varargin = argname2sysname(varargin,ArgNames);
   try
      lsimplot(varargin{:});
   catch E
      throw(E)
   end
end
