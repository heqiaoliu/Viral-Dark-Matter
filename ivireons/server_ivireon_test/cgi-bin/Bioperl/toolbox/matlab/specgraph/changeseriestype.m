function h2 = changeseriestype(h1, newtype)
%CHANGESERIESTYPE Change a series plot type
%  Helper function for Plot Tool. Do not call directly.

%  H2 = CHANGESERIESTYPE(H1,NEWTYPE) switches series with handle
%  H1 to a new handle with same data and type NEWTYPE. H1 can be
%  a vector of handles.

%   Copyright 1984-2009 The MathWorks, Inc. 

if feature('HGUsingMATLABClasses')
    h2 = changeseriestypeHGUsingMATLABClasses(h1,newtype);
    return
end
if ~any(strcmp(newtype,{'stem','line','bar','stairs','area'}))
  error(id('InvalidType'),'Only ''line'',''stem'',''stairs'',''area'' and ''bar'' types are supported.');
end
returnCellArray = false;
if iscell(h1)
    h1 = [h1{:}];
    returnCellArray = true;
end 
if isempty(h1), return; end
h1(~ishghandle(h1)) = [];
if isempty(h1)
  error(id('InvalidHandle'),'First argument must be a handle or vector of handles.');
end
N = length(h1);
cax = ancestor(h1(1),'axes');
switchprops = get(h1,'switchprops');
if N == 1
  vals = get(h1,switchprops);
  % replace FaceColor with Color after getting value
  facecolor = strcmp(switchprops,'FaceColor');
  if any(facecolor)
    switchprops{facecolor} = 'Color';
    vals{facecolor} = ensureRGB(cax,h1,vals{facecolor});
  end
else
  vals = cell(1,N);
  for k=1:N
    vals{k} = get(h1(k),switchprops{k});
    % replace FaceColor with Color after getting value
    props = switchprops{k};
    facecolor = strcmp(props,'FaceColor');
    if any(facecolor)
      props{facecolor} = 'Color';
      switchprops{k} = props;
      val = vals{k};
      val{facecolor} = ensureRGB(cax,h1(k),val{facecolor});
      vals{k} = val;
    end
  end
end

% TO DO: Remove the following conditions once hg objects use MCOS. MCOS
% hg objects use an instance property for oldswitchprops &
% oldswitchvals
oldswitch = get(h1,'oldswitchprops');
oldswitchvals = get(h1,'oldswitchvals');

if N > 1
  h2 = [];
  for n=1:N
    h2 = [h2;change_one_series(h1(n),switchprops{n},vals{n},oldswitch{n},oldswitchvals{n},newtype)];
  end
else
  h2 = change_one_series(h1,switchprops,vals,oldswitch,oldswitchvals,newtype);
end
h1(h1 == h2) = []; % don't delete objects that we want to keep

% MCOS baseline does not get removed when deleting the
% matlab.graphics.chart.primitive.Bar. Work around this for now until final behavior is
% decided.
if isa(h1,'matlab.graphics.chart.primitive.Bar') && ~isempty(h1)
    baseLine = get(h1,'baseLine');
    delete(h1);
    if ~isempty(baseLine) && isvalid(baseLine)
        delete(baseLine)
    end
else
    delete(h1);
end
plotdoneevent(cax,h2);
h2 = handle(h2); % plot tools expect handles not doubles
if (returnCellArray == true && length(h2) > 1)
    orig = h2;
    h2 = cell(1, length(orig));
    for i = 1:length(orig)
        h2{i} = orig(i);
    end
end


function h2=change_one_series(h1,switchprops,vals,oldswitch,oldswitchvals,newtype)
% compare newtype with existing class name of h1
cls = class(handle(h1));
if strcmp(newtype,'stairs')
  newcls = 'stairseries';
else
  newcls = [newtype 'series'];
end
if strncmpi(fliplr(cls),fliplr(newcls),length(newcls))
  h2 = h1;
  return;
end


% new type is different than existing type so go ahead and switch
for k=1:length(oldswitch)
  prop = oldswitch{k};
  val = oldswitchvals{k};
  if ~any(strcmp(prop,switchprops)) 
    switchprops = {switchprops{:},prop};
    vals = {vals{:}, val};
  end
end

% filter out properties that have the factory values
k = 1;
% TO DO: Exclude the following conditions for MCOS objects until factory 
% values are available.
while k < length(switchprops)
  prop = findprop(handle(h1),switchprops{k});
  if ~isempty(prop) && isequal(prop.FactoryValue, vals{k})
    switchprops(k) = [];
    vals(k) = [];
  else
    k = k+1;
  end
end


cax = get(h1,'parent');
ydata = get(h1,'ydata');

try
  if strcmp(get(h1,'xdatamode'),'manual')
    xdata = get(h1,'xdata');
    pvpairs = {'xdata',xdata,'ydata',ydata,'parent',cax};
  else
    pvpairs = {'ydata',ydata,'parent',cax};
  end
catch err
end

% treat Color and FaceColor as the same and preserve colors when
% changing. Default to not setting FaceColor. Area and Bar set this
% to true.
mapFaceColor = false;

switch newtype
 case 'line'
      lineseries('init');
      h2 = double(graph2d.lineseries(pvpairs{end-1:end}));
      set(h2,'XDataMode',get(h1,'XDataMode'));
      set(h2,pvpairs{1:end-2});
 case 'stem'
      h2 = specgraph.stemseries(pvpairs{:});
 case 'area'
      h2 = specgraph.areaseries(pvpairs{:});
      peers = find(handle(cax),'-class','specgraph.areaseries');
      set(peers,'AreaPeers',peers);
      mapFaceColor = true;
 case 'bar'
  h2 = specgraph.barseries(pvpairs{:});
  peers = find(handle(cax),'-class','specgraph.barseries');
  set(peers,'BarPeers',peers);
  mapFaceColor = true;
 case 'errorbar'
  h2 = specgraph.errorbarseries(pvpairs{:});
 case 'stairs'
  h2 = specgraph.stairseries(pvpairs{:});
end

for k=1:length(switchprops)
  try
    if mapFaceColor && strcmp(switchprops{k},'Color')
      set(h2,'FaceColor',vals{k});
    else
      set(h2,switchprops{k},vals{k});
    end
  catch err
  end
end
if isprop(h2,'RefreshMode')
  set(h2,'RefreshMode','auto');
end

set(h2,'oldswitchprops',switchprops);
set(h2,'oldswitchvals',vals);
h2 = double(h2);

% Carry over the "Tag" and "UserData" properties from the original handle:
set(h2,'Tag',get(h1,'Tag'),'UserData',get(h1,'UserData'));

function color = ensureRGB(ax, h, color)
if ischar(color)
  fig = ancestor(ax,'figure');
  cmap = get(fig,'Colormap');
  if isempty(cmap), return; end   
  clim = get(ax,'CLim');
  fvdata = get(get(h,'children'),'FaceVertexCData');
  seriesnum = fvdata(1);
  color = (seriesnum-clim(1))/(clim(2)-clim(1));
  ind = max(1,min(size(cmap,1),floor(1+color*size(cmap,1))));
  color = cmap(ind,:);
end

function str=id(str)
str = ['MATLAB:changeseriestype:' str];
