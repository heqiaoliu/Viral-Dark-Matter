function robustdemo(action,arg2)
%ROBUSTDEMO Demonstration of robust fitting (ROBUSTFIT function)
%   ROBUSTDEMO demonstrates the difference between ordinary (least
%   squares) regression and robust regression.  It displays a
%   scatter plot of X and Y values, where Y is roughly a linear
%   function of X but one point is an outlier (it falls far from
%   the line).  The bottom of the figure shows the fitted equations
%   using least squares and robust fitting, plus an estimate of the
%   root mean squared error from both.
%
%   You can use the left mouse button to select a point and move
%   it, and the fitted lines will update.  You can use the right
%   mouse button to click on a point and view two of its
%   properties:
%       LEVERAGE is a measure of how much influence that point has
%                on the least squares fit.
%       WEIGHT is the weight that point was given in the robust fit.
%
%   ROBUSTDEMO(X,Y) uses X and Y data you supply, in place of the
%   sample data supplied with the function.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/05/10 17:59:55 $

if (nargin<1), action = 'start'; end

% Normally we use data defined here, but we'll take input data too
xname = 'X';
yname = 'Y';
if (isnumeric(action))
   if (nargin<2)
      error('stats:robustdemo:TooFewInputs','Missing Y vector.');
   end
   x = action(:);
   y = arg2(:);
   action = 'start';
   if (length(x)~=length(y) || length(x)<3)
      error('stats:robustdemo:InputSizeMismatch',...
            'Lengths of X and Y vectors must be the same and at least 3.');
   end
   if ~isempty(inputname(1))
      xname = inputname(1);
   end
   if ~isempty(inputname(2))
      yname = inputname(2);
   end
   
elseif (isequal(action,'start'))
   % Use roughly linear data, with an outlier
   x = (1:10)';
   y = [-0.6867 1.7258 1.9117 6.1832 5.3636 ...
        7.1139 9.5668 10.0593 11.4044 6.1677]';
end

% For callback, always need handles and cursor location
if (~isequal(action, 'start'))
   fig = gcbf;
   ax = findobj(fig, 'Tag', 'graph');

   cp = get(ax,'CurrentPoint');
   cx = cp(1,1);
   cy = cp(1,2);
end

switch(action)
 case 'start'
   % Make a scatter plot
   fig = figure('WindowButtonDownFcn',  'robustdemo(''down'')', ...
            'WindowButtonUpFcn',    '', ...
            'WindowButtonMotionFcn','', ...
            'Interruptible','off', ...
            'NumberTitle','off', 'IntegerHandle','off', ...
            'Name','Robust Fitting Demonstration');

   % Brushing and linking don't work, so remove them to avoid confusion
   delete(uigettool(fig,'Exploration.Brushing'))
   delete(uigettool(fig,'DataManager.Linking'))
   delete(findall(fig,'Tag','figDataManagerBrushTools'))
   delete(findall(fig,'Tag','figBrush'))
   delete(findall(fig,'Tag','figLinked'))   
        
   for j=1:numel(x)
       h = line(x(j),y(j),'marker','o','linestyle','none','tag','data');
       a = get(h,'Annotation');
       a.LegendInformation.IconDisplayStyle = 'off';
   end
   
   ax = gca;
   xlim = [min(x) max(x)];
   xlim = xlim + diff(xlim) * 0.1 * [-1 1];
   ylim = [min(y) max(y)];
   ylim = ylim + diff(ylim) * 0.1 * [-1 1];
   set(ax,'Position',[.13 .3 .85 .6],'Tag','graph',...
          'XLim',xlim,'XLimMode','manual',...
          'YLim',ylim,'YLimMode','manual');
   title(sprintf(...
       ['Use left mouse button to select and drag points\n' ...
        'Use right mouse button to query point properties']));
   set(get(ax,'XLabel'),'String',xname);
   set(get(ax,'YLabel'),'String',yname);

   % Add fitted curves, just fake ones for now.  These lines just connect
   % the dots, and allow legend to try to avoid the data points.
   hold on;
   [sx,indx] = sort(x);
   sy = y(indx);
   h1 = plot(sx, sy, 'r-', 'Tag', 'lsfit', 'Visible','off');
   h2 = plot(sx, sy, 'g-', 'Tag', 'rfit',  'Visible','off');
   hold off;
   
   % Create empty invisible axes to hold text annotations
   axes('Position', [.05 .0 .9 .2], 'Visible','off');
   
   % Add fields to hold text
   text(0,.5,'Least squares:');
   text(0,.2,'Robust:');
   text(.3,.5,'','Tag','lseqn');
   text(.3,.2,'','Tag','reqn');
   text(.75,.5,'','Tag','lsrmse');
   text(.75,.2,'','Tag','rrmse');
   axes(ax);

   legend([h1 h2], {'Least squares', 'Robust'}, 'location','Best');

   set(fig, 'HandleVisibility','callback');

   % Get data again, using the order as stored inside figure
   [x,y] = getcoords(ax);

 case 'down'
   [x,y,h] = getcoords(ax);

   xl = get(ax,'XLim');
   dx = diff(xl);
   yl = get(ax,'YLim');
   dy = diff(yl);

   % Do nothing if we're not within the axes
   if ~(cx>=xl(1) && cx<=xl(2) && cy>=yl(1) && cy<=yl(2)), return; end
   
   d = abs((x-cx)/dx) + abs((y-cy)/dy);
   [dmin,j] = min(d);

   if (dmin < 0.1)
      btype = get(fig,'SelectionType');

      if (isequal(btype,'alt'))
         s = get(fig, 'UserData');
         lev = s.h(j); % leverage
         wgt = s.w(j); % weight
         txt = sprintf(...
             'L.S. leverage = %.2g\nRobust weight = %.2g',...
             lev,wgt);
         if (x(j) < xl(1) + dx/3)
            xalign = 'left';
         elseif (x(j) > xl(1) + 2*dx/3)
            xalign = 'right';
         else
            xalign = 'center';
         end
         text(x(j),y(j)-.01*dy,txt, 'Tag','label', 'Color','m',...
                  'HorizontalAlignment',xalign,'VerticalAlignment','top');
         set(fig, 'WindowButtonUpFcn', 'robustdemo(''erase'')');
      else
         % Prepare to grab point only if it is close
         set(fig, 'WindowButtonMotionFcn','robustdemo(''motion'')', ...
                  'WindowButtonUpFcn',    'robustdemo(''up'')');
  
         h = h(j);
         w = get(h, 'LineWidth');
         set(ax,'UserData',{h w});
         set(h, 'LineWidth', 2);
      end
   end
   return

 case {'up' 'motion'}
   hw = get(ax,'UserData');
   xlim = get(ax,'XLim');
   ylim = get(ax,'YLim');
   dx = diff(xlim)/100;
   dy = diff(ylim)/100;
   set(hw{1}, 'XData',min(xlim(2)-dx,max(xlim(1)+dx,cx)), ...
              'YData',min(ylim(2)-dy,max(ylim(1)+dy,cy)));
   if isequal(action,'motion')
      return
   end
   
   set(hw{1}, 'LineWidth',hw{2});
   set(fig, 'WindowButtonMotionFcn','', 'WindowButtonUpFcn','');
   [x,y] = getcoords(ax);
   
 case 'erase'
   h = findobj(ax,'Tag','label');
   delete(h);
   set(fig, 'WindowButtonUpFcn','');
   return
end
   

% Now fit y as a linear function of x using both algorithms
b0 = regress(y,[ones(length(y),1) x]);
[b1,s] = robustfit(x,y);
s0 = s.ols_s;
s1 = s.s;

% Remove old line so it won't affect axis limits
h1 = findobj(ax,'Tag','lsfit');
if (~isempty(h1)), set(h1, 'XData',[], 'YData',[]); end
h2 = findobj(ax,'Tag','rfit');
if (~isempty(h2)), set(h2, 'XData',[], 'YData',[]); end

% Get data limits and calculate a fitted line across the X range
xlim = get(ax,'XLim');
yls = b0(1) + b0(2)*xlim;
yr  = b1(1) + b1(2)*xlim;

% Update lines on graph
if (~isempty(h1)), set(h1, 'XData',xlim, 'YData',yls, 'Visible','on'); end
if (~isempty(h2)), set(h2, 'XData',xlim, 'YData',yr, 'Visible','on'); end

% Update text fields
h = findobj(fig,'Tag','lseqn');
if (~isempty(h)), set(h, 'String', sprintf('Y = %g + %g*X',b0)); end
h = findobj(fig,'Tag','reqn');
if (~isempty(h)), set(h, 'String', sprintf('Y = %g + %g*X',b1)); end
h = findobj(fig,'Tag','lsrmse');
if (~isempty(h)), set(h, 'String', sprintf('RMS error = %g',s0)); end
h = findobj(fig,'Tag','rrmse');
if (~isempty(h)), set(h, 'String', sprintf('RMS error = %g',s1)); end

% Store some info for possible later use
set(fig, 'UserData', s);

% ----------------------------
function [x,y,h] = getcoords(ax)
%GETCOORDS  Get coordinates of points now on the graph
h = findobj(ax, 'Tag', 'data');
x = get(h,'XData');
y = get(h,'YData');

% Combine x/y data for all lines
if iscell(x), x = cat(1,x{:}); end
if iscell(y), y = cat(1,y{:}); end

x = x(:);
y = y(:);
