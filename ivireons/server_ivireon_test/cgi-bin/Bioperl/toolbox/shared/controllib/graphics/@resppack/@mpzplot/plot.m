function r = plot(this,z,p,varargin)
%PLOT  Adds data to a response plot.
%
%   R = PLOT(PZPLOT,Z,P) adds the zero/pole data (Z,P) to the 
%   pole/zero plot PZPLOT.  The response is drawn immediately.
%
%   R = PLOT(PZPLOT,Z,P,'Property1',Value1,...) further specifies 
%   data properties such as sample time. See the @pzdata class for 
%   a list of valid properties.
%
%   R = PLOT(PZPLOT,Z,P,...,'nodraw') defers drawing.  An explicit 
%   call to DRAW is then required to show the new response.  This 
%   option is useful to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:51 $

if nargin<3
    ctrlMsgUtils.error('Controllib:general:ThreeOrMoreInputsRequired', ...
        'resppack.mpzplot/plot','resppack.mpzplot/plot');
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
if ~iscell(z)
   z = {z(:)};
end
if ~iscell(p)
   p = {p(:)};
end
if prod(size(z))>1 | prod(size(p))>1
    ctrlMsgUtils.error('Controllib:plots:Plot5','plot(MPZPLOT,Z,P,...)')
end

% Create new response
try
   r = this.addresponse(1,1,1);
catch ME
   throw(ME)
end

% Store data and set properties
r.Data.Zeros = z;
r.Data.Poles = p;
if length(varargin)
   set(r.Data,varargin{:})
end

% Draw new response
if DrawFlag
   draw(r)
end