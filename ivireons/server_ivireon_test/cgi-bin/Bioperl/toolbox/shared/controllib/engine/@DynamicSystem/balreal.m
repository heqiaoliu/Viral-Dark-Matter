function [sysb,g,varargout] = balreal(sys,varargin)
%BALREAL  Gramian-based balancing of state-space realizations.
%
%   [SYSB,G] = BALREAL(SYS) computes a balanced state-space realization for 
%   the stable portion of the linear system SYS. For stable systems, SYSB 
%   is an equivalent realization for which the controllability and 
%   observability Gramians are equal and diagonal, their diagonal entries 
%   forming the vector G of Hankel singular values. Small entries in G  
%   indicate states that can be removed to simplify the model (use MODRED 
%   to reduce the model order).
% 
%   If SYS has unstable poles, its stable part is isolated, balanced, and 
%   added back to the unstable part to form SYSB. The entries of G 
%   corresponding to unstable modes are set to Inf. Use the syntax
%      [SYSB,G] = BALREAL(SYS,OPTIONS)
%   to specify additional options for the stable/unstable decomposition.
%   See HSVDOPTIONS to create and configure the option set OPTIONS.
%
%   [SYSB,G,T,Ti] = BALREAL(SYS,...) also returns the balancing state 
%   transformation x_b = T*x used to transform SYS into SYSB, as well as 
%   the inverse transformation x = Ti*x_b.
%
%   See also HSVDOPTIONS, GRAM, MODRED, PRESCALE, SS.

%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:25 $
ni = nargin-1;
no = nargout-2;
if numsys(sys)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','balreal')
elseif any(iosize(sys)==0)
   % System without input or output
   ctrlMsgUtils.error('Control:transformation:NotSupportedNoInputsorOutputs','balreal')
elseif no>0 && ~isa(sys,'StateSpaceModel')
   % Set T=Ti=[] for non-empty state-space models
   no = 0;  varargout = cell(1,2);
end

% Convert to numerical state space
try
   sys = ss(sys);
catch %#ok<CTCH>
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','balreal',class(sys))
end

% Options
if ni>0 && isa(varargin{1},'ltioptions.hsvd')
   Options = varargin{1};
else
   if ni>0 && isnumeric(varargin{1})
      % RE: Pre-R14sp2 syntax: sysb = balreal(sys,condt)
      varargin = {'RelTol' , eps * varargin{1}};
   end
   try
      Options = hsvdOptions(varargin{:});
   catch ME
      throw(ME)
   end
end

% Call state-space implementation
try
   [sysb,g,varargout{1:no}] = balreal_(sys,Options);
catch E
   ltipack.throw(E,'command','balreal',class(sys))
end
