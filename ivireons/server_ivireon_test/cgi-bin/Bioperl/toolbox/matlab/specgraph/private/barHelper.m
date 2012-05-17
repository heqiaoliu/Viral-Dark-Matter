function varargout = barHelper(functionName,varargin)
% This function is undocumented and may change in a future release.

%   Copyright 2008 The MathWorks, Inc.

% Switchyard for helper functions used by the BAR and BARH commands.
%   Function name may be one of:
%      computeBars - Returns the delta, dt and yOffset for the bars based
%      on the state of the Bar object.
%      addListeners - Sets up the necessary callbacks to mimic having peers
%      of a Bar object.
%      updateTicks - Updates the ticks on the axes.

error(nargchk(1,inf,nargin,'struct'));

if ~ischar(functionName)
    error('MATLAB:barHelper:firstInputString','The first input argument must be a string.');
end

switch(functionName)
    case 'computeBars'
        [varargout{1} varargout{2} varargout{3}] = localComputeBars(varargin{:});
    case 'addListeners'
        localAddListeners(varargin{:});
    case 'updateTicks'
        localUpdateTicks(varargin{:});
    otherwise
        error('MATLAB:barHelper:unrecognizedFunction',...
            'The first input argument is an unrecognized function name');
end

%-------------------------------------------------------------------------%
function [delta,dt,yOffset] = localComputeBars(numBars,numSeries,isGrouped,equalBarSpacing,x,y,maxX,minX)

% Calculate the Y-offset:
yOffset = [];
if ~isGrouped && (numSeries>1)
    ySum = cumsum(y,2);
    yOffset = [zeros(numBars,1),ySum(:,1:end-1)];
end

% Determine the width of each bar:
groupWidth = 0.8;
if numSeries == 1 || ~isGrouped
    groupWidth = 1;
else
    groupWidth = min(groupWidth,numSeries/(numSeries+1.5));
end
singleBar = false;
if numBars==1
    singleBar = true;
end
% Figure out the delta between bars
if singleBar
    delta = 1;
    dt = 0;
elseif equalBarSpacing
    if isGrouped
        delta = (maxX-minX)*groupWidth/(numBars-1)/numSeries;
        dt = -0.5*delta*(numSeries-1);
    else
        % There is no offset for stacked bar plots, we precompute values to
        % make sure that the "XOffset" will end up being zero for all bars.
        delta = ones(size(maxX));
        dt = (0:numel(delta)-1).*delta*(-1);
    end
else
    dx = min(diff(sort(x)));
    if isGrouped
        delta = dx*groupWidth/numSeries;
        dt = -0.5*delta*(numSeries-1);
    else
        % There is no offset for stacked bar plots, we precompute values to
        % make sure that the "XOffset" will end up being zero for all bars.
        delta = ones(size(dx));
        dt = (0:numel(delta)-1).*delta*(-1);
    end
end

%-------------------------------------------------------------------------%
function localAddListeners(hBars)

if ~isempty(hBars)
    
    % Add listeners to key properties to mimic changing properties of the
    % peers:
    addlistener(hBars,{'BarWidth','Horizontal'},'PostSet',@localUpdatePeers);
    addlistener(hBars,'BarLayout','PostSet',@localUpdatePeersAndRecomputeLayout);
    addlistener(hBars,{'XData','YData','XDataMode'},'PostSet',@localRecomputeLayout);
    % Add a listener to any properties that may require us to update the
    % ticks appropriately:
    addlistener(hBars,{'Horizontal','XData','YData','XDataMode'},'PostSet',@localTickCallback);
end

%-------------------------------------------------------------------------%
function localTickCallback(obj,evd) %#ok<INUSL>
% Given a change to the "Horiztonal" property, update the axes ticks
% appropriately

% If the axes is held, bail out early:
hBar = evd.AffectedObject;
hAx = ancestor(hBar,'axes');

if ishold(hAx)
    return;
end

% Set up the ticks on the axes:
if strcmp(get(hBar,'Horizontal'),'on')
    yTickString = 'YTick';
    xTickString = 'XTickMode';
else
    yTickString = 'XTick';
    xTickString = 'YTickMode';
end
localUpdateTicks(hAx,xTickString,yTickString,get(hBar,'XData'));

%-------------------------------------------------------------------------%
function localUpdatePeers(obj,evd)
% Given a property change, update the same property on the peers of the
% Bar object. A peer is defined to be all Bar objects sharing a parent with the
% affected object.
hBar = evd.AffectedObject;
hPeers = findobj(hBar.Parent,'-class','matlab.graphics.chart.primitive.Bar');
hPars = get(hPeers,'Parent');
if ~iscell(hPars)
    % We only have the one bar, short-circuit
    return;
end
% Since we don't have a "depth" flag for findobj yet filter on the parent:
hPeers = hPeers(cellfun(@(x)(isequal(x,hBar.Parent)),hPars));
% Remove the object from the list of peers as well:
hPeers(hPeers == hBar) = [];
% Set the internal property that was changed on the bar:
for i=1:numel(hPeers)
    set(hPeers(i),[obj.Name '_I'],get(hBar,obj.Name));
end

%-------------------------------------------------------------------------%
function localRecomputeLayout(obj,evd) %#ok<INUSL>
% Recompute the layout for the bars

hBar = evd.AffectedObject;
hPeers = findobj(hBar.Parent,'-class','matlab.graphics.chart.primitive.Bar');
hPars = get(hPeers,'Parent');
if ~iscell(hPars)
    % We only have the one bar, set some defaults and bail out
    set(hBar,'XOffset',0,'YOffset',[],'WidthScaleFactor',1);
    return;
end
% Since we don't have a "depth" flag for findobj yet filter on the parent:
hPeers = hPeers(cellfun(@(x)(isequal(x,hBar.Parent)),hPars));
numSeries = numel(hPeers);

% We need to manually assemble an XData and YData matrix here since the
% peers may have ragged data:
xData = get(hPeers,'XData');
yData = get(hPeers,'YData');
yLen = max(cellfun('length',yData));
xLen = max(cellfun('length',xData));
maxLen = max(yLen,xLen);
yDataFull = repmat(hBar.BaseValue,maxLen,numSeries);
xDataFull = zeros(maxLen,numSeries);
for i = 1:numSeries
    yDat = yData{i};
    xDat = xData{i};
    yDataFull(1:length(yDat),i) = yDat(:);
    xDataFull(1:length(xDat),i) = xDat(:);
end
y = yDataFull;
x = xDataFull;

% In order to return meaningful information for empty
% inputs, we will convert any empty input to be of size 0xnumSeries
if isempty(xData)
    x = zeros(0,numSeries);
end
if isempty(yData)
    y = zeros(0,numSeries);
end

% Figure out if the bar spacing is equal
if max(abs(diff(diff(sort(x))))) <= max(max(abs(x)))*sqrt(eps(class(x)))
    equalBarSpacing = true;
end

% Compute the max and min x
maxX = max(x);
minX = min(x);

% Determine whether we will be grouped
isGrouped = strcmpi(hBar.BarLayout,'grouped');
% Determine the number of bars
numBars = size(y,1);

[delta,dt,yOffset] = localComputeBars(numBars,numSeries,isGrouped,equalBarSpacing,x,y,maxX,minX);

% Set the computed properties on the bar and its peers:
for i=0:numSeries-1
    yOffsetVal = [];
    if ~isempty(yOffset)
        yOffsetVal = yOffset(:,i+1);
    end
    set(hPeers(i+1),'XOffset',dt(i+1)+delta(i+1)*i,...
        'WidthScaleFactor',delta(i+1),'YOffset',yOffsetVal);
end

%-------------------------------------------------------------------------%
function localUpdatePeersAndRecomputeLayout(obj,evd)
% Given a property change that requires a recomputation of the layout,
% and and updating of the peers, update the peers and recompute the layout.

% First, update the peers:
localUpdatePeers(obj,evd);
% Next, recompute the layout:
localRecomputeLayout(obj,evd);

%-------------------------------------------------------------------------%
function localUpdateTicks(hAx,xTickString,yTickString,x)
% Update the axes ticks based on the bars:

yTickData = get(hAx,yTickString);
sortedX = sort(x);
% Set ticks if less than 16 integers and matches previous
if ~isappdata(hAx,['barseries' yTickString]) || ...
        isequal(yTickData,getappdata(hAx,['barseries' yTickString])) || ...
        strcmp(get(hAx,[yTickString 'Mode']),'auto')
    set(hAx,[yTickString 'Mode'],'auto')
    if all(all(floor(sortedX)==sortedX)) && (length(sortedX)<16)
        xDiff = diff(sortedX);
        if all(xDiff > 0)
            set(hAx,yTickString,sortedX)
        end
        set(hAx,xTickString,'auto')
    end
    setappdata(hAx,['barseries' yTickString],get(hAx,yTickString));
end