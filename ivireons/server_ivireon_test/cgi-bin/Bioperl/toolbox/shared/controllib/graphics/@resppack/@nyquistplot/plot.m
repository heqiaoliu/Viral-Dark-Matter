function r = plot(this,w,h,varargin)
%PLOT  Adds data to a bode plot.
%
%   R = PLOT(NYQPLOT,W,H) adds the frequency response data (W,H) to  
%   the Nyquist plot NYQPLOT.  W is the frequency vector, and H is
%   the complex frequency response (the size of its first dimension
%   must match the number of frequencies). The added response is drawn 
%   immediately.
%
%   R = PLOT(NYQPLOT,W,H,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @freqdata class for a list
%   of valid properties.
%
%   R = PLOT(NYQPLOT,...,'nodraw') defers drawing.  An explicit call to
%   DRAW is then required to show the new response.  This option is useful 
%   to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:28 $

ni = nargin;
if ni<3
    ctrlMsgUtils.error('Controllib:general:ThreeOrMoreInputsRequired', ...
        'resppack.nyquistplot/plot','resppack.nyquistplot/plot');
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
% Frequency
if ~isreal(w) 
    ctrlMsgUtils.error('Controllib:plots:Plot1','resppack.nyquistplot/plot')
elseif ~isnumeric(h)
    ctrlMsgUtils.error('Controllib:plots:Plot6','resppack.nyquistplot/plot')
end
w = w(:);
nf = length(w);
% Response
if prod(size(h))==nf
   h = h(:);
end
% Size checking
if size(h,1)~=nf & size(h,3)==nf
   % Accept frequency-last format
   h = permute(h,[3 1 2]);
end
[nf2,ny,nu] = size(h);
if nf2~=nf
    ctrlMsgUtils.error('Controllib:plots:Plot2','plot(NYQUISTPLOT,W,H,...)','W','H')
end
   
% Create new response
try
   r = this.addresponse(1:ny,1:nu,1);
catch ME
   throw(ME)
end

% Store data and set properties
r.Data.Frequency = w;
r.Data.Response = h;
if nf>0
   r.Data.Focus = [w(1) w(end)];
end
if length(varargin)
   set(r.Data,varargin{:})
end

% Draw new response
if DrawFlag
   draw(r)
end