function draw(this, Data, NormalRefresh)
%DRAW  Draws time response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.8 $ $Date: 2006/11/17 13:45:42 $

% Time:      Ns x 1
% Amplitude: Ns x Ny x Nu

% Input and output sizes
[Ny, Nu] = size(this.Curves);

%% Cache data
data = Data.Amplitude;
time = Data.Time;
watermarkdata = Data.Watermarkdata;
watermarktime = Data.Watermarktime;

% Redraw the curves
if strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(this.Curves),'XData',[],'YData',[])
   set(double(this.WatermarkCurves),'XData',[],'YData',[])
else
  for ct = 1:Ny*Nu
     %% ZData = 10 - Make sure data lines are in the front, watermark
     %% lines behind
     if ~isequal(Data.Ts,0) && strcmp(this.Style,'stairs')
         [T,Y] = stairs(time,data(:,ct));
         set(double(this.Curves(ct)), 'XData', T, 'YData', Y);        
     else
         set(double(this.Curves(ct)), 'XData', time, ...
           'YData', data(:,ct))
     end 
     if ~isempty(watermarkdata)
         if ~isequal(Data.Ts,0) && strcmp(this.Style,'stairs')
             [T,Y] = stairs(watermarktime,watermarkdata(:,ct));
             set(double(this.WatermarkCurves(ct)), 'XData', T, 'YData', Y);              
         else
             set(double(this.WatermarkCurves(ct)), 'XData', watermarktime, ...
                'YData', watermarkdata(:,ct)) 
         end
     else
         set(double(this.WatermarkCurves(ct)), 'XData', [], ...
            'YData', []) 
     end
  end    
end

%% Draw selected points
if ~isempty(this.SelectedPoints) && isequal(size(this.SelectedPoints),size(data))
    
    selectionCurves = double(this.SelectionCurves);
    for ct = 1:Ny*Nu
        if size(this.SelectedPoints,1)==length(time)
    
            % Get the data once to avoid repeted access to time series
            % data storage
            xdata = time;
            ydata = Data.Amplitude(:,ct);
            if length(xdata)>=2
                % Form the selected data array - one row per obs, half
                % line segments on each side of the point
                if ~isequal(Data.Ts,0) && strcmp(this.Style,'stairs')
                    X = ...
                    [NaN                                 NaN                      0.5*(xdata(1)+xdata(2))
                    0.5*(xdata(1:end-2)+xdata(2:end-1))  xdata(2:end-1)           0.5*(xdata(2:end-1)+xdata(3:end)) 
                    0.5*(xdata(end-1)+xdata(end))        xdata(end)               NaN];
                    Y = ...
                    [NaN                                 NaN                      ydata(1)
                    ydata(1:end-2)                       ydata(2:end-1)           ydata(2:end-1)
                    ydata(end-1)                         ydata(end)               NaN];
                else
                    X = ...
                    [NaN                                 xdata(1)           0.5*(xdata(1)+xdata(2))
                    0.5*(xdata(1:end-2)+xdata(2:end-1))  xdata(2:end-1)     0.5*(xdata(2:end-1)+xdata(3:end)) 
                    0.5*(xdata(end-1)+xdata(end))        xdata(end)         NaN];
                    Y = ...
                    [NaN                                 ydata(1)           0.5*(ydata(1)+ydata(2))
                    0.5*(ydata(1:end-2)+ydata(2:end-1))  ydata(2:end-1)     0.5*(ydata(2:end-1)+ydata(3:end)) 
                    0.5*(ydata(end-1)+ydata(end))        ydata(end)         NaN];
                end
                % Set unselected points on SelectionCurves to NaN
                X(~this.SelectedPoints(:,ct),:) = NaN;% Null out excluded
                X = X';
                Y(~this.SelectedPoints(:,ct),:) = NaN; % Null out excluded
                Y = Y'; 

            else
                X = xdata(1);
                Y = ydata;
            end
            if  ~isequal(Data.Ts,0) && strcmp(this.Style,'stairs')
                [X1,Y1] = stairs(X,Y);
                set(selectionCurves(ct),'xdata',X1(:),'ydata',Y1(:));
            else
                set(selectionCurves(ct),'xdata',X(:),'ydata',Y(:));
            end
        end
    end
else 
   this.SelectedPoints = []; % Reset selected points 
   s = size(time);
   selectionCurves = double(this.SelectionCurves);
   for ct = 1:Ny*Nu 
       set(selectionCurves(ct),'ydata',NaN*ones([max(s) 1]),'xdata', ...
           NaN*ones([max(s) 1]));
   end
end
      
%% Draw time selection rectangles. Each SelectionPatch need only be
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
    if length(this.SelectedTimes)>0
        ylims = get(ax(k),'yLim');
        xlims = get(ax(k),'xLim');
        xdata = [this.SelectedTimes this.SelectedTimes(:,end:-1:1)]';
        xdata(xdata<xlims(1)) = xlims(1);
        xdata(xdata>xlims(2)) = xlims(2);
        ydata = [ylims(1); ylims(1);ylims(2);ylims(2)]*ones(1,size(this.SelectedTimes,1));
        zdata = [-10;-10;-10;-10]*ones(1,size(this.SelectedTimes,1));
        set(rear_patch,...
          'Xdata',xdata,...
          'Ydata',ydata,...
          'LineStyle','none',...
          'HitTest','on');
    else
         set(rear_patch,...
          'Xdata',[NaN;NaN;NaN;NaN],...
          'Ydata',[NaN;NaN;NaN;NaN],...
          'LineStyle','none',...
          'HitTest','on');
    end

    % Clear other patches    
    for j=1:length(other_grp)
          thispatch = findobj(allchild(other_grp(j)),'type','patch');
          set(thispatch,...
          'Xdata',[NaN;NaN;NaN;NaN],...
          'Ydata',[NaN;NaN;NaN;NaN],...
          'LineStyle','none',...
          'HitTest','on');
    end
end
