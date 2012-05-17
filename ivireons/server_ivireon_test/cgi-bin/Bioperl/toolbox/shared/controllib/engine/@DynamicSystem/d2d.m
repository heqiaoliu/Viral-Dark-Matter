function sys = d2d(sys,Ts,varargin)
%D2D  Resamples discrete-time dynamic system.
%
%   SYS = D2D(SYS,TS,METHOD) resamples the discrete-time dynamic system SYS
%   to the new sampling time TS. The string METHOD selects the resampling 
%   method among the following:
%      'zoh'       Zero-order hold on the inputs
%      'tustin'    Bilinear (Tustin) approximation
%   The default is 'zoh' when METHOD is omitted.
%
%   D2D(SYS,TS,OPTIONS) gives access to additional resampling options. Use 
%   D2DOPTIONS to create and configure the option set OPTIONS. For example, 
%   you can specify a prewarping frequency for the Tustin method by:
%      opt = d2dOptions('Method','tustin','PrewarpFrequency',0.5);
%      sys = d2d(sys,0.1,opt);
%
%   See also D2DOPTIONS, D2C, C2D, DYNAMICSYSTEM/UPSAMPLE, DYNAMICSYSTEM.

%	Andrew C. W. Grace 2-20-91, P. Gahinet 8-28-96
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:36 $
ni = nargin;
error(nargchk(2,4,ni));
if isempty(Ts) && ni==3
   % Trap 4.0 syntax D2D(SYS,[],Nd) where Nd = input delays
   Nd = varargin{1};
   if ~isnumeric(Nd) || any(abs(Nd-round(Nd))>1e3*eps*abs(Nd)),
      ctrlMsgUtils.error('Control:transformation:d2d01')
   elseif ~isequal(size(Nd),[1 1]) && length(Nd)~=size(sys,2),
      ctrlMsgUtils.error('Control:transformation:d2d01')
   end
   set(sys,'inputdelay',round(Nd));
   % Call DELAY2Z
   sys = delay2z(sys);
   return
end

% Check original and target sampling time
if ~isdt(sys)
   ctrlMsgUtils.error('Control:transformation:FirstArgDiscreteModel','d2d')
elseif ~(isnumeric(Ts) && isscalar(Ts) && Ts>0)
   ctrlMsgUtils.error('Control:transformation:d2d06')
end

% Options
if ni<3 || isempty(varargin{1})
   % Create default options
   options = d2dOptions;
elseif isa(varargin{1},'ltioptions.d2d')
   options = varargin{1};
elseif ischar(varargin{1})
   options = d2dOptions;
   % Backward compatibility (<R2010a): Map old syntax to d2dOptions
   try
      if strncmpi(varargin{1},'prewarp',length(varargin{1}))
         if ni<4
            ctrlMsgUtils.error('Control:transformation:d2d02','d2d')
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
   ctrlMsgUtils.error('Control:transformation:d2d10')
end

% Convert model
% REVISIT: Written for single rate system as is
Ts = double(Ts);
Ts0 = getTs_(sys);
if Ts0<0,
   % Unspecified sample time
   ctrlMsgUtils.error('Control:transformation:d2d03')
elseif strcmpi(options.Method,'tustin') && options.PrewarpFrequency>=pi/max(Ts,Ts0)
   ctrlMsgUtils.error('Control:transformation:d2d05')
end
try
   sys = d2d_(sys,Ts,options);
catch E
   ltipack.throw(E,'command','d2d',class(sys))
end

% Clear notes, userdata, etc
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
