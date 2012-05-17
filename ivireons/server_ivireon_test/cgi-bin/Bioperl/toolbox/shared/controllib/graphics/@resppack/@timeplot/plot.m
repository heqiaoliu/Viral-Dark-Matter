function r = plot(this,t,y,varargin)
%PLOT  Adds data to a response plot.
%
%   R = PLOT(TIMEPLOT,T,Y) adds the response data (T,Y) to the 
%   time plot TIMEPLOT.  The response is drawn immediately.
%
%   R = PLOT(TIMEPLOT,T,Y,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @timedata class for a list of 
%   valid properties.
%
%   R = PLOT(TIMEPLOT,T,Y,...,'nodraw') defers drawing.  An 
%   explicit call to DRAW is then required to show the new response. 
%   This option is useful to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:24 $

if nargin<3
    ctrlMsgUtils.error('Controllib:general:ThreeOrMoreInputsRequired', ...
        'resppack.timeplot/plot','resppack.timeplot/plot');
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
% Time vector
if ~isreal(t) 
    ctrlMsgUtils.error('Controllib:plots:Plot3','plot(TIMEPLOT,T,Y,...)','T')
elseif ~isreal(y)
    ctrlMsgUtils.error('Controllib:plots:Plot3','plot(TIMEPLOT,T,Y,...)','Y')
end
t = t(:);
ns = length(t);
% Amplitude
if prod(size(y))==ns
   y = y(:);
end
[ns2,ny,nu] = size(y);
if ns2~=ns
    ctrlMsgUtils.error('Controllib:plots:Plot2','plot(TIMEPLOT,T,Y,...)','T','Y')
end

% Create new response
try
   r = this.addresponse(1:ny,1:nu,1);
catch ME
   throw(ME)
end

% Store data and set properties
r.Data.Time = t;
r.Data.Amplitude = y;
if ns>0
   r.Data.Focus = [t(1) t(end)];
end
if length(varargin)
   set(r.Data,varargin{:})
end

% Draw new response
if DrawFlag
   draw(r)
end