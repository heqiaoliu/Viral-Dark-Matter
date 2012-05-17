function [sys,varargout] = c2d(sys,Ts,varargin)
%C2D  Converts continuous-time dynamic system to discrete time.
%
%   SYSD = C2D(SYSC,TS,METHOD) computes a discrete-time model SYSD with 
%   sampling time TS that approximates the continuous-time model SYSC.
%   The string METHOD selects the discretization method among the following:
%      'zoh'       Zero-order hold on the inputs
%      'foh'       Linear interpolation of inputs
%      'impulse'   Impulse-invariant discretization
%      'tustin'    Bilinear (Tustin) approximation.
%      'matched'   Matched pole-zero method (for SISO systems only).
%   The default is 'zoh' when METHOD is omitted.
%
%   C2D(SYSC,TS,OPTIONS) gives access to additional discretization options. 
%   Use C2DOPTIONS to create and configure the option set OPTIONS. For 
%   example, you can specify a prewarping frequency for the Tustin method by:
%      opt = c2dOptions('PrewarpFrequency',.5);
%      sysd = c2d(sysc,.1,opt);
%
%   For state-space models without delays,
%      [SYSD,G] = C2D(SYSC,Ts,METHOD)
%   also returns the matrix G mapping the states xc(t) of SYSC to the states 
%   xd[k] of SYSD:
%      xd[k] = G * [xc(k*Ts) ; u[k]]
%   Given some initial condition x0 for SYSC, an equivalent initial condition 
%   for SYSD is
%      xd[0] = G * [x0;u0]
%   where u0 is the initial input value.
%
%   See also C2DOPTIONS, D2C, D2D, DYNAMICSYSTEM.

%   Author(s): Clay M. Thompson, A.Potvin, P. Gahinet
%   Revised: Murad Abu-Khalaf
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:31 $
ni = nargin;
no = nargout;
error(nargchk(2,4,ni))

% Validate sys and Ts
if ~isct_(sys)
   ctrlMsgUtils.error('Control:transformation:c2d03')
elseif ~(isnumeric(Ts) && isscalar(Ts) && Ts>0)
   ctrlMsgUtils.error('Control:transformation:c2d05')
end

if ni<3 || isempty(varargin{1})
   % Create default options
   options = c2dOptions;
elseif isa(varargin{1},'ltioptions.c2d')
   options = varargin{1};
elseif ischar(varargin{1})
   options = c2dOptions;
   % Backward compatibility (<=R2009b): Map old syntax to c2dOptions
   try
      if strncmpi(varargin{1},'prewarp',length(varargin{1}))
         if ni<4
            ctrlMsgUtils.error('Control:transformation:c2d07')
         end
         options.Method = 'tustin';
         options.PrewarpFrequency = varargin{2};
      else
         % Only first character matters in < R2010a syntax
         options.Method = varargin{1}(1);
      end
   catch E
      throw(E);
   end
else
   ctrlMsgUtils.error('Control:transformation:c2d16');
end

% Validate prewarp frequency used by 'tustin'
if strcmpi(options.Method,'tustin') && options.PrewarpFrequency>=pi/Ts
   ctrlMsgUtils.error('Control:transformation:c2d08')
end

% Checks for second output
if no==2
   if strcmp(options.Method,'matched')
      ctrlMsgUtils.error('Control:transformation:c2d09')
   elseif numsys(sys)~=1
      ctrlMsgUtils.error('Control:transformation:ICMappingModelArrays','c2d','c2d')
   end
end

% Convert 
try
   [sys,varargout{1:no-1}] = c2d_(sys,Ts,options);
catch E
   ltipack.throw(E,'command','c2d',class(sys))
end

% Clear notes, userdata, etc
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];

