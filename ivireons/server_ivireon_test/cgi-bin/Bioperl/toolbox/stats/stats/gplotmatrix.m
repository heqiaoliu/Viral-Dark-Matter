function [h,ax,BigAx] = gplotmatrix(x,y,g,clr,sym,siz,doleg,dispopt,xnam,ynam)
%GPLOTMATRIX  Scatter plot matrix with grouping variable.
%   GPLOTMATRIX(X,Y,G) creates a matrix of scatter plots of the columns of
%   X against the columns of Y, grouped by G.  If X is P-by-M and Y is
%   P-by-N, GPLOTMATRIX will produce a N-by-M matrix of axes.  If you omit
%   Y or specify it as [], the function graphs X vs. X.  G is a grouping
%   variable that determines the marker and color assigned to each point in
%   each matrix, and it can be a categorical variable, vector, string
%   matrix, or cell array of strings.  Alternatively G can be a cell array
%   of grouping variables (such as {G1 G2 G3}) to group the values in X by
%   each unique combination of grouping variable values.
%
%   Use the data cursor to read precise values from the plot, as well as
%   the observation number and the values of related variables.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ) specifies the colors, markers, and size
%   to use.  CLR is a string of color specifications, and SYM is a string
%   of marker specifications.  Type "help plot" for more information.  For
%   example, if SYM='o+x', the first group will be plotted with a circle,
%   the second with plus, and the third with x. SIZ is a marker size to use
%   for all plots.  By default, the colors are 'bgrcmyk', the marker is
%   '.', and the marker size depends on the number of plots and the size of
%   the figure window.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ,DOLEG) lets you control whether legends
%   are created.  Set DOLEG to 'on' (default) or 'off'.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ,DOLEG,DISPOPT) lets you control how to
%   fill the diagonals in a plot of X vs. X.  Set DISPOPT to 'none' to
%   leave them blank, 'hist' (default) to plot histograms, or 'variable' to
%   write the variable names.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ,DOLEG,DISPOPT,XNAM,YNAM) specifies XNAM
%   and YNAM as the names of the X and Y variables.  Each must be a
%   character array or cell array of strings of the appropriate dimension.
%
%   [H,AX,BigAx] = GPLOTMATRIX(...) returns an array of handles H to the
%   plotted points; a matrix AX of handles to the individual subaxes; and a
%   handle BIGAX to big (invisible) axes framing the subaxes.  The third
%   dimension of H corresponds to groups in G.  If DISPOPT is 'hist', AX
%   contains one extra row of handles to invisible axes in which the
%   histograms are plotted. BigAx is left as the CurrentAxes so that a
%   subsequent TITLE, XLABEL, or YLABEL will be centered with respect to
%   the matrix of axes.
%
%   Example:
%      load carsmall;
%      X = [MPG,Acceleration,Displacement,Weight,Horsepower];
%      varNames = {'MPG' 'Acceleration' 'Displacement' 'Weight' 'Horsepower'};
%      gplotmatrix(X,[],Cylinders,'bgrcm',[],[],'on','hist',varNames);
%
%   See also GRPSTATS, GSCATTER, PLOTMATRIX.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:58:48 $

error(nargchk(1,10,nargin,'struct'));
nin = nargin;

if (nin < 2), y = []; end
if isempty(y) % gplotmatrix(x)
  rows = size(x,2); cols = rows;
  y = x;
  XvsX = true;
else % gplotmatrix(x,y)
  rows = size(y,2); cols = size(x,2);
  XvsX = false;
end
if (nin > 2) && ~isempty(g)
   [g,gn] = mgrp2idx(g,size(x,1),',');
   ng = max(g);
else
   g = [];
   gn = [];
   ng = 1;
end

% Default colors, markers, etc.
if (nin < 4) || isempty(clr), clr = 'bgrcmyk'; end
if (nin < 5) || isempty(sym), sym = '.'; end
if (nin < 6), siz = []; end
if (nin < 7) || isempty(doleg), doleg = 'on'; end
if (nin < 8) || isempty(dispopt), dispopt = 'h'; end
if (nin < 9) || isempty(xnam)
   xnam = {};
else
   if ischar(xnam) && (size(xnam,1)==cols)
       xnam = cellstr(xnam);
   elseif iscellstr(xnam) && (numel(xnam)==cols)
      % ok
   else
      error('stats:gplotmatrix:InputSizeMismatch',...
            'XNAM must be a character array or cell array of strings, with\none variable name for each column of X.');
   end
end
if (XvsX)
   ynam = xnam;
elseif (nin < 10) || isempty(ynam)
   ynam = {};
else
   if ischar(ynam) && (size(ynam,1)==rows)
       ynam = cellstr(ynam);
   elseif iscellstr(ynam) && (numel(ynam)==rows)
      % ok
   else
      error('stats:gplotmatrix:InputSizeMismatch',...
            'YNAM must be a character array or cell array of strings, with\none variable name for each column of Y.');
   end
end

% What should go into the plot matrix?
doleg = strcmp(doleg, 'on') && (~XvsX || (rows>1)) && ~isempty(gn);
dohist = XvsX && (dispopt(1)=='h');
donames = (XvsX && (dispopt(1)=='v'));

% Don't plot anything if either x or y is empty
if isempty(rows) || isempty(cols),
   if nargout>0, h = []; ax = []; BigAx = []; end
   return
end

if ndims(x)>2 || ndims(y)>2
   error('stats:gplotmatrix:MatrixRequired','X and Y must be 2-D.');
end
if size(x,1)~=size(y,1)
  error('stats:gplotmatrix:InputSizeMismatch',...
        'X and Y must have the same length.');
end
if (~isempty(g)) && (length(g) ~= size(x,1)),
  error('stats:gplotmatrix:InputSizeMismatch',...
        'There must be one value of G for each row of X.');
end

% Create/find BigAx and make it invisible
clf;
BigAx = newplot;
hold_state = ishold;
set(BigAx,'Visible','off','color','none')

if (isempty(siz))
   siz = repmat(get(0,'defaultlinemarkersize'), size(sym));
   if any(sym=='.'),
      units = get(BigAx,'units');
      set(BigAx,'units','pixels');
      pos = get(BigAx,'Position');
      set(BigAx,'units',units);
      siz(sym=='.') = max(1,min(15, ...
                       round(15*min(pos(3:4))/size(x,1)/max(rows,cols))));
   end
end

% Store global data for datatips into BixAx
ginds = cell(1,ng);
for i=1:ng
    ginds{i} = find(g==i);
end

setappdata(BigAx,'ginds',ginds);
setappdata(BigAx,'xnam',xnam);
setappdata(BigAx,'ynam',ynam);
setappdata(BigAx,'x',x);
setappdata(BigAx,'y',y);
setappdata(BigAx,'XvsX',XvsX);
setappdata(BigAx,'gn',gn);

% Make datatips show up in front of axes
dcm_obj = datacursormode(ancestor(BigAx,'figure'));
set(dcm_obj,'EnableAxesStacking',true);

dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',@gplotmatrixDatatipCallback);

% Create and plot into axes
ax2filled = false(max(rows,cols),1);
pos = get(BigAx,'Position');
width = pos(3)/cols;
height = pos(4)/rows;
space = .02; % 2 percent space between axes
pos(1:2) = pos(1:2) + space*[width height];
[m,n,k] = size(y); %#ok<ASGLU>
xlim = repmat(cat(3,min(x,[],1),max(x,[],1)),[rows 1 1]);
ylim = repmat(cat(3,min(y,[],1)',max(y,[],1)'),[1 cols 1]);

for i=rows:-1:1,
   for j=cols:-1:1,
      axPos = [pos(1)+(j-1)*width pos(2)+(rows-i)*height ...
               width*(1-space) height*(1-space)];
      ax(i,j) = axes('Position',axPos, 'visible', 'on', 'Box','on');

      if ((i==j) && XvsX)
         if (dohist)
            histax = axes('Position',axPos);
            ax2(j) = histax;
            ax2filled(j) = true;
            [nn,xx] = hist(reshape(y(:,i,:),[m k]));
            hhdiag(i) = bar(xx,nn,'hist');
            set(histax, 'YAxisLocation', 'right', ...
                        'Visible','off', 'XTick',[], 'YTick',[], ...
                        'XGrid','off', 'YGrid','off', ...
                        'XTickLabel','', 'YTickLabel','');
            axis tight;
            xlim(i,j,:) = get(gca,'xlim');
            % Don't set ylim, so histogram heights won't affect y limits.
         end
      else
         hhij = iscatter(reshape(x(:,j,:),[m k]), ...
                              reshape(y(:,i,:),[m k]), ...
                              g, clr, sym, siz);
         hh(i,j,1:length(hhij)) = hhij;
         axis tight;
         ylim(i,j,:) = get(gca,'ylim');
         xlim(i,j,:) = get(gca,'xlim');

         % Store information for gname
         set(gca, 'UserData', {'gscatter' x(:,j,:) y(:,i,:) g});
         % Attach data cursor
         for q=1:ng
             hgaddbehavior(hh(i,j,q),dataCursorBehaviorObj);
             setappdata(hh(i,j,q),'dtcallbackdata',{BigAx,q,i,j});
         end
      end
      set(ax(i,j),'xlimmode','auto', 'ylimmode','auto', ...
                  'xgrid','off', 'ygrid','off')
   end
end

% Fill in histogram handles
if XvsX && dohist
    for i=1:rows
        hh(i,i,1) = hhdiag(i);
    end
end

xlimmin = min(xlim(:,:,1),[],1); xlimmax = max(xlim(:,:,2),[],1);
ylimmin = min(ylim(:,:,1),[],2); ylimmax = max(ylim(:,:,2),[],2);

% Set all the limits of a row or column to be the same and leave 
% just a 5% gap between data and axes.
inset = .05;
for i=1:rows,
  set(ax(i,1),'ylim',[ylimmin(i,1) ylimmax(i,1)])
  dy = diff(get(ax(i,1),'ylim'))*inset;
  set(ax(i,:),'ylim',[ylimmin(i,1)-dy ylimmax(i,1)+dy])
end
for j=1:cols,
  set(ax(1,j),'xlim',[xlimmin(1,j) xlimmax(1,j)])
  dx = diff(get(ax(1,j),'xlim'))*inset;
  set(ax(:,j),'xlim',[xlimmin(1,j)-dx xlimmax(1,j)+dx])
  if ax2filled(j)
     set(ax2(j),'xlim',[xlimmin(1,j)-dx xlimmax(1,j)+dx])
  end
end

% Label plots one way or the other
if (donames && ~isempty(xnam))
   for j=1:cols
      set(gcf,'CurrentAx',ax(j,j));
      h = text((...
          xlimmin(1,j)+xlimmax(1,j))/2, (ylimmin(j,1)+ylimmax(j,1))/2, -.1,...
          xnam{j}, 'HorizontalAlignment','center',...
          'VerticalAlignment','middle');
   end
else
   if ~isempty(xnam)
      for j=1:cols, xlabel(ax(rows,j),xnam{j}); end
   end
   if ~isempty(ynam)
      for i=1:rows, ylabel(ax(i,1),ynam{i}); end
   end
end

% Ticks and labels on outer plots only
set(ax(1:rows-1,:),'xticklabel','')
set(ax(:,2:cols),'yticklabel','')
set(BigAx,'XTick',get(ax(rows,1),'xtick'),'YTick',get(ax(rows,1),'ytick'), ...
          'userdata',ax,'tag','PlotMatrixBigAx')

% Create legend if requested; base it on the top right plot
if (doleg)
   gn = gn(ismember(1:size(gn,1),g),:);
   legend(ax(1,cols),gn);
end

% Make BigAx the CurrentAxes
set(gcf,'CurrentAx',BigAx)
if ~hold_state,
   set(gcf,'NextPlot','replace')
end

% Also set Title and X/YLabel visibility to on and strings to empty
set([get(BigAx,'Title'); get(BigAx,'XLabel'); get(BigAx,'YLabel')], ...
 'String','','Visible','on')

if nargout~=0,
  h = hh;
  if any(ax2filled)
     ax = [ax; ax2(:)'];
  end
end

% -----------------------------
function datatipTxt = gplotmatrixDatatipCallback(obj,evt)

target = get(evt,'Target');
ind = get(evt,'DataIndex');
pos = get(evt,'Position');

dtcallbackdata = getappdata(target,'dtcallbackdata');
[BigAx,gnum,row,col] = dtcallbackdata{:};

ginds = getappdata(BigAx,'ginds');
xnam = getappdata(BigAx,'xnam');
ynam = getappdata(BigAx,'ynam');
xdat = getappdata(BigAx,'x');
ydat = getappdata(BigAx,'y');
XvsX = getappdata(BigAx,'XvsX');
gn = getappdata(BigAx,'gn');

gind = ginds{gnum};
obsind = gind(ind);

xvals = xdat(obsind,:);
yvals = ydat(obsind,:);

x = xvals(col);
y = yvals(row);

if x~=pos(1) || y~=pos(2)
    % Something is inconsistent, display default datatip.
    datatipTxt = {['X: ' num2str(pos(1))],['Y: ' num2str(pos(2))]};
else
    if isempty(xnam)
        xnam = cell(size(xdat,2),1);
        for i = 1:size(xdat,2)
            xnam{i} = ['xvar' num2str(i)];
        end
    end
    if isempty(ynam)
        ynam = cell(size(ydat,2),1);
        for i = 1:size(ydat,2)
            ynam{i} = ['yvar' num2str(i)];
        end
    end

    % Generate datatip text.
    datatipTxt = {
        [xnam{col},': ',num2str(x)],...
        [ynam{row},': ',num2str(y)],...
        '',...
        ['Observation: ',num2str(obsind)],...
        };

    if ~isempty(gn)
        datatipTxt{end+1} = ['Group: ',gn{gnum}];
    end
    datatipTxt{end+1} = '';

    xnamTxt = cell(length(xvals),1);
    for i=1:length(xvals)
        xnamTxt{i} = [xnam{i} ': ' num2str(xvals(i))];
    end
    datatipTxt = {datatipTxt{:}, xnamTxt{:}};
    
    if ~XvsX
        ynamTxt = cell(length(yvals),1);
        for i=1:length(yvals)
            ynamTxt{i} = [ynam{i} ': ' num2str(yvals(i))];
        end
        datatipTxt = {datatipTxt{:}, ynamTxt{:}};
    end

end


