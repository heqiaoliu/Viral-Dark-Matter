function adjustview(this,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:12 $

return
%RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim') 
   [s1,s2] = size(this.UncertainPatch);
   % Position dot and lines given finalized axes limits
   for ct=1:s1*s2
      
      % Position objects
      set(double(this.UncertainPatch(ct)),'XData',XData,'YData',YData,-10*ones(size(YData)))
      XData = [Data.Time;Data.Time(end:-1:1)];
      ZData = -10 * ones(size(XData));
      set(this.UncertainPatch,'YData', [Data.UpperAmplitudeBound;Data.LowerAmplitudeBound(end:-1:1)],...
          'XData', XData,'ZData',ZData);
   end
end
% 
% %  Input and output sizes
% [Ny, Nu] = size(this.UncertainPatch);
% 
% % Redraw the curves
% if strcmp(this.AxesGrid.YNormalization,'on') || (length(Data.Data)<2)
%    % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
%    set(double(this.UncertainPatch),'XData',[],'YData',[],'ZData',[])
% else
%     % Map data to curves
%     Data.Ts = 0;
%     if isequal(Data.Ts,0)
%         % Plot data as a line
%         Bounds = getBounds(Data);
%         XData = [Bounds.Time;Bounds.Time(end:-1:1)];
%         ZData = -10 * ones(size(XData));
%         for ct = 1:Ny*Nu
%             TempData = Bounds.LowerAmplitudeBound(:,ct);
%             YData = [Bounds.UpperAmplitudeBound(:,ct);TempData(end:-1:1)];
%             set(double(this.UncertainPatch(ct)), 'XData', XData, ...
%                 'YData',YData,'ZData',ZData);
%         end
%     else
%         % Discrete time system use style to determine stem or stair plot
%         switch this.Style
%             case 'stairs'
%                 for ct = 1:Ny*Nu
%                     [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
%                     set(double(this.UncertainPatch(ct)), 'XData', T, 'YData', Y);
%                 end
%             case 'stem'
%                 % REVISIT: Not implemented yet
%                 ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
%                     'Stem plot is not currently implemented for this view type.')
%         end
%     end
% end