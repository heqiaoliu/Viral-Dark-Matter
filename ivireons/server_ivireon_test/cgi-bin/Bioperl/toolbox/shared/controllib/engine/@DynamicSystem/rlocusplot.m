function h0 = rlocusplot(varargin)
%RLOCUSPLOT  Evans root locus.
%
%   RLOCUSPLOT, an extension of RLOCUS, provides a command line interface
%   for customizing the plot appearance.
%
%   RLOCUSPLOT(SYS) computes and plots the root locus of the single-input,
%   single-output LTI model SYS.  The root locus plot is used to 
%   analyze the negative feedback loop
%
%                     +-----+
%         ---->O----->| SYS |----+---->
%             -|      +-----+    |
%              |                 |
%              |       +---+     |
%              +-------| K |<----+
%                      +---+
%
%   and shows the trajectories of the closed-loop poles when the feedback 
%   gain K varies from 0 to Inf.  RLOCUS automatically generates a set of 
%   positive gain values that produce a smooth plot.  
%
%   RLOCUSPLOT(SYS,K) uses a user-specified vector K of gain values.
%
%   RLOCUSPLOT(SYS1,SYS2,...) draws the root loci of multiple LTI models  
%   SYS1, SYS2,... on a single plot.  You can specify a color, line style, 
%   and marker for each model, as in  
%      rlocusplot(sys1,'r',sys2,'y:',sys3,'gx').
%
%   RLOCUSPLOT(AX,...) plots into the axes with handle AX.
%
%   RLOCUSPLOT(..., PLOTOPTIONS) plots root locus with the options 
%   specified in PLOTOPTIONS. See PZOPTIONS for more detail.
%
%   H = RLOCUSPLOT(...) returns the handle to the root locus plot. 
%   You can use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See PZOPTIONS for a list of available plot 
%   options.
%   
%   Example:
%       sys = rss(3);
%       h = rlocusplot(sys);
%       p = getoptions(h); % get options for plot
%       p.Title.String = 'My Title'; % change title in options
%       setoptions(h,p); % apply options to plot  
%
%   See also RLOCUS, PZOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 7-8-89, 6-21-92 
%   Revised P. Gahinet 7-96
%   Revised A. DiVergilio 6-00
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:31 $

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
   [sysList,GainVector] = DynamicSystem.checkRootLocusInputs(sysList,Extras);
catch E
   throw(E)
end

% Create plot (visibility ='off')
try
   if isempty(ax)
      ax = gca;
   end
   h = ltiplot(ax,'rlocus',[],[],OptionsObject,cstprefs.tbxprefs);
catch ME
   throw(ME)
end

% Create responses
GainVector = unique(GainVector);
nsys = length(sysList);
for ct=1:nsys
   sysInfo = sysList(ct);
   src = resppack.ltisource(sysInfo.System,'Name',sysInfo.Name);
   r = h.addresponse(src);
   r.DataFcn = {'rlocus' src r GainVector};
   % Styles and preferences
   initsysresp(r,'rlocus',h.Options,sysInfo.Style)
end

% Trap case of single model with unspecified color
% (use different color for each branch in this case)
if nsys==1 && numsys(sysList.System)==1 && LocalNoColor(sysList.Style)
   r.View.BranchColorList = ...
      {[0 0 1],[0 .5 0],[1 0 0],[0 .75 .75],[.75 0 .75],[.75 .75 0],[.25 .25 .25]};
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
   h.Visible = 'on';  % new plot created with Visible='off'
else
   draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h,'rlocus');

if nargout
   h0 = h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function boo = LocalNoColor(PlotStyle)
if ~isempty(PlotStyle)
   [~,C,M] = colstyle(PlotStyle); %#ok<NASGU>
   boo = isempty(C);
else
   boo = true;
end
