function [G1,G2,varargout] = stabsep(G,varargin)
%STABSEP  Stable/unstable decomposition of linear systems.
%
%   [GS,GNS] = STABSEP(G) decomposes the linear system G into its stable  
%   and unstable parts:
%      G = GS + GNS
%   GS contains all stable modes that can be separated from the unstable 
%   modes in a numerically stable way, and GNS contains the remaining modes. 
%   GNS is always strictly proper.
%
%   [GS,GNS] = STABSEP(G,OPTIONS) specifies additional options. Use
%   STABSEPOPTIONS to create and configure the option set OPTIONS.
%
%   Example: Compute a stable/unstable decomposition with absolute error no
%   larger than 1e-5 and offset 0.1:
%      h = zpk(1,[-2 -1 1 -0.001],0.1)
%      Options = stabsepOptions('AbsTol',1e-5,'Offset',0.1)
%      [hs,hns] = stabsep(h,Options)
%
%   See also STABSEPOPTIONS, MODSEP, LTI.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:49:41 $
ni = nargin-1;
no = nargout-2;
if numsys(G)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','stabsep')
elseif no>0 && ~isa(G,'StateSpaceModel')
   % Set Tinfo=T=Ti=[] for non-state-space models
   no = 0;  varargout = cell(1,3);
end

% Options
if ni>0 && isa(varargin{1},'ltioptions.StableUnstableDecomposition')
   Options = varargin{1};
else
   if ni>0 && isnumeric(varargin{1})
      % RE: Pre-R14sp2 syntax: [G1,G2,T,Ti] = stabsep(G,condmax,mode,offset)
      varargin{1} = eps * varargin{1}; % mapping CONDMAX to RELTOL
      Opts = {'RelTol','Mode','Offset'};
      idx = find(~cellfun(@isempty,varargin));
      varargin = [Opts(idx) ; varargin(idx)];
   end
   try
      Options = stabsepOptions(varargin{:});
   catch ME
      throw(ME)
   end
end

% Clear notes, userdata, etc
G.Name_ = [];  G.Notes_ = [];  G.UserData = [];

% Perform separation
try
   [G1,G2,varargout{1:no}] = stabsep_(G,Options);
catch E
   ltipack.throw(E,'command','stabsep',class(G))
end
