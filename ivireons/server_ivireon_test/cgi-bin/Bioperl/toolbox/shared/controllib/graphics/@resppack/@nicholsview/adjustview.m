function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'prelim') hides HG objects that might interfer with 
%  limit picking.
%
%  ADJUSTVIEW(VIEW,DATA,'postlimit') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:08 $

switch Event
   case 'prelim'
      % Frequency focus
      Curves = View.Curves;
      if Data.SoftFocus
         % Quasi-integrator/derivator or pure gain: Limit visible mag range
         for ct = 1:numel(Curves)
            LocalShowMagRange(Curves(ct),Data.Magnitude(:,ct))
         end
      else
         % Other cases: Show frequency range of interest
         InFocus = (Data.Frequency >= Data.Focus(1) & ...
            Data.Frequency <= Data.Focus(2));
         LocalShowFreqRange(Curves, InFocus)
      end   
      
   case 'postlim'
      % Restore nichols curves to their full extent
      draw(View, Data)
end


% --------------------------------------------------------------------------- %
% Local Functions
% --------------------------------------------------------------------------- %
function LocalShowFreqRange(Curves, Include)
% Clips response to a given frequency range
npts = length(Include);
idx = find(Include);
for ct = 1:numel(Curves)
   h = Curves(ct);
   ydata = get(h, 'YData');
   if length(ydata) == npts  % watch for exceptions (ydata=NaN)
      xdata = get(h, 'XData');
      set(double(h),'XData', xdata(idx), 'YData', ydata(idx))
   end
end


function LocalShowMagRange(h, mag)
% Clips response to show only portion in [-30,30] dB mag range
% nichols(tf(1,[1 0 0 eps^2]))
% nichols(tf(1e-10,[1 1e-10]))
% nichols(tf(1e5,[1 1e-10]))
npts = length(mag);
xdata = get(h, 'XData');
ydata = get(h, 'YData');
if length(ydata)~=npts || npts<2
   return
end
% Eliminate frequencies with infinite gain
isZero = (mag==0);
mag(isZero) = -inf;
mag(~isZero) = log10(mag(~isZero));

% Determine mag range [GMIN,GMAX] to focus on 
gmin = min(mag);
gmax = max(mag);
if gmin>1,
   gmax = gmin + 2;
elseif gmax<-1
   gmin = gmax - 2;
else
   gmin = max(-1.5,gmin);
   gmax = min(1.5,gmax);
end

% Find points where response enters and leaves this range
magF = mag(find(isfinite(mag),1));  % first finite
if magF<gmin
   idxs = find(mag>=gmin,1)-1;  gs = gmin;
elseif magF>gmax
   idxs = find(mag<=gmax,1)-1;  gs = gmax;
else 
   idxs = 1;  gs = NaN;
end
magL = mag(find(isfinite(mag),1,'last'));  % last finite
if magL<gmin
   idxf = find(mag>=gmin,1,'last')+1;  gf = gmin;
elseif magL>gmax
   idxf = find(mag<=gmax,1,'last')+1;  gf = gmax;
else 
   idxf = npts;  gf = NaN;
end
xdata = xdata(idxs:idxf);
ydata = ydata(idxs:idxf);

% Interpolate to find exact crossing (critical when frequency
% grid is very sparse)
if isfinite(gs)
   t = (gs-mag(idxs))/(mag(idxs+1)-mag(idxs));
   xdata(1) = (1-t) * xdata(1) + t * xdata(2);
   ydata(1) = (1-t) * ydata(1) + t * ydata(2);
   mag(idxs) = gs;
end
if isfinite(gf)
   t = (gf-mag(idxf))/(mag(idxf-1)-mag(idxf));
   n = length(xdata);
   xdata(n) = (1-t) * xdata(n) + t * xdata(n-1);
   ydata(n) = (1-t) * ydata(n) + t * ydata(n-1);
end

% Update line data
set(double(h),'XData', xdata, 'YData', ydata)
