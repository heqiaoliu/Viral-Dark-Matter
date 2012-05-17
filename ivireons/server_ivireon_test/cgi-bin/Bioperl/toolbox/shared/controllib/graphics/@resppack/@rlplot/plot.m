function r = plot(this,Gains,Roots,System,varargin)
%PLOT  Adds data to a root locus plot.
%
%   R = PLOT(RLPLOT,GAINS,ROOTS,SYS) adds the root locus 
%   (GAINS,ROOTS) to the root locus plot RLPLOT.  SYS is
%   the open-loop model. The response is drawn immediately.
%
%   R = PLOT(RLPLOT,GAINS,ROOTS,SYS,'Property1',Value1,...) further  
%   specifies data properties such as sample time. See the @rldata 
%   class for a list of valid properties.
%
%   R = PLOT(RLPLOT,...,'nodraw') defers drawing.  An explicit 
%   call to DRAW is then required to show the new response.  This 
%   option is useful to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:47 $

if nargin<4
   ctrlMsgUtils.error('Controllib:general:FourOrMoreInputsRequired', ...
       'resppack.rlplot/plot','resppack.rlplot/plot');
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
Gains = Gains(:);
ng = length(Gains);
% Roots
[nr,nc] = size(Roots);
if nr~=ng
    if nc==ng
        Roots = Roots.';
    else
        ctrlMsgUtils.error('Controllib:plots:Plot2','plot(RLPLOT,GAINS,ROOTS,...)',...
            'GAINS','ROOTS')
    end
end

% Create new response
try
   r = this.addresponse(1,1,1);
catch ME
   throw(ME)
end

% Store data and set properties
d = r.Data;
d.Gains  = Gains;
d.Roots = Roots;
[d.SystemZero,d.SystemPole,d.SystemGain] = zpkdata(System,'v');
if length(varargin)
   set(d,varargin{:})
end

% Focus
[d.XFocus,d.YFocus] = rloclims(Roots.');

% Draw new response
if DrawFlag
   draw(r)
end