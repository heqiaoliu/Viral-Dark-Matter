function dfupdatelegend(dffig,reset,leginfo)
%DFUPLDATELEGEND Update legend in dfittool window

%   $Revision: 1.1.8.3 $  $Date: 2010/04/24 18:31:47 $ 
%   Copyright 2001-2010 The MathWorks, Inc.

if nargin<2, reset=false; end

% If figure not passed in, find figure that contains this thing
dffig = ancestor(dffig,'figure');

% Remember info about old legend, if any
ax = get(dffig,'CurrentAxes');
if isempty(get(ax,'Children'))
   legh = [];
else
   legh = legend('-find',ax);
end
if nargin<3 || isempty(leginfo)
    if ~isempty(legh) && ishghandle(legh) && ~reset
        leginfo = dfgetlegendinfo(legh);
    else
        leginfo = {};
    end
end

% Loop to find 'Location', as some non-text entries make ismember fail
foundit = false;
for j=1:length(leginfo)
    if isequal('Location',leginfo{j})
        foundit = true;
        break
    end
end
if ~foundit
    % Try to put the legend where the curves are not likely to be.
    % Position "0" is supposed to do this, but it is deprecated
    % and can be slow.  Instead use a heurisitic.
    ftype = dfgetset('ftype');
    if ischar(ftype) && ~isempty(ftype) && ismember(ftype, {'pdf' 'survivor'})
        % The survivor function is decreasing.  Most pdf functions drop more
        % quickly to the right. "northeast" is probably good for these functions.
        legendloc = 'NE';
    else
        % The remaining ones are increasing, so "northwest" is probably good.
        legendloc = 'NW';
    end
    leginfo(end+(1:2)) = {'Location' legendloc};
end
legend(ax, 'off');

% Maybe no legend has been requested
if isequal(dfgetset('showlegend'),'off')
   return
end

% Get data line handles and labels
hh = flipud(findobj(ax,'Type','line'));
hData = findobj(hh,'flat','Tag','dfdata');
n = length(hData);

textData = cell(n,1);
ok = true(1,length(hData));
for j=1:length(hData)
   nm = '';
   ds = get(hData(j),'UserData');
   if ~isempty(ds) && ishandle(ds) && ~isempty(findprop(ds,'name'))
      nm = ds.name;
   end
   if isempty(nm)
      ok(j) = false;
   else
      textData{j} = nm;
   end
end
textData = textData(ok);
hData = hData(ok);
sortData = 1000*(1:length(hData));
if isempty(sortData)
   maxnum = 0;
else
   maxnum = max(sortData) + 1000;
end

% Indent bounds if there are two or more data set lines
if n>1
   pre = '  ';
else
   pre = '';
end

% Deal with confidence bounds, if any, around empirical cdf
n = length(hData);
nextj = 1;
textDataBounds = {};
hDataBounds = [];
sortDataBounds = [];

for j=1:n
   ds = get(hData(j),'UserData');
   if ds.showbounds
      hbounds = ds.boundline;
      if ~isempty(hbounds) && ishghandle(hbounds) ...
                           && ~isempty(get(hbounds,'YData'))
         textDataBounds{nextj,1} = [pre 'confidence bounds'];
         hDataBounds = [hDataBounds; hbounds];
         sortDataBounds(nextj,1) = sortData(j) + .5;
         nextj = nextj + 1;
      end
   end
end

% Indent fits if there are two or more data lines
if (length(hData)>1)
   pre = '  ';
else
   pre = '';
end

% Get fit line handles and labels
hFit = findobj(hh,'flat','Tag','distfit');
sortFit = NaN(1,length(hFit));
n = length(hFit);
hFitConf = hFit;   % handle array, elements to be replaced
textFit = cell(n,1);
nms = cell(n,1);
ok = true(1,n);
havebounds = true(1,n);
for j=1:n
   try
      fit = get(hFit(j),'UserData');
      nm = fit.name;
   catch
      nm = '';
   end
   if isempty(nm)
      ok(j) = false;
   else
      nms{j} = nm;
      textFit{j} = [pre nm];
      
      % Find the dataset for this fit
      ds = fit.dshandle;
      sortFitj = maxnum + j;
      for k=1:length(hData)
         if isequal(ds.name,textData{k})
            sortFitj = sortData(k) + j;
            break;
         end
      end
      sortFit(j) = sortFitj;

      % Look for bounds
      b = get(fit,'boundline');
      if ~isempty(b)
         hFitConf(j) = b(1);
      else
         havebounds(j) = false;
      end
   end
end
nms = nms(ok);
textFit = textFit(ok);
hFit = hFit(ok);
sortFit = sortFit(ok);
hFitConf = hFitConf(ok);
havebounds = havebounds(ok);

% Indent bounds if there are two or more fits
if (length(hFit)>1)
   pre = [pre '  '];
end

% Get confidence bound line handles and labels
n = length(hFitConf);
textFitBounds = cell(n,1);
sortFitBounds = zeros(size(hFitConf));
for j=1:length(hFitConf)
   if havebounds(j) && ishghandle(hFitConf(j)) ...
                    && ~isempty(get(hFitConf(j),'XData'))
      textFitBounds{j} = sprintf('%sconfidence bounds (%s)',pre,nms{j});
      sortFitBounds(j) = sortFit(j) + 0.5;
   end
end
textFitBounds = textFitBounds(havebounds);
hFitConf = hFitConf(havebounds);
sortFitBounds = sortFitBounds(havebounds);

% Combine everything together for the legend
h = [hData(:); hDataBounds(:); hFit(:); hFitConf(:)];
c = [textData; textDataBounds; textFit; textFitBounds];
s = [sortData(:); sortDataBounds(:); sortFit(:); sortFitBounds(:)];

% Sort so related things are together
[~,j] = sort(s);
c = c(j);
h = h(j);

% Create the legend
if ~isempty(h)
   try
      legh = legend(ax,h,c,leginfo{:});
      set(legh,'Interpreter','none');        % Avoid TeX ds/fit names
      localFixContextMenu( legh );
   catch
   end
end

% Set a resize function that will handle legend and layout
set(dffig,'resizefcn','dfittool(''adjustlayout'');');

% ---------------------------------------------------------
function localFixContextMenu( hLegend )
% The legend gets created with a context menu. However this context menu
% has some features that have a destructive affect on DFITTOOL. In this
% little function, we remove those features....
cmh = get( hLegend, 'UIContextMenu' );
if isempty(cmh)
    return;
end

% The children (menu entries) of the context menu are hidden so we need
% to get around that
h = allchild( cmh );
if isempty(h)
    return
end

% Our actions are based on labels that appear in the context menu so we
% need to get all of those labels.
tags = get( h, 'Tag' );

% Delete the entries that cause bad things to happen
TAGS_TO_DELETE = {'scribe:legend:mcode', 'scribe:legend:propedit', 'scribe:legend:interpreter'};
tf = ismember( tags, TAGS_TO_DELETE );
delete( h(tf) );

% For the 'Delete' item, we want to redirect the call to the DFITTOOL
% legend toggle function
tf = ismember( tags, 'scribe:legend:delete' );
set( h(tf), 'Callback', @(s, e) dftogglelegend(gcbf, 'off'));

% For the 'Refresh' item, we want to redirect the callback to reset the
% properties of the legend, e.g., the colour and font.
tf = ismember( tags, 'scribe:legend:refresh' );
set( h(tf), 'Callback', @(s, e) dfupdatelegend(gcbf, true ) );
