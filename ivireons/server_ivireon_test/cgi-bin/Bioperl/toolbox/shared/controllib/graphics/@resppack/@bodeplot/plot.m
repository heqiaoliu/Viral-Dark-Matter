function r = plot(this,w,varargin)
%PLOT  Adds data to a bode plot.
%
%   R = PLOT(BODEPLOT,W,M,P) adds the frequency response data (W,M,P) to  
%   the Bode plot BODEPLOT.  W is the frequency vector, and M and P are
%   the magnitude and phase arrays (the size of their first dimension
%   must match the number of frequencies). The added response is drawn 
%   immediately.
%
%   R = PLOT(BODEPLOT,W,H) specifies the complex frequency response H
%   rather than the magnitude and phase data.  
%
%   R = PLOT(BODEPLOT,W,M,P,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @magphasedata class for a list
%   of valid properties.
%
%   R = PLOT(BODEPLOT,...,'nodraw') defers drawing.  An explicit call to
%   DRAW is then required to show the new response.  This option is useful 
%   to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:17 $

ni = nargin;
if ni<3
    ctrlMsgUtils.error('Controllib:general:ThreeOrMoreInputsRequired', ...
        'resppack.bodeplot/plot','resppack.bodeplot/plot');
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
% Frequency
if ~isreal(w)
    ctrlMsgUtils.error('Controllib:plots:Plot1','resppack.bodeplot/plot')
end
w = w(:);
nf = length(w);
if ni==3 | ischar(varargin{2})
   % Complex frequency response
   h = varargin{1};
   varargin = varargin(2:end);
   if prod(size(h))==nf
      h = h(:);
   end
   mag = abs(h);
   phase = unwrap(atan2(imag(h),real(h)),[],1);
else
   mag = varargin{1};
   phase = varargin{2};
   varargin = varargin(3:end);
   if prod(size(mag))==nf
      mag = mag(:);
      phase = phase(:);
   end
end
% Size checking
if size(mag,1)~=nf & size(mag,3)==nf
   % Accept frequency-last format
   mag = permute(mag,[3 1 2]);
   phase = permute(phase,[3 1 2]);
end
if isempty(phase)
   phase = reshape(phase,[nf 0 0]);
end
[nf2,ny,nu] = size(mag);
[nf3,ny2,nu2] = size(phase);
if nf2~=nf | nf3~=nf
    ctrlMsgUtils.error('Controllib:plots:Plot2','plot(BODEPLOT,W,M,...)','W','M')
elseif ny2>0 & nu2>0 & (ny2~=ny | nu2~=nu)
        ctrlMsgUtils.error('Controllib:plots:Plot2','plot(BODEPLOT,W,M,P,...)','M','P')
elseif ~isreal(mag) 
    ctrlMsgUtils.error('Controllib:plots:Plot3','plot(BODEPLOT,W,M,P,...)','M')
elseif ~isreal(phase)
    ctrlMsgUtils.error('Controllib:plots:Plot3','plot(BODEPLOT,W,M,P,...)','P')
end
   
% Create new response
try
   r = this.addresponse(1:ny,1:nu,1);
catch ME
   throw(ME)
end

% Store data and set properties
r.Data.Frequency = w;
r.Data.Magnitude = mag;
r.Data.Phase = phase;
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