function sys = d2c(sys,varargin)
%D2C  Converts discrete-time dynamic system to continuous time.
%
%   SYSC = D2C(SYSD,METHOD) computes a continuous-time model SYSC that 
%   approximates the discrete-time model SYSD. The string METHOD selects 
%   the conversion method among the following:
%      'zoh'       Zero-order hold on the inputs
%      'tustin'    Bilinear (Tustin) approximation
%      'matched'   Matched pole-zero method (for SISO systems only)
%   The default is 'zoh' when METHOD is omitted.
%
%   D2C(SYSD,OPTIONS) gives access to additional conversion options. Use  
%   D2COPTIONS to create and configure the option set OPTIONS. For example, 
%   you can specify a prewarping frequency for the Tustin method by:
%      opt = d2cOptions('Method','tustin','PrewarpFrequency',0.5);
%      sysc = d2c(sysd,opt);
%
%   See also D2COPTIONS, C2D, D2D, DYNAMICSYSTEM.

%   Author(s): Clay M. Thompson, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:35 $
ni = nargin;
error(nargchk(1,3,ni))
Ts = sys.Ts;

% Error checking
if ~isdt(sys)
   ctrlMsgUtils.error('Control:transformation:FirstArgDiscreteModel','d2c')
elseif Ts<0
   % Unspecified sample time
   ctrlMsgUtils.error('Control:transformation:d2c01')
end

% Options
if ni<2 || isempty(varargin{1})
   % Create default options
   options = d2cOptions;
elseif isa(varargin{1},'ltioptions.d2c')
   options = varargin{1};
elseif ischar(varargin{1})
   options = d2cOptions;
   % Backward compatibility (<R2010a): Map old syntax to d2dOptions
   try
      if strncmpi(varargin{1},'prewarp',length(varargin{1}))
         if ni<3
            ctrlMsgUtils.error('Control:transformation:d2c03')
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
   ctrlMsgUtils.error('Control:transformation:d2c12')
end

% Error check prewarp frequency used by 'tustin'
if strcmpi(options.Method,'tustin') && options.PrewarpFrequency>=pi/Ts
    ctrlMsgUtils.error('Control:transformation:d2c09')
end

% Convert
try
   sys = d2c_(sys,options);
catch E
   ltipack.throw(E,'command','d2c',class(sys))
end

% Clear notes, userdata, etc
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
