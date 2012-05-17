function sysOut = ss(varargin)
   %SS  Constructs state-space model or converts model to state space.
   %
   %  Construction:
   %    SYS = SS(A,B,C,D) creates an object SYS of class @ss representing 
   %    the continuous-time state-space model
   %         dx/dt = Ax(t) + Bu(t)
   %          y(t) = Cx(t) + Du(t)
   %    You can set D=0 to mean the zero matrix of appropriate dimensions.
   %    If one or more of the matrices A,B,C,D have uncertainty, SS returns
   %    an uncertain state-space (USS) model (Robust Control Toolbox only).
   %
   %    SYS = SS(A,B,C,D,Ts) creates a discrete-time state-space model with
   %    sampling time Ts (set Ts=-1 if the sampling time is undetermined).
   %
   %    SYS = SS creates an empty SS object.
   %    SYS = SS(D) specifies a static gain matrix D.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = ss(-1,2,1,0,'InputDelay',0.7,'StateName','position')
   %    also sets the input delay and the state name. Type "properties(ss)" 
   %    for a complete list of model properties, and type 
   %       help ss.<PropertyName>
   %    for help on a particular property. For example, "help ss.StateName" 
   %    provides information about the "StateName" property.
   %
   %  Arrays of state-space models:
   %    You can create arrays of state-space models by using ND arrays for
   %    A,B,C,D. The first two dimensions of A,B,C,D define the number of 
   %    states, inputs, and outputs, while the remaining dimensions specify 
   %    the array sizes. For example,
   %       sys = ss(rand(2,2,3,4),[2;1],[1 1],0)
   %    creates a 3x4 array of SISO state-space models. You can also use
   %    indexed assignment and STACK to build SS arrays:
   %       sys = ss(zeros(1,1,2))     % create 2x1 array of SISO models
   %       sys(:,:,1) = rss(2)        % assign 1st model
   %       sys(:,:,2) = ss(-1)        % assign 2nd model
   %       sys = stack(1,sys,rss(5))  % add 3rd model to array
   %
   %  Conversion:
   %    SYS = SS(SYS) converts any dynamic system SYS to state space by 
   %    computing a state-space realization of SYS. The resulting SYS is 
   %    of class @ss.
   %
   %    SYS = SS(SYS,'min') computes a minimal realization of SYS.
   %
   %    SYS = SS(SYS,'explicit') computes an explicit realization (E=I) of SYS.
   %    An error is thrown if SYS is improper.
   %
   %    See also DSS, DELAYSS, RSS, DRSS, SSDATA, TF, ZPK, FRD, DYNAMICSYSTEM.

%   Author(s): P. Gahinet, 5-1-96
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:04 $
try
   ni = nargin;
   [ConstructFlag,InputList] = lti.parseConvertFcnInputs('ss',varargin);
   if ConstructFlag
      % SS(a,b,c,d,SSSYS): Try again with system replaced by struct
      sysOut = ss(InputList{:});
   elseif ni>2 || (ni==2 && ~ischar(varargin{2}))
      % Invalid syntax
      ctrlMsgUtils.error('Control:transformation:InvalidConversionSyntax','ss','ss')
   else
      sys = InputList{1};
      if isa(sys,'FRDModel')
         ctrlMsgUtils.error('Control:transformation:ss1',class(sys))
      elseif ni==1
         sysOut = copyMetaData(sys,ss_(sys));
      else
         optflag = ltipack.matchKey(InputList{2},{'minimal','explicit'});
         if isempty(optflag)
            ctrlMsgUtils.error('Control:transformation:ss3')
         end
         sysOut = copyMetaData(sys,ss_(sys,optflag));
      end
   end
catch E
   throw(E)
end
