function h0 = pzplot(varargin)
%PZPLOT  Pole-zero map of LTI models.
%
%   PZPLOT, an extension of PZMAP, provides a command line interface for   
%   customizing the plot appearance.
%
%   PZPLOT(SYS) computes the poles and (transmission) zeros of the
%   LTI model SYS and plots them in the complex plane.  The poles 
%   are plotted as x's and the zeros are plotted as o's.  
%
%   PZPLOT(SYS1,SYS2,...) shows the poles and zeros of multiple LTI
%   models SYS1,SYS2,... on a single plot.  You can specify 
%   distinctive colors for each model, as in  
%      pzplot(sys1,'r',sys2,'y',sys3,'g')
%
%   PZPLOT(AX,...) plots into the axes with handle AX.
%
%   PZPLOT(..., PLOTOPTIONS) plots the poles and zeros with the options 
%   specified in PLOTOPTIONS. See PZOPTIONS for more detail.
%
%   H = PZPLOT(...) returns the handle to the poles and zero plot. 
%   You can use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See PZOPTIONS for a list of available plot 
%   options.
%
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of LTI models, PZMAP plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   Example:
%       sys = rss(3,2,2);
%       h = pzplot(sys);
%       p = getoptions(h); % get options for plot
%       p.Title.Color = [1,0,0]; % change title color in options
%       setoptions(h,p); % apply options to plot  
%
%   See also PZMAP, LTI/IOPZPLOT, PZOPTIONS, WRFC/SETOPTIONS, 
%   WRFC/GETOPTIONS.

%	Clay M. Thompson  7-12-90
%	Revised ACWG 6-21-92, AFP 12-1-95, PG 5-10-96, ADV 6-16-00
%          Kamesh Subbarao 10-29-2001
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:27 $

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
   sysList = DynamicSystem.checkPZInputs(sysList,Extras);
catch E
   throw(E)
end

% Create plot
if isempty(ax)
    ax = gca;
end
h = ltiplot(ax,'pzmap',[],[],OptionsObject,cstprefs.tbxprefs);

% Create responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   % Link each response to system source
   src = resppack.ltisource(sysInfo.System, 'Name', sysInfo.Name);
   r = h.addresponse(src);
   r.DataFcn = {'pzmap' src r};
   % Styles and preferences
   initsysresp(r,'pzmap',h.Options,sysInfo.Style)
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
    h.Visible = 'on';  % new plot created with Visible='off'
else
    draw(h)  % hold mode
end

% Right-click menus
m = ltiplotmenu(h, 'pzmap');
lticharmenu(h, m.Characteristics, 'pzmap');

if nargout
    h0 = h;
end
