function [cdata] = renderwebfigure(parameters, serialized, uid)
deploylog('finer', 'RENDERWEBFIGURE entered');

% all arguments must be present
error(nargchk(3, 3, nargin, 'struct'));

if ~isstruct(parameters) 
    error('MATLAB:renderwebfigure:IllegalArgument',...
          'renderwebfigure: parameters arugment must be a struct');
end

% Either create a new handle from the serialzed data or get existing one
% from the cache
hnd        = webfigurecache(uid, serialized);

% Make the figure visible for HG2
if feature('hgusingmatlabclasses')
    set(hnd,'Visible','on');
end

% Get the static information about the figure in the form of figInfo. figInfo
% has all the information about the figure and its children. The
% information includes position, units data for children of figure at
% various levels
figInfo    = getappdata(hnd,'figInfo');

% Analyze the passed in parameters and set the default values to those
% which haven't been provided in the render request.
parameters = setDefaultParams(figInfo,hnd,parameters);

% Crop the figure and get the cdata information
cdata      = cropFigureAndReturnCData(figInfo,parameters);

% Restore figure handle and all its children to their original units and
% positions. 
restoreFigure(figInfo,hnd);

deploylog('finer','leaving RENDERWEBFIGURE');

%---------------------------------------------------------------------
%---------------------------------------------------------------------
function cdata = cropFigureAndReturnCData(figInfo,parameters)

hnd         = figInfo.figHnd;
figChildren = figInfo.figChildren;

set(hnd,'unit','pixels');
set(figChildren,'unit','pixels');

% The view of the current axes should be changed only after changing the
% units of the figure and its children but before the cropping
currentAxes = figInfo.currentAxes;

if isfield(parameters, 'rotation') && isfield(parameters, 'elevation')
    set(currentAxes, 'View', [parameters.rotation,parameters.elevation]);
end

% Adjust positions of figure children, and the position of the figure
%  itself, to match the desired width/heigh + clip rect

clipRect = [parameters.cropLeft, parameters.cropBottom, ...
    parameters.width - (parameters.cropLeft + parameters.cropRight), ...
    parameters.height - (parameters.cropTop + parameters.cropBottom)];

deploylog('finer',sprintf('RENDERWEBFIGURE: clipRect is [%d,%d,%d,%d]',clipRect));

% create an extra buffer of pixels around the outside edge, because hardcopy does not
% always clip graphical objects with tiling in mind
extraRenderSpace = 32;

cellfun(@(childHnd, childPos) set(childHnd,'Position',...
            [childPos(1)*parameters.width - clipRect(1) + extraRenderSpace,...
             childPos(2)*parameters.height - clipRect(2) + extraRenderSpace,...
             childPos(3)*parameters.width, childPos(4)*parameters.height]),...
        num2cell(figChildren), figInfo.childlayout);

cellfun(@(childHnd) deploylog('finest',sprintf('Position of figure child is: [%d,%d,%d,%d]',...
                              get(childHnd,'Position'))),num2cell(figChildren));

set(hnd,'Position',[0, 200, clipRect(3) + extraRenderSpace*2, clipRect(4) + extraRenderSpace*2]);
deploylog('finer',sprintf('RENDERWEBFIGURE: set figure position to [0,200,%d,%d]',clipRect(3),clipRect(4)));

% Call outputMethod to get the cdata  
cdata = parameters.outputMethod(hnd);
cdata = cdata(extraRenderSpace:clipRect(4)-1+extraRenderSpace, extraRenderSpace:clipRect(3)-1+extraRenderSpace, :);

%---------------------------------------------------------------------
%---------------------------------------------------------------------
function restoreFigure(figInfo,hnd)

% Restore original view for the axis
set(figInfo.currentAxes, 'View',[figInfo.origView(1) figInfo.origView(2)]);

% Restore original Units and Position for the figure
set(hnd,'Units',figInfo.figOrigUnits);
set(hnd,'Position',figInfo.figOrigPos);
% Following call is required only for HG2
set(hnd,'visible','off');

figChildren          = figInfo.figChildren;
figChildrenOrigPos   = figInfo.figChildrenOrigPos;
figChildrenOrigUnits = figInfo.figChildrenOrigUnits;

setProperty('unit',figChildren,figChildrenOrigUnits);
setProperty('position',figChildren,figChildrenOrigPos);

%---------------------------------------------------------------------
%---------------------------------------------------------------------
function setProperty(propName, hdlArray, valArray)

if iscell(valArray)
    cellfun(@(ch,pos) set(ch,propName,pos), num2cell(hdlArray), valArray);
else
    cellfun(@(ch,pos) set(ch,propName,pos), num2cell(hdlArray), num2cell(valArray, 2));
end

%---------------------------------------------------------------------
%---------------------------------------------------------------------
function parameters = setDefaultParams(figInfo,hnd,parameters)

origFigPositionInPixel = figInfo.origFigPositionInPixel;

if ~isfield(parameters, 'width')
    parameters.width = origFigPositionInPixel(3);
end

if ~isfield(parameters, 'height')
    parameters.height = origFigPositionInPixel(4);
end

if ~isfield(parameters, 'cropLeft')
    parameters.cropLeft = 0;
end

if ~isfield(parameters, 'cropRight')
    parameters.cropRight = 0;
end

if ~isfield(parameters, 'cropTop')
    parameters.cropTop = 0;
end

if ~isfield(parameters, 'cropBottom')
    parameters.cropBottom = 0;
end   

if ~isfield(parameters, 'outputMethod')
    parameters.outputMethod = getappdata(hnd,'WebFigure_outputMethod');
    if isempty(parameters.outputMethod)
        % TODO - warn if HEADLESS
        parameters.outputMethod = @hardcopyOutput;
    end
end

