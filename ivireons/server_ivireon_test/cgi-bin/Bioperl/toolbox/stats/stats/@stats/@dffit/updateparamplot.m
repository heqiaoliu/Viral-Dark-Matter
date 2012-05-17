function updateparamplot(fit,newlim)
%UPDATEPARAMPLOT Update the plot of parametric fit

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:22:06 $
%   Copyright 2003-2008 The MathWorks, Inc.

dffig = dfgetset('dffig');

if fit.plot && fit.isgood
   % Get the axes and make sure they include our x range
   ax = get(dffig,'CurrentAxes');
   
   % Find a good color and line style
   [c,m,l,w] = dfswitchyard('statgetcolor',ax,'fit',fit);

   % Special handling for probability plots
   dist = fit.distspec;
   if isequal(fit.ftype, 'probplot')
      if ~isempty(fit.linehandle) && ishghandle(fit.linehandle)
         delete(fit.linehandle);
      end
      fit.linehandle = probplot(ax,dist.cdffunc,fit.params);
      set(fit.linehandle, 'Color',c, 'Marker','none', 'LineStyle',l, ...
                          'LineWidth',w);
      if ~isempty(fit.boundline) && ishghandle(fit.boundline)
         delete(fit.boundline);
         fit.boundline = [];
      end

      % Get data limits.  In some cases they may be infinite (as when a
      % Weibull fit appears on a normal probability plot), so consider
      % only the visible, finite points when selecting the axis limits.
      ydata = get(fit.linehandle,'YData');
      ydata(~isfinite(ydata)) = NaN;
      fit.ylim = [min(ydata), max(ydata)];
   else
      % For the inverse cdf of discrete distributions, evaluate cdf
      if isequal(fit.ftype,'icdf') && ~iscontinuous(fit)
         computeftype = 'cdf';
      else
         computeftype = fit.ftype;
      end
      
      % Get x data at which to evaluate this fit function
      xlim = get(ax,'XLim');
      if nargin<2
          newlim = xlim;
      end
      fit.xlim = newlim;

      if isempty(xlim)
         xlim = [0 1];
      end
      x = fit.x;
      if ~fit.iscontinuous
         if isequal(fit.ftype, 'icdf')
            plim = newlim + 0.01 * diff(newlim) * [1 -1];
            xlim = fit.eval(plim);
         else
            xlim(1) = ceil(newlim(1));
            xlim(2) = floor(newlim(2));
         end
         npts = max(2, xlim(2)-xlim(1)+1);
         incr = max(1, floor(npts / fit.numevalpoints));
         x = (xlim(1):incr:xlim(2))';
      elseif isempty(x) || x(1)~=xlim(1) || x(end)~=xlim(end)
         x = linspace(newlim(1),newlim(2),fit.numevalpoints)';
      end
      
      % Evaluate the function at x, with or without confidence bounds
      if fit.showbounds && dfgetset('dobounds')
         [y,ylo,yup] = fit.eval(x,computeftype);
         ybnds = [ylo yup];
      else
         y = fit.eval(x,computeftype);
         ybnds = [];
      end
      
      % For discrete distributions, modify x and y to get a discrete appearance
      if ~fit.iscontinuous && length(x)>1 && x(2)==x(1)+1
         n = length(x);
         ind = [1:n; 1:n];
         if ~isequal(fit.ftype, 'pdf')
            x = x(ind(2:end));
            y = y(ind(1:end-1));
            m = 'none';
         end
         if isequal(fit.ftype,'icdf')
            temp = y;
            y = x;
            x = temp;
         end
      else
         m = 'none';
      end
   
      % Store results into data members
      fit.x = x;
      fit.y = y;
      fit.ybounds = ybnds;
      if isempty(ybnds)
         fit.ylim = [min(y), max(y)];
      else
         fit.ylim = [min(min(y),min(ylo)), max(max(y),max(yup))];
      end
   
      % Plot the results and bounds
      if isempty(fit.linehandle) || ~ishghandle(fit.linehandle)
         fit.linehandle = line(x,y,...
            'Color',c, 'Marker',m, 'LineStyle',l, 'LineWidth',w, ...
            'Parent',ax);
      else
         set(fit.linehandle,'XData',x,'YData',y,'Marker',m);
      end
      if ~isempty(ybnds)
         xbnds = [x; NaN; x];
         ybnds = [ybnds(:,1); NaN; ybnds(:,2)];
         if isempty(fit.boundline) || ~ishghandle(fit.boundline)
            fit.boundline = line(xbnds, ybnds, ...
               'Color',c, 'Marker','none', 'LineStyle',':', 'LineWidth',1, ...
               'Parent',ax, 'Tag','dffbounds','UserData',fit);
         else
            set(fit.boundline,'XData',xbnds,'YData',ybnds,'UserData',fit);
         end
      elseif ~isempty(fit.boundline) && ishghandle(fit.boundline)
         delete(fit.boundline);
         fit.boundline = [];
      end
   end
   hTipFcn = dfittool('gettipfcn');
   set(fit.linehandle,'ButtonDownFcn',hTipFcn,...
                      'Tag','distfit','UserData',fit);
   if ~isempty(fit.boundline) && all(ishghandle(fit.boundline))
      set(fit.boundline,'ButtonDownFcn',hTipFcn);
   end
   savelineproperties(fit);

   % Give it a context menu
   if isempty(get(fit.linehandle,'uiContextMenu'))
      ctxt = findall(get(ax,'Parent'),'Type','uicontextmenu',...
                     'Tag','fitcontext');
      set(fit.linehandle,'uiContextMenu',ctxt);
   end
   
else
   if ~isempty(fit.linehandle)
      savelineproperties(fit);
      if ishghandle(fit.linehandle)
         delete(fit.linehandle);
      end
      fit.linehandle=[];
      if ~isempty(fit.boundline) && ishghandle(fit.boundline)
         delete(fit.boundline);
      end
      fit.boundline = [];
   end
end

