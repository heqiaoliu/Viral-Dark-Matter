function h0 = initialplot(varargin)
%INITIALPLOT  Initial condition response of state-space models.
%
%   INITIALPLOT, an extension of INITIAL, provides a command line interface
%   for customizing the plot appearance.
%
%   INITIALPLOT(SYS,X0) plots the undriven response of the state-space 
%   model SYS (created with SS) with initial condition X0 on the 
%   states.  This response is characterized by the equations
%                        .
%     Continuous time:   x = A x ,  y = C x ,  x(0) = x0 
%
%     Discrete time:  x[k+1] = A x[k],  y[k] = C x[k],  x[0] = x0.
%
%   The time range and number of points are chosen automatically.  
%
%   INITIALPLOT(SYS,X0,TFINAL) simulates the time response from t=0 
%   to the final time t=TFINAL.  For discrete-time models with 
%   unspecified sample time, TFINAL should be the number of samples.
%
%   INITIALPLOT(SYS,X0,T) specifies a time vector T to be used for 
%   simulation.  For discrete systems, T should be of the form  
%   0:Ts:Tf where Ts is the sample time.  For continuous-time models,
%   T should be of the form 0:dt:Tf where dt will become the sample
%   time of a discrete approximation of the continuous model.
%
%   INITIALPLOT(SYS1,SYS2,...,X0,T) plots the response of multiple LTI 
%   models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      initialplot(sys1,'r',sys2,'y--',sys3,'gx',x0).
%
%   INITIALPLOT(AX,...) plots into the axes with handle AX.
%
%   INITIALPLOT(..., PLOTOPTIONS) plots the initial condition response 
%   with the options specified in PLOTOPTIONS. See TIMEOPTIONS for 
%   more detail.
%
%   H = INITIALPLOT(...) returns the handle to the initial condition 
%   response plot. You can use this handle to customize the plot with 
%   the GETOPTIONS and SETOPTIONS commands.  See TIMEOPTIONS for a list 
%   of available plot options.
%
%   Example:
%       sys = rss(3);
%       h = initialplot(sys,[1,1,1]);
%       p = getoptions(h); % get options for plot
%       p.Title.String = 'My Title'; % change title in options
%       setoptions(h,p); % apply options to plot
%	
%   See also INITIAL, TIMEOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%	Clay M. Thompson  7-6-90
%	Revised: ACWG 6-21-92
%	Revised: PG 4-25-96
%       Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-02-01
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:59 $

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
   [sysList,t,x0] = DynamicSystem.checkInitialInputs(sysList,Extras);
catch E
   throw(E)
end
if ~isreal(x0)
   % Accept complex x0 with output arguments
   ctrlMsgUtils.error('Control:analysis:initialplot1')
end

% Derive plot I/O size
[InputName,OutputName,EmptySys] = mrgios(sysList.System);
if any(EmptySys)
   ctrlMsgUtils.warning('Control:analysis:PlotEmptyModel')
end

% Create plot
try
   if isempty(ax)
      ax = gca;
   end
   h = ltiplot(ax,'initial',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch E
   throw(E)
end

% Set global time focus for user-defined range/vector (sets preferred X limits)
if length(t) == 1
    h.setfocus([0, t],'sec')
elseif ~isempty(t)
    h.setfocus([t(1) t(end)],'sec')
end

% Create responses
for ct = 1:length(sysList)
   sysInfo = sysList(ct);
   Sizes = size(sysInfo.System);  Sizes(2) = [];
   if all(Sizes>0) % skip empty systems
      src = resppack.ltisource(sysInfo.System, 'Name', sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('initial');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'timeresp' src 'initial' r t};
      r.Context = struct('Type','initial','IC',x0);
      % Styles and preferences
      initsysresp(r,'initial',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
    h.Visible = 'on';  % new plot created with Visible='off'
else
    draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h, 'initial');

if nargout
    h0 = h;
end
