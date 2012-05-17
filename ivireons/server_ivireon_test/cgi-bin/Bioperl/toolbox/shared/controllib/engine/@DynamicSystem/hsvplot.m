function [varargout] = hsvplot(varargin)
%HSVPLOT  Plots the Hankel singular values of an LTI model.
%
%   HSVPLOT(SYS) plots the Hankel singular values of the LTI 
%   model SYS.  See HSVD for details on the meaning and purpose 
%   of Hankel singular values.  The Hankel singular values for 
%   the stable and unstable modes of SYS are shown in blue and 
%   red, respectively.
%
%   HSVPLOT(AX,SYS,...) attaches the plot to the axes AX.
%
%   HSVPLOT(..., PLOTOPTIONS) plots the Hankel singular value plot with the
%   options specified in PLOTOPTIONS. See HSVOPTIONS for more details. 
%
%   H = HSVPLOT(...) returns the handle H to the Hankel singular 
%   value plot. You can use this handle to customize the plot 
%   with the GETOPTIONS and SETOPTIONS commands. See HSVOPTIONS
%   for a list of available plot options.
%
%   Example:
%      sys = rss(20);
%      h = hsvplot(sys);
%      % Switch to log scale and modify Offset parameter
%      setoptions(h,'Yscale','log','Offset',0.3)
%
%   See also LTI/HSVD, HSVOPTIONS, WRFC/GETOPTIONS, WRFC/SETOPTIONS.

%	Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:53 $
no = nargout;

% Check for axes argument
if nargin>0 && ishghandle(varargin{1})
   ax = varargin{1};
   varargin(1) = [];
else
   ax = -1;
end

% Get system
sys = varargin{1};

% Validate data and read options
D = getPrivateData(sys);
if ~isscalar(D)
    ctrlMsgUtils.error('Control:general:RequiresSingleModel','hsvplot')
elseif any(iosize(D)==0)
    % System without input or output
    ctrlMsgUtils.error('Control:transformation:NotSupportedNoInputsorOutputs','hsvplot')
end

% RE: OPTIONS is an instance of HSVPlotOptions class
% REVISIT: Need to merge plotopts.HSVPlotOptions and ltioptions.hsvd
if length(varargin)>1 && isa(varargin{2},'plotopts.HSVPlotOptions')
   Options = varargin{2};
   HSVDOptions = hsvdOptions('AbsTol',Options.AbsTol,'RelTol',Options.RelTol,'Offset',Options.Offset);
else
   if length(varargin)>1 && isa(varargin{2},'ltioptions.hsvd')
      HSVDOptions = varargin{2};
   else
      try
         % PV pairs
         HSVDOptions = hsvdOptions(varargin{2:end});
      catch E
         % Replace hsvd with hsvplot
         error(E.identifier,strrep(E.message,'hsvd','hsvplot'))
      end
   end
   Options = plotopts.HSVPlotOptions;
   Options.AbsTol = HSVDOptions.AbsTol;
   Options.RelTol = HSVDOptions.RelTol;
   Options.Offset = HSVDOptions.Offset;
end

% Convert to state space
try
   D = ss(D);
catch %#ok<CTCH>
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','hsvplot',class(sys))
end

% Compute HSV (needed to check computability)
try
   g = hsvd(D,HSVDOptions);
catch E
   % Replace hsvd with hsvplot
   msg = ltipack.utStripErrorHeader(E.message);
   error(E.identifier,strrep(msg,'hsvd','hsvplot'))
end


% Create plot (visibility ='off')
if ~ishghandle(ax,'axes')
   % Default to GCA
   % Call gca after argument parsing to prevent blank axis from appearing
   % if syntax error occurs
   ax = gca; %
end
try
   h = ltiplot(ax,'hsv',[],[],Options,cstprefs.tbxprefs);
catch E
   throw(E)
end

% Add HSV "response"
r = h.addresponse(1,1,1);
% Note: Use ssdata object to avoid additional conversion to SS in localComputeData
r.DataFcn = {@localComputeData r h D};
r.Data.HSV  = g;

% Make plot visible
h.Visible = 'on';
legend(ax,'show')  % Legend on by default

% Add menu
h.addHSVMenu('yscale');
h.AxesGrid.addMenu('grid');
h.addMenu('fullview');

% Add properties menu
if usejava('MWT')
   h.addMenu('properties','Separator','on');
end

% Return handle if requested
if no>0
   varargout = {h};
end


%---------------------- Local Functions -------------------------

function localComputeData(r,h,D)
% Recomputes data
if isempty(r.Data.HSV)
   opts = h.Options;  
   r.Data.HSV = hsvd(D,hsvdOptions('AbsTol',opts.AbsTol,'RelTol',opts.RelTol,'Offset',opts.Offset));
end
