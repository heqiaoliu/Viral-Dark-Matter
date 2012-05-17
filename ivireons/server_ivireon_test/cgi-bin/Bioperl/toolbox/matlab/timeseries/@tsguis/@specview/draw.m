function draw(this, Data, NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2006/06/27 23:11:14 $

AxGrid = this.AxesGrid;

%% Input and output sizes
[Ny, Nu] = size(this.Curves);
Freq = unitconv(Data.Frequency,Data.FreqUnits,AxGrid.XUnits);
Spec = Data.Response;
watermarkdata = Data.Watermarkdata;
watermarkfreq = Data.Watermarkfreq;

%% Eliminate zero frequencies in log scale
if strcmp(AxGrid.Xscale{1},'log')
   idxf = find(Freq>0);
   Freq = Freq(idxf);
   watermarkfreq = watermarkfreq(idxf);
   if ~isempty(Spec)
      Spec = Spec(idxf,:);
   end
   if ~isempty(watermarkdata)
      watermarkdata = watermarkdata (idxf,:);
   end
end

%% Spec curves
for ct = 1:Ny*Nu
   % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
   set(double(this.Curves(ct)), 'XData', Freq, 'YData', Spec(:,ct));
   if ~isempty(watermarkdata)
       set(double(this.WatermarkCurves(ct)), 'XData', watermarkfreq, ...
                'YData', watermarkdata(:,ct)) 
   else
        set(double(this.WatermarkCurves(ct)), 'XData',[],'YData',[]) 
   end
end

%% Draw  selection rectangles. Each SelectionPatch need only be
%% drawn once in each axes since they all occur at the same times. Need to
%% detect this and avoid drawing overlapping rectangles. Also avoids xor
%% mode toggling the visibility of overlapping patches
ax = this.AxesGrid.getaxes;
for k=1:length(ax)
    % Find the most rear group so that it does not overlap lines
    ax_children = double(allchild(ax(k)));
    hggroup_children = findobj(ax_children,'Type','hggroup');
    [junk1,ind] = intersect(ax_children,hggroup_children);
    [maxind,maxindPos] = max(ind);
    rear_grp = ax_children(maxind);
    other_grp = setdiff(hggroup_children, rear_grp);
    rear_patch = findobj(allchild(rear_grp),'type','patch');
 
    % Draw read patch
    if length(this.SelectedInterval)>0
        ylims = get(ax(k),'yLim');
        xlims = get(ax(k),'xLim');
        xdata = [this.SelectedInterval this.SelectedInterval(:,end:-1:1)]';
        xdata(xdata<xlims(1)) = xlims(1);
        xdata(xdata>xlims(2)) = xlims(2);
        ydata = [ylims(1); ylims(1);ylims(2);ylims(2)]*ones(1,length(this.SelectedInterval));
        zdata = [-10;-10;-10;-10]*ones(1,length(this.SelectedInterval));
        set(rear_patch,...
          'Zdata',zdata,...
          'Xdata',xdata,...
          'Ydata',ydata,...
          'LineStyle','none',...
          'HitTest','on');
    else
         set(rear_patch,...
          'Zdata',[NaN;NaN;NaN;NaN],...
          'Xdata',[NaN;NaN;NaN;NaN],...
          'Ydata',[NaN;NaN;NaN;NaN],...
          'LineStyle','none',...
          'HitTest','on');
    end
    % Clear other patches    
    for j=1:length(other_grp)
          thispatch = findobj(allchild(other_grp(j)),'type','patch');
          set(thispatch,...
          'Zdata',[NaN;NaN;NaN;NaN],...
          'Xdata',[NaN;NaN;NaN;NaN],...
          'Ydata',[NaN;NaN;NaN;NaN],...
          'LineStyle','none',...
          'HitTest','on');
    end
end