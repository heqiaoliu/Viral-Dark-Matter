function [g,varargout] = hsvd(sys,varargin)
%HSVD  Computes the Hankel singular values of linear systems.
%
%   HSV = HSVD(SYS) computes the Hankel singular values HSV of the linear 
%   system SYS. In state coordinates that equalize the input-to-state 
%   and state-to-output energy transfers, the Hankel singular values 
%   measure the contribution of each state to the input/output behavior.  
%   Hankel singular values are to model order what singular values are 
%   to matrix rank. In particular, small Hankel singular values flag  
%   states that can be discarded to simplify the model (see BALRED).
% 
%   For models with unstable poles, HSVD only computes the Hankel singular 
%   values of the stable part and entries of HSV corresponding to unstable 
%   modes are set to Inf. Use
%      HSV = HSVD(SYS,OPTIONS)
%   to specify additional options for the stable/unstable decomposition, 
%   see HSVDOPTIONS for details.
%
%   HSVD(SYS) displays a plot of the Hankel singular values.
%
%   [HSV,BALDATA] = HSVD(SYS) returns additional data to speed up model 
%   order reduction with BALRED. For example
%       sys = rss(20);  % 20-th order model
%       [hsv,baldata] = hsvd(sys);
%       rsys = balred(sys,8:10,baldata);
%       bode(sys,'b',rsys,'r--')
%   computes three approximations of sys of orders 8, 9, 10.
%
%   See also HSVDOPTIONS, HSVPLOT, BALRED, BALREAL.

%	Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:52 $
ni = nargin-1;
no = nargout;
if numsys(sys)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','hsvd')
elseif any(iosize(sys)==0)
   % System without input or output
   ctrlMsgUtils.error('Control:transformation:NotSupportedNoInputsorOutputs','hsvd')
end

if no>0
   % Convert to numerical state space
   try
      sys = ss(sys);
   catch %#ok<CTCH>
      ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','hsvd',class(sys))
   end
      
   % Read options
   try
      if ni>0 && isa(varargin{1},'ltioptions.hsvd')
         Options = varargin{1};
      else
         Options = hsvdOptions(varargin{:});
      end
      [g,varargout{1:no-1}] = hsvd_(sys,Options);
   catch E
      throw(E)
   end
else
   % HSV response plot
   try
      hsvplot(sys,varargin{:});
   catch E
      % Replace hsvplot with hsvd
      error(E.identifier,strrep(E.message,'hsvplot','hsvd'))
   end
end

