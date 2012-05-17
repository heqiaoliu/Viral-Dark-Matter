function h0 = iopzplot(varargin)
%IOPZPLOT  Plots poles and zeros for each I/O pair of an LTI model.
%
%   IOPZPLOT, an extension of IOPZMAP, provides a command line interface
%   for customizing the plot appearance.
%
%   IOPZPLOT(SYS) computes and plots the poles and zeros of each input/output  
%   pair of the LTI model SYS.  The poles are plotted as x's and the zeros are 
%   plotted as o's.  
%
%   IOPZPLOT(SYS1,SYS2,...) shows the poles and zeros of multiple LTI models 
%   SYS1,SYS2,... on a single plot.  You can specify distinctive colors for 
%   each model, as in  iopzplot(sys1,'r',sys2,'y',sys3,'g')
%
%   IOPZPLOT(AX,...) plots into the axes with handle AX.
%
%   IOPZPLOT(..., PLOTOPTIONS) plots the poles and zeros with the options 
%   specified in PLOTOPTIONS. See PZOPTIONS for more detail.
%
%   H = IOPZPLOT(...) returns the handle to the poles and zero plot. 
%   You can use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See PZOPTIONS for a list of available plot 
%   options.
%   
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of LTI models, IOPZPLOT plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   Example:
%       sys = rss(3,2,2);
%       h = iopzplot(sys);
%       % View all input-output pairs on a single axes
%       setoptions(h,'IOGrouping','all')
%
%   See also LTI/IOPZMAP, LTI/PZPLOT, LTI/RLOCUSPLOT, PZOPTIONS, 
%   WRFC/SETOPTIONS, WRFC/GETOPTIONS.
 
%  Kamesh Subbarao 10-29-2001
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:01 $

% Parse input list

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

% Derive plot I/O size
[InputName,OutputName,EmptySys] = mrgios(sysList.System);
if any(EmptySys)
   ctrlMsgUtils.warning('Control:analysis:PlotEmptyModel')
end

% Create plot
if isempty(ax)
    ax = gca;
end
h = ltiplot(ax,'iopzmap',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);

% Create responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      % Link each response to system source
      src = resppack.ltisource(sysInfo.System, 'Name', sysInfo.Name);
      r = h.addresponse(src);
      r.DataFcn = {'pzmap' src r 'io'};
      % Styles and preferences
      initsysresp(r,'pzmap',h.Options,sysInfo.Style)
   end
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
