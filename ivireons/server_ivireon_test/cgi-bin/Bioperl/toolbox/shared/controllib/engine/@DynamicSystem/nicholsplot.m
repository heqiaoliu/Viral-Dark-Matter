function h0 = nicholsplot(varargin)
%NICHOLSPLOT  Nichols frequency response of LTI models.
%
%   NICHOLSPLOT, an extension of NICHOLS, provides a command line interface
%   for customizing the plot appearance.
%
%   NICHOLSPLOT(SYS) draws the Nichols plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range  
%   and number of points are chosen automatically.  See BODE for  
%   details on the notion of frequency in discrete-time.
%
%   NICHOLSPLOT(SYS,{WMIN,WMAX}) draws the Nichols plot for frequencies
%   between WMIN and WMAX (in radian/second).
%
%   NICHOLSPLOT(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the Nichols response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NICHOLSPLOT(SYS1,SYS2,...,W) plots the Nichols plot of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The frequency vector W
%   is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      nicholsplot(sys1,'r',sys2,'y--',sys3,'gx').
%
%   NICHOLSPLOT(AX,...) plots into the axes with handle AX.
%
%   NICHOLSPLOT(..., PLOTOPTIONS) plots the Nichols chart with the options
%   specified in PLOTOPTIONS. See NICHOLSOPTIONS for more details. 
%
%   H = NICHOLSPLOT(...) returns the handle to the Nichols plot. You can 
%   use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See NICHOLSOPTIONS for a list of available plot 
%   options.
%
%   Example:
%       sys = rss(5);
%       h = nicholsplot(sys);
%       % Change units to Hz 
%       setoptions(h,'FreqUnits','Hz');
%
%   See also NICHOLS, NICHOLSOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%   Authors: P. Gahinet, B. Eryilmaz
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:14 $

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

% Nichols plot
% Create plot (visibility ='off')
try
   if isempty(ax)
      ax = gca;
   end
   h = ltiplot(ax,'nichols',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch ME
   throw(ME)
end

if isnumeric(w)
    % Unique frequencies, to avoid interpolation incompatibility
    % for other calculations. Resolution for G154921
    w = unique(w);
end

% Create responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      src = resppack.ltisource(sysInfo.System,'Name',sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('nichols');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'magphaseresp' src 'nichols' r w};
      % Styles and preferences
      initsysresp(r,'nichols',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot, 'replace')
    h.Visible = 'on';  % new plot created with Visible='off'
else
    draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h, 'nichols');

if nargout
    h0 = h;
end
