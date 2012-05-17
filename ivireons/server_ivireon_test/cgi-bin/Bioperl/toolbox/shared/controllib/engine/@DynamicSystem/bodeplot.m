function h0 = bodeplot(varargin)
%BODEPLOT Bode response plot of LTI models.
%
%   BODEPLOT, an extension of BODE, provides a command line interface for   
%   customizing the plot appearance.
%
%   BODEPLOT(SYS) draws the Bode plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range and
%   number of points are chosen automatically.
%
%   BODEPLOT(SYS1,SYS2,...) graphs the Bode response of multiple LTI
%   models SYS1,SYS2,... on a single plot. You can specify a color, 
%   line style, and marker for each model, as in  
%      bodeplot(sys1,'r',sys2,'y--',sys3,'gx').
%
%   BODEPLOT(AX,...) plots into the axes with handle AX.
%
%   BODEPLOT(..., PLOTOPTIONS) plots the Bode response with the options
%   specified in PLOTOPTIONS. See BODEOPTIONS for more details. 
%
%   BODEPLOT(SYS,W) draws the Bode plot for frequencies specified by W.
%   When W = {WMIN,WMAX}, the Bode plot is drawn for frequencies
%   between WMIN and WMAX (in radians/second). When W is a user-supplied 
%   vector W of frequencies, in radian/second, the bode response is drawn
%   for the specified frequencies.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   H = BODEPLOT(...) returns the handle to the Bode plot. You can use 
%   this handle to customize the plot with the GETOPTIONS and SETOPTIONS
%   commands.  See BODEOPTIONS for a list of available plot options.
%
%   Example:
%       sys = rss(5);
%       h = bodeplot(sys);
%       % Change units to Hz and make phase plot invisible
%       setoptions(h,'FreqUnits','Hz','PhaseVisible','off');
%
%   See also BODE, BODEOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%   Authors: P. Gahinet  8-14-96
%   Revised: A. DiVergilio
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:30 $

% Get argument names
for ct = length(varargin):-1:1
   ArgNames(ct,1) = {inputname(ct)};
end

% Parse input list
% Check for axes argument
if ishghandle(varargin{1},'axes')
   ax = varargin{1};
   varargin(1) = [];
   ArgNames(1) = [];
else
   ax = [];
end

try
   [sysList,Extras,OptionsObject] = DynamicSystem.parseRespFcnInputs(varargin,ArgNames);
   [sysList,w] = DynamicSystem.checkBodeInputs(sysList,Extras);
catch ME
   throw(ME)
end

% Derive plot I/O size
[InputName,OutputName,EmptySys] = mrgios(sysList.System);
if any(EmptySys)
   ctrlMsgUtils.warning('Control:analysis:PlotEmptyModel')
end

% Create plot (visibility ='off')
try
   if isempty(ax)
      ax = gca;
   end
   h = ltiplot(ax,'bode',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch ME
   throw(ME)
end

% Set global frequency focus for user-defined range/vector (specifies preferred limits)
if iscell(w)
   h.setfocus([w{:}],'rad/sec')
elseif ~isempty(w)
   % Unique frequencies, to avoid interpolation incompatibility
   % for other calculations. Resolution for G154921
   w = unique(w);
   h.setfocus([w(1) w(end)],'rad/sec')
end

% Create responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      src = resppack.ltisource(sysInfo.System,'Name',sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('bode');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'magphaseresp' src 'bode' r w};
      % Styles and preferences
      initsysresp(r,'bode',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
   h.Visible = 'on';  % new plot created with Visible='off'
else
   draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h,'bode');


if nargout
   h0 = h;
end
