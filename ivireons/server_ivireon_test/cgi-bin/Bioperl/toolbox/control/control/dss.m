function sys = dss(varargin)
%DSS  Create descriptor state-space (DSS) models
%          .
%        E x = A x + B u            E x[n+1] = A x[n] + B u[n]
%                             or 
%          y = C x + D u                y[n] = C x[n] + D u[n]  
%         
%   SYS = DSS(A,B,C,D,E) creates a continuous-time DSS model SYS
%   with matrices A,B,C,D,E. The output SYS is an object of class @ss.
%   You can set D=0 to mean the zero matrix of appropriate dimensions.
%
%   SYS = DSS(A,B,C,D,E,Ts) creates a discrete-time DSS model with 
%   sample time Ts (set Ts=-1 if the sample time is undetermined).
%
%   You can set additional model properties by using name/value pairs.
%   For example,
%      sys = dss(A,B,C,D,E,'InputDelay',0.7,'StateUnit','kg')
%   also sets the input delay and the state unit. Type "properties(ss)"
%   for a complete list of model properties.
%
%   You can create arrays of DSS models by specifying ND arrays for 
%   A,B,C,D,E. See help for SS for more details.
%
%   DSS models may be improper when the E matrix is rank deficient.
%   When SYS is proper, you can eliminate the algebraic variables and
%   compute an explicit realization (E=I) using SYS = SS(SYS,'explicit')
%   or [A,B,C,D] = SSDATA(SYS).
%
%   See also SS, DSSDATA, SSDATA, DYNAMICSYSTEM/ISPROPER.

%   Author(s): P. Gahinet, 4-1-96
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.14.4.7 $  $Date: 2010/03/31 18:12:48 $
ni = nargin;

% Dissect input list
DoubleInputs = 0;
while DoubleInputs < ni,
   arg = varargin{DoubleInputs+1};
   if isnumeric(arg) || iscell(arg)
      DoubleInputs = DoubleInputs+1;
   else
      break;
   end
end

% error check
if (DoubleInputs<5) || (DoubleInputs>6)
    ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','dss','dss')
else
   try
   sys = ss(varargin{[1:4,6:ni]},'e',varargin{5});
   catch E
      throw(E)
   end
end

