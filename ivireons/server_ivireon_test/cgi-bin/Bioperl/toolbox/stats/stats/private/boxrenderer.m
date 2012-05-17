function hgg=boxrenderer(ax, factorCenterPosition, boxDataWidth, ...
    orientation, varargin)

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:23 $


if isempty(ax)
    ax=gca;
end
%factorCenterPosition has one element per group
factorCenterPosition = factorCenterPosition(:);
boxDataWidth = boxDataWidth(:);

switch orientation
    case 'vertical', factorsOnXAxis=1;
    case 'horizontal', factorsOnXAxis=0;
    otherwise
        error('stats:boxrenderer:BadOrientation',...
            'Bad value for ''Orientation'' parameter');
end

numgroups = size(factorCenterPosition,1);
if ~ismember(length(boxDataWidth),[1 numgroups])
    error ('stats:boxrenderer:badBoxDataWidthSize', ...
        'boxDataWidth must be either a scalar or a vector numgroups long');
end

if mod(length(varargin),2) == 1 || ~iscellstr(varargin(1:2:end)) || ...
        ~all(cellfun(@iscell,varargin(2:2:end)))
    error ('stats:boxrenderer:badSubFuncHandle', ...
        ['Parameter names must be strings, and sub-argument lists ',...
        'must be cell arrays']);
end

numsubfuncs = length(varargin)/2;

h=NaN(numgroups,numsubfuncs);

for subfuncindex = 1:numsubfuncs
    subfunc = varargin{(subfuncindex-1)*2+1};
    % %%%%%%%%%%%%%%%%
    % The next line lists the supported sub-functions
    % %%%%%%%%%%%%%%%%%%%%
    if ~ismember(subfunc, ...
            {'marker','lineAlongResponse','lineAlongFactor', ...
            'lineBox','lineBoxNotched'} )
        % %%%%%%%%%%%%%%%%%%%%%%%
        error('stats:boxrenderer:badSubFuncHandle', ...
            'Unrecognized subfunction handle');
    end
    subfunc(1)=upper(subfunc(1)); % CamelCase the subfunc name.
    funcname = ['draw' subfunc];
    h(:,subfuncindex) = feval(funcname,ax, numgroups, ...
        factorCenterPosition, boxDataWidth, factorsOnXAxis, ...
        varargin{(subfuncindex-1)*2+2});
end

hgg = h';

end

%% drawMarker function
%used for outliers, and for medians drawn as one dot
%
%scalar args apply to all groups
%vector args have one item per group
%cell arrays of vectors have one item per each item in the group
function h=drawMarker(hgg, numgroups, ...
    factorCenterPosition, boxDataWidth, factorsOnXAxis, varargin)

%varargout = parseSubfuncArgs(argValues, argNames, defaults)
[     location,  jitter,  offset,  markertype,  markersize,  markercolor,  markerfill,  tag] = ...
    parseSubfuncArgs(varargin, ...
    {'location','jitter','offset','markertype','markersize','markercolor','markerfill','tag'}, ...
     {[],        0,       0,       'o',         6,          [0 0 1],      'n',         ''  }  );

h=NaN(numgroups,1);
if isempty(location)
    %kick out if no points to plot 
    return;
end

%complain about args that should not have a vector worth of values for each
%group
if iscell(markertype) || iscell(markersize) || iscell(markercolor) || ...
        iscell(markerfill)
    error('stats:boxrenderer:TooManyLineStylesPerGroup',...
        'You can have only one marker style per group');
end

%render as one line per group
for currentGroup = 1:numgroups
    %unpack data for this group, put into grp variables
    %This unpacking should be put into its own subfunction or something
    %unpack bundle start
    [grpLocation,grpJitter,grpOffset,grpMarkertype,grpMarkersize,grpMarkerfill,grpBoxDataWidth] = ...
        unpackGroup(currentGroup, ...
       location,  jitter,  offset,  markertype,  markersize,  markerfill,  boxDataWidth);
    numInGroup = length(grpLocation);
    if numInGroup == 0
        [grpLocation,grpJitter,grpOffset,grpMarkertype,grpMarkersize,grpMarkerfill,grpBoxDataWidth] = ...
            unpackGroup(currentGroup, ...
            nan,  jitter,  nan,  markertype,  markersize,  markerfill,  boxDataWidth);
        numInGroup = 1;
    end    
    
    grpMarkercolor = unpackGroupColor(currentGroup,markercolor);
    if strcmp(grpMarkertype,'n')
        grpMarkertype = 'none';
    end
    
    %compute factor axis position for each point
    %the random number will need to be replaced later with a hash
    %based on some data index, for the repeatability needed for
    %brushing
    if grpJitter==0
        jitterOffset=zeros(numInGroup,1);
    else
        jitterOffset = grpJitter .* (rand(numInGroup,1)-.5);
    end
    factorValue = factorCenterPosition(currentGroup) + ...
        grpBoxDataWidth .* jitterOffset + ...
        grpBoxDataWidth .* grpOffset * .5;
    
    if factorsOnXAxis==1
        x=factorValue;
        y=grpLocation;
    else
        x=grpLocation;
        y=factorValue;
    end
    switch(grpMarkerfill)
        case 'n', markerfacecolor = 'none';
        case 'b', markerfacecolor = 'auto';
        case 'f', markerfacecolor = grpMarkercolor;
        otherwise,
            error('stats:boxrenderer:BadMarkerFill',...
                ['Marker Fill must be n, b, or f, for none, ',...
                'background, or filled']);
            
    end
    h(currentGroup) = line(x,y, ...
        'marker',grpMarkertype,...
        'markerSize',grpMarkersize,...
        'markerEdgeColor',grpMarkercolor,...
        'lineStyle','none',...
        'markerfacecolor',markerfacecolor,...
        'tag',tag,...
        'parent',hgg);

end

 
end

%% drawLineAlongResponse
%used for whiskers and fixed pixel width boxes
% Width is in pixels
%

function h=drawLineAlongResponse(hgg, numgroups, ...
    factorCenterPosition, boxDataWidth, factorsOnXAxis, varargin)

%varargout = parseSubfuncArgs(argValues, argNames, defaults)
[     locationStart,  locationEnd,  lineStyle,  lineWidth,  lineColor, tag] = ...
    parseSubfuncArgs(varargin, ...
    {'locationstart','locationend','linestyle','linewidth','linecolor','tag'}, ...
    {[],              [],          '-',        .5,         [0 0 1],    ''}  );

h=NaN(numgroups,1);
if isempty(locationStart)
    %kick out if no lines to plot
    return;
end

%complain about args that should not have a vector worth of values for each
%group
if iscell(lineStyle) || iscell(lineWidth) || iscell(lineColor)
    error('stats:boxrenderer:TooManyLineStylesPerGroup',...
        ['You can have only one line width and color per group, '...
        ' and one line style for all the groups']);
end

%render as one line per group
for currentGroup = 1:numgroups
    %unpack data for this group, put into grp variables
    %This unpacking should be put into its own subfunction or something
    %unpack bundle start
    [grpLocationStart,grpLocationEnd,grpLineWidth] = ...
        unpackGroup(currentGroup, ...
       locationStart,  locationEnd,  lineWidth); 

    numInGroup = length(grpLocationStart);
    if numInGroup == 0
        [grpLocationStart,grpLocationEnd,grpLineWidth] = ...
            unpackGroup(currentGroup, ...
            nan,  nan,  lineWidth);
        numInGroup = 1;
    end
    
    grpLineColor = unpackGroupColor(currentGroup,lineColor);
    
    factor = nan(3*numInGroup-1,1);
    response = nan(3*numInGroup-1,1);
    factor(1:3:end)=factorCenterPosition(currentGroup);
    response(1:3:end) = grpLocationStart;
    factor(2:3:end)=factorCenterPosition(currentGroup);
    response(2:3:end) = grpLocationEnd;
    
    if factorsOnXAxis==1
        x=factor;
        y=response;
    else
        x=response;
        y=factor;
    end
    
    h(currentGroup) = line(x,y, ...
        'Marker','none',...
        'Color',grpLineColor,...
        'LineWidth',grpLineWidth,...
        'LineStyle',lineStyle,...
        'Tag',tag,...
        'Parent',hgg);
    
end

end


%% drawLineAlongFactor
%used for medians drawn as lines, and for whisker ends
function h=drawLineAlongFactor(hgg, numgroups, ...
    factorCenterPosition, boxDataWidth, factorsOnXAxis, varargin)

%varargout = parseSubfuncArgs(argValues, argNames, defaults)
[     location,  lineLength,  lineStyle,  lineWidth,  lineColor,  tag] = ...
    parseSubfuncArgs(varargin, ...
    {'location','linelength','linestyle','linewidth','linecolor','tag'}, ...
    { [],        1,          '-',        .5,         [0 0 1],    ''}  );
      
h=NaN(numgroups,1);

if isempty(location)
    return;
end

%complain about args that should not have a vector worth of values for each
%group
if iscell(lineStyle) || iscell(lineWidth) || iscell(lineColor)
    error('stats:boxrenderer:TooManyLineStylesPerGroup',...
        ['You can have only one line width and color per group, '...
        ' and one line style for all the groups']);
end


%render as one line per group
for currentGroup = 1:numgroups
    %unpack data for this group, put into grp variables
    %This unpacking should be put into its own subfunction or something
    %unpack bundle start
    [grpLocation,grpLineLength,grpLineWidth,grpBoxDataWidth] = ...
        unpackGroup(currentGroup, ...
       location,  lineLength,  lineWidth,  boxDataWidth);
    numInGroup = length(grpLocation);
    if numInGroup == 0
        [grpLocation,grpLineLength,grpLineWidth,grpBoxDataWidth] = ...
            unpackGroup(currentGroup, ...
            nan,  lineLength,  lineWidth,  boxDataWidth);
        numInGroup = 1;
    end
    
    grpLineColor = unpackGroupColor(currentGroup,lineColor);
    
    factor = nan(3*numInGroup-1,1);
    response = nan(3*numInGroup-1,1);
    factor(1:3:end)=factorCenterPosition(currentGroup) - ...
        grpBoxDataWidth.*grpLineLength./2;
    response(1:3:end) = grpLocation;
    factor(2:3:end)=factorCenterPosition(currentGroup) + ...
        grpBoxDataWidth.*grpLineLength./2;
    response(2:3:end) = grpLocation;
    
    if factorsOnXAxis==1
        x=factor;
        y=response;
    else
        x=response;
        y=factor;
    end
    
    h(currentGroup) = line(x,y, ...
        'Marker','none',...
        'Color',grpLineColor,...
        'LineWidth',grpLineWidth,...
        'LineStyle',lineStyle,...
        'Tag',tag,...
        'Parent',hgg);
    
end


end



%% drawLineBox
%used for data width filled boxes
function h=drawLineBox(hgg, numgroups, ...
    factorCenterPosition, boxDataWidth, factorsOnXAxis, varargin)

%varargout = parseSubfuncArgs(argValues, argNames, defaults)
[     locationStart,  locationEnd,  lineStyle,  lineWidth,  lineColor,  tag] = ...
    parseSubfuncArgs(varargin, ...
    {'locationstart','locationend','linestyle','linewidth','linecolor','tag'}, ...
    {[],              [],          '-',         .5,         [0 0 1],   ''}  );
      

h=NaN(numgroups,1);

if isempty(locationStart)
    return;
end

%complain about args that should not have a vector worth of values for each
%group
if iscell(lineStyle) || iscell(lineWidth) || iscell(lineColor)
    error('stats:boxrenderer:TooManyLineStylesPerGroup',...
        ['You can have only one line width and color per group, '...
        ' and one line style for all the groups']);
end


%render as one line per group
for currentGroup = 1:numgroups
    %unpack data for this group, put into grp variables
    %This unpacking should be put into its own subfunction or something
    %unpack bundle start
    [grpLocationStart,grpLocationEnd,grpLineWidth,grpBoxDataWidth] = ...
        unpackGroup(currentGroup, ...
       locationStart,  locationEnd,  lineWidth,  boxDataWidth);
    numInGroup = length(grpLocationStart);
    if numInGroup == 0
        [grpLocationStart,grpLocationEnd,grpLineWidth,grpBoxDataWidth] = ...
            unpackGroup(currentGroup, ...
            nan,  nan,  lineWidth,  boxDataWidth);
        numInGroup = 1;
    end
    
    grpLineColor = unpackGroupColor(currentGroup,lineColor);

    factor = nan(6*numInGroup-1,1);
    response = nan(6*numInGroup-1,1);
    %lower left (assuming factorsOnXAxis == 0)
    factor(1:6:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(1:6:end) = grpLocationStart;
    %upper left
    factor(2:6:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(2:6:end) = grpLocationEnd;
    %upper right
    factor(3:6:end)=factorCenterPosition(currentGroup)+grpBoxDataWidth./2;
    response(3:6:end) = grpLocationEnd;
    %lower right
    factor(4:6:end)=factorCenterPosition(currentGroup)+grpBoxDataWidth./2;
    response(4:6:end) = grpLocationStart;
    %lower left, same as starting point
    factor(5:6:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(5:6:end) = grpLocationStart;

    if factorsOnXAxis==1
        x=factor;
        y=response;
    else
        x=response;
        y=factor;
    end

    h(currentGroup) = line(x,y, ...
        'Marker','none',...
        'Color',grpLineColor,...
        'LineWidth',grpLineWidth,...
        'LineStyle',lineStyle,...
        'tag',tag,...
        'Parent',hgg);

end

end



%% drawLineBoxNotched
%used for data width filled boxes
function h=drawLineBoxNotched(hgg, numgroups, ...
    factorCenterPosition, boxDataWidth, factorsOnXAxis, varargin) 

%varargout = parseSubfuncArgs(argValues, argNames, defaults)
[     locationStart,  locationEnd,  notchStart,  notchMiddle,  notchEnd, ...
        notchDepth,  lineStyle,  lineWidth,  lineColor,  tag] = ...
    parseSubfuncArgs(varargin, ...
    {'locationstart','locationend','notchstart','notchmiddle','notchend',...
        'notchdepth','linestyle','linewidth','linecolor','tag'}, ...
    { [],             [],           [],          [],           [], ...
         .5,         '-',         .5,        [0 0 1],    ''}  );
      

h=NaN(numgroups,1);

if isempty(locationStart)
    return;
end

%complain about args that should not have a vector worth of values for each
%group
if iscell(lineStyle) || iscell(lineWidth) || iscell(lineColor)
    error('stats:boxrenderer:TooManyLineStylesPerGroup',...
        ['You can have only one line width and color per group, '...
        ' and one line style for all the groups']);
end

%render as one line per group
for currentGroup = 1:numgroups
    %unpack data for this group, put into grp variables
    %This unpacking should be put into its own subfunction or something
    %unpack bundle start
    [grpLocationStart,grpLocationEnd,grpNotchStart,grpNotchMiddle,grpNotchEnd,...
        grpNotchDepth,grpLineWidth,grpBoxDataWidth] = ...
        unpackGroup(currentGroup, ...
       locationStart,  locationEnd,  notchStart,  notchMiddle,  notchEnd, ...
          notchDepth,  lineWidth,  boxDataWidth);
    numInGroup = length(grpLocationStart);
    if numInGroup == 0
        [grpLocationStart,grpLocationEnd,grpNotchStart,grpNotchMiddle,grpNotchEnd,...
            grpNotchDepth,grpLineWidth,grpBoxDataWidth] = ...
            unpackGroup(currentGroup, ...
            nan,  nan,  nan,  nan,  nan, ...
            notchDepth,  lineWidth,  boxDataWidth);
        numInGroup = 1;
    end
    
    grpLineColor = unpackGroupColor(currentGroup,lineColor);
    
    %removed notches that are nan's
    grpNotchStart(isnan(grpNotchStart)) = ...
        grpNotchMiddle(isnan(grpNotchStart));
    grpNotchEnd(isnan(grpNotchEnd)) = grpNotchMiddle(isnan(grpNotchEnd));
    
    factor = nan(12*numInGroup-1,1);
    response = nan(12*numInGroup-1,1);
    %left middle of box, at the median (assuming factorsOnXAxis ==0)
    factor(1:12:end)=factorCenterPosition(currentGroup) ...
        -(1-grpNotchDepth).*grpBoxDataWidth./2;
    response(1:12:end) = grpNotchMiddle;
    %left of box, at top of notch
    factor(2:12:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(2:12:end) = grpNotchEnd;
    %left of box, at top of box
    factor(3:12:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(3:12:end) = grpLocationEnd;
    %right of box, at top of box
    factor(4:12:end)=factorCenterPosition(currentGroup)+grpBoxDataWidth./2;
    response(4:12:end) = grpLocationEnd;
    %right of box, at top of notch
    factor(5:12:end)=factorCenterPosition(currentGroup)+grpBoxDataWidth./2;
    response(5:12:end) = grpNotchEnd;
    %right middle of box, at the median
    factor(6:12:end)=factorCenterPosition(currentGroup) ...
        +(1-grpNotchDepth).*grpBoxDataWidth./2;
    response(6:12:end) = grpNotchMiddle;
    %right of box, at bottom of notch
    factor(7:12:end)=factorCenterPosition(currentGroup)+grpBoxDataWidth./2;
    response(7:12:end) = grpNotchStart;
    %right of box, at bottom of box
    factor(8:12:end)=factorCenterPosition(currentGroup)+grpBoxDataWidth./2;
    response(8:12:end) = grpLocationStart;
    %left of box, at bottom of box
    factor(9:12:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(9:12:end) = grpLocationStart;
    %left of box, at bottom of notch
    factor(10:12:end)=factorCenterPosition(currentGroup)-grpBoxDataWidth./2;
    response(10:12:end) = grpNotchStart;
    %left of box, at middle of notch
    factor(11:12:end)=factorCenterPosition(currentGroup)...
        -(1-grpNotchDepth).*grpBoxDataWidth./2;
    response(11:12:end) = grpNotchMiddle;
    
    
    
    
    if factorsOnXAxis==1
        x=factor;
        y=response;
    else
        x=response;
        y=factor;
    end
    
    h(currentGroup) = line(x,y, ...
        'Marker','none',...
        'Color',grpLineColor,...
        'LineWidth',grpLineWidth,...
        'LineStyle',lineStyle,...
        'Tag',tag,...
        'Parent',hgg);
    
end

end



%%
%expect color to be a length 3 vector, a nx3 matrix (where n is the number
%of groups), or an n-long cell array of mx3 matrices (where m is the number
%of points in the given group).
function groupColor = unpackGroupColor(groupindex, colorInputArg)
if iscell(colorInputArg)
    groupColor = colorInputArg{groupindex};
    if size(groupColor,1)~=3
        error('stats:boxrenderer:ColorMustBeLength3Vectors', ...
            'Color must be specified as RGB triples');
    end
elseif ischar(colorInputArg)
    if isscalar(colorInputArg)
        groupColor= colorInputArg;
    elseif isvector(colorInputArg)
        groupColor=colorInputArg(groupindex);
    else
        error('stats:boxrenderer:unexpectedDataType', ...
            ['color specified as character must be a single character '...
            'or a character array numgroups long']);
    end
else
    sz=size(colorInputArg);
    if ~ismember(3,sz)
        error('stats:boxrenderer:ColorMustBeLength3Vectors', ...
            'Color must be specified as RGB triple vectors');
    end
    if ismember(1,sz)
        groupColor = colorInputArg;
    else
        if sz(2)~=3
            error('stats:boxrenderer:MultipleColorsMatrixShape', ...
                ['Multiple color must be specified as a 3 column ',...
                'matrix of RGB triples']);
        end
        groupColor = colorInputArg(groupindex,:);
    end
end

end

%%
function varargout = unpackGroup (groupindex,varargin)
numvars = length(varargin);

%handle scalar, vector, or cell array of vectors
%verify that all items in this group are the same length, or scalar
if any(cellfun(@iscell,varargin))
    vectlens = ones(numvars+1,1);
    for i=1:numvars
        if iscell(varargin{i})
            vectlens(i) = length(varargin{i}{groupindex});
        end
    end
    %return all empties if one of the inputs is empty
    if min(vectlens)==0
        varargout{numvars}=[];
        return;
    end
    %error check
    if length(unique(vectlens))>2
        error('stats:boxrenderer:vectLenMismatchWithinGroup', ...
            ['when passing in multiple values per group, ', ...
            'there must be the same number of values in each group']);
    end
    %vectlen = max(vectlens);
end

%unpack data for each group, return as a vector for each group
for i=1:numvars
    currentvar = varargin{i};
    if iscell(currentvar)
        varargout{i}=currentvar{groupindex};
    elseif isscalar(currentvar)
        varargout{i}= currentvar;
    elseif isvector(currentvar)
        varargout{i}=currentvar(groupindex);
    else
        error('stats:boxrenderer:unexpectedDataType', ...
            ['Subfunction arg must be a scalar, a vector, ' , ...
            'or a cell array of vectors']);
    end
end


end


%%
function varargout = parseSubfuncArgs(argValues, argNames, defaults)
numargs = length(defaults);

if ischar(argValues{1}{1})
    varargout{numargs}=[];
    %parse as parameter-value pairs, permitting optional args
    [eid,emsg,varargout{:}] = ...
        internal.stats.getargs(argNames,defaults,argValues{1}{:});
    if ~isempty(eid)
        error(sprintf('stats:boxrenderer:%s',eid),emsg);
    end
else
    %parse as fixed parameters, with no optional args and minimal error
    %checking
    varargout = argValues{1};
end

% Do an error check on the args - vectors and cell inputs must be numgroups
% long; scalars are also ok.
% A tweak is needed for color and linestyle
% length 0 is considered invalid, and will cause an error.
numels = ones(numargs+1,1);
for i=1:numargs
    numels(i)=length(varargout{i});
end
%tweak for certain color cases...
%avoid spurious warning for color specifications, if 1 or 2 colors are
%specificed
% 1 color is a 3x1 or 1x3 vector, 2 colors are a 2x3 matrix.
%these ought to be counted as 1 and 2 respectively, but are instead counted
%as 3 by the code above.
%Do this after the initial check to avoid string matching for all the args
maybeColorArgs = find(numels==3);
if ~isempty(maybeColorArgs)
    for i=maybeColorArgs'
        %c might be cap or lower case, so don't search on it
        %cells and char shortcut names are handled fine with the general
        %case
        if ~isempty(strfind(argNames{i},'olor')) && ...
                ~iscell(varargout{i}) && ~ischar(varargout{i})
            sz = size(varargout{i}); %already know one dim is size 3
            if sz(1)==1 || sz(2)==1
                numels(i)=1;
            end
            if sz(1)==2
                numels(i)=2;
            end
        end
    end
end
%tweak for linestyle string; lineStyle must be a scalar
LineStyleArg = strmatch('linestyle',argNames,'exact');
if ~isempty(LineStyleArg)
    lineStyleTemp = ismember(varargout{LineStyleArg},...
        {'-','--',':','-.','none'});
    if length(lineStyleTemp)>1 || ~lineStyleTemp
        error('stats:boxrenderer:TooManyLineStylesPerAxis',...
            'You can have only one line style for all the groups');
    else
        numels(LineStyleArg)=1; %make the error check pass
    end
end
%tweak for tag string; tag must be a string
tagArg = strmatch('tag',argNames,'exact');
if ~isempty(tagArg)
    tagval = varargout{tagArg};
    if ischar(tagval)
        numels(tagArg)=1;
    else
        error('stats:boxrenderer:TagMustBeString',...
            'Tag must be set to a string, or '''' ');
    end
end

%do the check
if (length(unique(numels)))>2
    error ('stats:boxrenderer:unequalNumGroups',...
        'Vectors and cell arrays of vectors must be uniform length');
end


end
