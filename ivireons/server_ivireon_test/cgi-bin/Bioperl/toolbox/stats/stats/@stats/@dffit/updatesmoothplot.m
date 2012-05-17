function updatesmoothplot(fit,newlim)
%UPDATESMOOTHPLOT Update the plot of smooth (nonparametric) fit

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:22:08 $
%   Copyright 2003-2008 The MathWorks, Inc.

dffig = dfgetset('dffig');

if fit.plot && fit.isgood
   % Get the axes and make sure they include our x range
   ax = get(dffig,'CurrentAxes');
   fit.ylim = [];     % forget any old settings
   
   ds = fit.dshandle;
   [ydata,cens,freq] = getincludeddata(ds,fit.exclusionrule);

   % Find a good color and line style
   [c,m,l,w] = dfswitchyard('statgetcolor',ax,'fit',fit);
   m = 'none';
   
   % Special handling for probability plots
   if isequal(fit.ftype, 'probplot')
      if ~isempty(fit.linehandle) && ishghandle(fit.linehandle)
         delete(fit.linehandle);
      end
      params = {ydata cens freq fit};

      fit.linehandle = probplot(ax,@cdfnp,params);
      set(fit.linehandle, 'Color',c, 'Marker',m, 'LineStyle',l, ...
                          'LineWidth',w);
      if ~isempty(fit.boundline) && ishghandle(fit.boundline)
         delete(fit.boundline);
         fit.boundline = [];
      end
      fit.x = get(fit.linehandle,'XData');
      ydata = get(fit.linehandle,'YData');
      fit.y = ydata;
   else
      % draw the fit
      x = fit.x;
      xlim = get(ax,'XLim');
      if isempty(xlim)
         xlim = [0 1];
      end
      if nargin<2
          newlim = xlim;
      end
      fit.xlim = newlim;
      if isempty(x) || x(1)~=xlim(1) || x(end)~=xlim(end)
         x = linspace(newlim(1),newlim(2),fit.numevalpoints);
         fit.x = x;
      end
      [y,ignore,outwidth] = ksdensity(ydata, x, 'cens',cens, ...
                    'weight',freq,...
                    'support',fit.support,'function',fit.ftype, ...
                    'kernel',fit.kernel, 'width',fit.bandwidth);
      fit.y = y;
      fit.bandwidth = outwidth;
      if isempty(fit.linehandle) || ~ishghandle(fit.linehandle)
         fit.linehandle=line(x,y,...
            'Color',c, 'Marker',m, 'LineStyle',l, 'LineWidth',w, ...
            'Parent',ax);
      else
         set(fit.linehandle,'XData',x,'YData',y,'UserData',fit,'Marker',m);
      end
   end
   fit.ylim = [min(fit.y), max(fit.y)];
   set(fit.linehandle,'ButtonDownFcn',dfittool('gettipfcn'),...
                      'Tag','distfit','UserData',fit);
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
   end
end

% -----------------------------------------------
function f=cdfnp(x, y,cens,freq,fit)
%CDFNP Compute cdf for non-parametric fit, used in probability plot

[f,ignore,outwidth] = ksdensity(y, x, 'cens',cens, 'weight',freq, ...
                                'function','cdf','support',fit.support, ...
                                'kernel',fit.kernel, 'width',fit.bandwidth);

% Update fit with band width actually used
if isempty(fit.bandwidth)
   fit.bandwidth = outwidth;
end


