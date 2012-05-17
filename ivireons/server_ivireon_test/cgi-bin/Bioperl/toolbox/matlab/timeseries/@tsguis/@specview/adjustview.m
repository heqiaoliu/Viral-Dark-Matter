function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:56:54 $

AxGrid = View.AxesGrid;

%% Input and output sizes
[Ny, Nu] = size(View.Curves);
Freq = unitconv(Data.Frequency,Data.FreqUnits,AxGrid.XUnits);
Spec = Data.Response;

%% Eliminate zero frequencies in log scale
if strcmp(AxGrid.Xscale{1},'log')
  idxf = find(Freq>0);
  Freq = Freq(idxf);
  if ~isempty(Spec)
     Spec = Spec(idxf,:);
  end
end

if strcmp(Event,'postlim') & strcmp(View.AxesGrid.YNormalization,'on')
   % Draw normalized data once X limits are finalized
      for ct=1:prod(size(View.Curves))
         Xlims = get(ancestor(View.Curves(ct),'Axes'),'Xlim'); 
         [ymin,ymax,FlatY] = ydataspan(Freq,Spec(:,ct), ...
            Xlims);
         YData = Spec(:,ct)/(ymax+FlatY);
      
         if ~isempty(Spec)
             set(double(View.Curves(ct)),'XData',Freq,'YData',YData)
         else
             set(double(View.Curves(ct)),'XData',[],'YData',[])
         end
      end 
end

