function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'prelim') hides HG objects that might interfer with 
%  limit picking.
%
%  ADJUSTVIEW(VIEW,DATA,'critical') prepares view for zooming in around the
%  critical point (handled by NYQUISTPLOT:UPDATELIMS)
%
%  ADJUSTVIEW(VIEW,DATA,'postlimit') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:34 $

if ~NormalRefresh
   return
end

switch Event
case 'prelim'
   % Hide arrows
   set(double([View.PosArrows(:);View.NegArrows(:)]),'XData',[],'YData',[])
   % Frequency focus
   PosCurves = View.PosCurves;
   NegCurves = View.NegCurves;
   if Data.SoftFocus
      % Quasi integrator or pure gain: Show only data in small disk centered at (-1,0)
      for ct=1:numel(PosCurves)
         LocalShowCriticalRange([PosCurves(ct),NegCurves(ct)],Data.Response(:,ct))
      end
   else
      % Other cases: show frequency range of interest (plus all data in
      % small disk centered at (-1,0))
      InFocus = (Data.Frequency>=Data.Focus(1) & Data.Frequency<=Data.Focus(2));
      for ct=1:numel(PosCurves)
         LocalShowFreqRange([PosCurves(ct),NegCurves(ct)],InFocus)
      end
   end   
   
case 'critical'
   % Zoom in region around critical point
   % Hide arrows
   set(double([View.PosArrows(:);View.NegArrows(:)]),'XData',[],'YData',[])
   % Hide data outside ball of rho max(4,1.5 x min. distance to (-1,0))
   PosCurves = View.PosCurves;
   NegCurves = View.NegCurves;
   for ct=1:numel(PosCurves)
      gap = 1+Data.Response(:,ct);
      if ~any(diff(gap))
         % Pure gain
         set(double([PosCurves(ct),NegCurves(ct)]),'marker','*')
      else
         distcp = abs(gap);
         LocalShowFreqRange([PosCurves(ct),NegCurves(ct)],(distcp < max(4,1.5*min(distcp))))
      end
   end
   
case 'postlim'
   % Restore nyquist curves to their full extent
   draw(View,Data)
   % Position and adjust arrows
   drawarrow(View)
   
end

%---------------------------- Local Functions --------------------

function LocalShowFreqRange(Curves, Include)
% Clips response to a given frequency range
npts = length(Include);
for ct = 1:numel(Curves)
   h = Curves(ct);
   ydata = get(h, 'YData');
   if length(ydata) == npts  % watch for exceptions (ydata=NaN)
      xdata = get(h, 'XData');
      % Using freq. focus only can unduly squeeze y limits: 
      % nyquist(tf([1e-2 1],[1 1e-5]))
      idx = find(Include | abs(xdata(:))+abs(ydata(:))<10);
      set(double(h),'XData', xdata(idx), 'YData', ydata(idx))
   end
end


function LocalShowCriticalRange(h,resp)
% Clips response to a given disk centered at (-1,0)
gap = 1+resp;
if ~any(diff(gap))
   % Pure gain
   set(double(h),'marker','*')
else   
   % Find frequencies where response first enters and last leaves
   % disk of rho 10 centered at (-1,0)
   distcp = abs(gap);
   rho = max(10,1.5 * min(distcp));
   npts = length(distcp);
   if distcp(find(isfinite(distcp),1))>rho
      idxs = find(distcp<=rho,1)-1;  
   else
      idxs = 1;
   end
   if distcp(find(isfinite(distcp),1,'last'))>rho
      idxf = find(distcp<=rho,1,'last')+1;
   else
      idxf = npts; 
   end
   
   % Update line data
   for ct=1:length(h)
      xdata = get(h(ct), 'XData');
      ydata = get(h(ct), 'YData');
      if length(ydata)==npts && npts>1
         % Use interpolation to find exact crossings with disk
         xdata = xdata(idxs:idxf);
         ydata = ydata(idxs:idxf);
         if distcp(idxs)>rho
            u = [xdata(2)-xdata(1);ydata(2)-ydata(1)];
            M = [xdata(1)+1;ydata(1)];
            t = min(roots([u'*u 2*M'*u M'*M-rho^2]));
            xdata(1) = xdata(1) + t * u(1);
            ydata(1) = ydata(1) + t * u(2);
         end
         if distcp(idxf)>rho
            n = length(xdata);
            u = [xdata(n-1)-xdata(n);ydata(n-1)-ydata(n)];
            M = [xdata(n)+1;ydata(n)];
            t = min(roots([u'*u 2*M'*u M'*M-rho^2]));
            xdata(n) = xdata(n) + t * u(1);
            ydata(n) = ydata(n) + t * u(2);
         end
         set(double(h(ct)),'XData', xdata, 'YData', ydata)
      end
   end
end
            
            
