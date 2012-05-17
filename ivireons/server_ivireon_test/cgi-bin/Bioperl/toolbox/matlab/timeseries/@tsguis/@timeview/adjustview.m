function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/11/17 13:45:41 $

if strcmp(Event,'postlim') && strcmp(View.AxesGrid.YNormalization,'on')
      % Draw normalized data once X limits are finalized
      for ct=1:prod(size(View.Curves))
         Xlims = get(ancestor(View.Curves(ct),'Axes'),'Xlim');
         YData = normalize(Data,Data.Amplitude(:,ct),Xlims,ct);
         if ~isempty(Data.Amplitude)
             if ~isequal(Data.Ts,0) && strcmp(View.Style,'stairs')
                 [T,Y] = stairs(Data.Time,YData);
                 set(double(View.Curves(ct)),'XData',T,'YData',Y);
             else
                 set(double(View.Curves(ct)),'XData',Data.Time,'YData',YData);
             end
         else
             set(double(View.Curves(ct)),'XData',[],'YData',[])
         end         
      end 
end

