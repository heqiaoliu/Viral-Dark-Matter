function varargout = renderframe2(varargin)
% RENDERFRAME Renders the simulink frame and model onto a portal and
% returns it. Do not call from command line. This function will be called
% by 'simprintdlg' and 'render' functions.

% Sridhar Ramaswamy
% Copyright 1990-2007 The MathWorks, Inc.

persistent frameInfo;

action = varargin{1};

switch action
    case 'initialize'
        frameFig = varargin{2};
        numSys = varargin{3};
        
        frameInfo = LInit(frameFig, frameInfo, numSys);
        varargout{1} = frameInfo;
        
    case 'render'
        sysObj = varargin{2};

        % If the portal is passed in, then the portal is setup and ready to go.  This
        % happens in the Report Generator Stateflow Snapshot Component.
        if (nargin > 2);
            portal = varargin{3};
        else
            portal = [];
        end

        % Render the object with frames
        [portal frameInfo sysObj portalRectForSys] = LRender(sysObj,frameInfo,portal);

        varargout{1} = portal;
        varargout{2} = sysObj;
        varargout{3} = portalRectForSys; % frame bounding block diagram
        
    case 'reset'
        frameInfo = [];
        varargout = {};
    otherwise
        error('Simulink:InvalidRenderFrameAction','Invalid action supplied to renderframe: %s',action);
end
%--------------------------------------------------------------------------
function frameinfo = LInit(fig, frameinfo, nsys)
% Initialize static stuff that will be printed on the page like date, time,
% page, number of pages etc.

% load the frame as a mat file
try
    figInfo = load('-mat',fig);
catch me
    error('Simulink:InvalidFrameFigure','Could not load the figure %s as mat file',fig);
end

% initialize the frameinfo structure
if(isempty(frameinfo))
    frameinfo = struct('date',datestr(now,1),'time',datestr(now,15),'npages',nsys,'page',0);
end

% save the frame's orientation
frameinfo.orientation = LGetFrameOrientation(figInfo);

% save the frame's paper type
frameinfo.papertype = LGetFramePaperType(figInfo);

% first get the axes
figAxes = LGetHGAxesFromFig(figInfo);

% ... then we need to get the patches ...
patches = LGetHGTypeFromAxes(figAxes,'patch');

% save the patch vertices
frameinfo.vertices = LGetHGPropForType(patches,'Vertices');

% ... and then the texts of the patches
frameinfo.texts = LGetHGTypeFromAxes(figAxes,'text');

% save whether to treat points as pixels
% xxx (Check with Eric Lim)
%frameinfo.treatPointsAsPixels = treatPointsAsPixels;

% Get paper margins
frameinfo.margins = LGetPaperMargins(frameinfo);

%--------------------------------------------------------------------------
function [portal frameinfo sysobj portalRectForSys] = LRender(sysobj, frameinfo, portal)
% Given the portal, system object and frame information, render the frame as
% well as the model onto the frame.

pointsPerInch = 72;
ppi = get(0,'ScreenPixelsPerInch')/pointsPerInch;

frameinfo.page = frameinfo.page + 1;

% If portal is not passed in, then use model properties
if isempty(portal)
    % save the old PaperUnits, since we really want to deal with points
    paperUnits = LGet(sysobj,'PaperUnits');
    
    if(~strcmpi(paperUnits,'points'))
        LSet(sysobj,'PaperUnits','points');
    end

    % After we set the PaperOrientation other parameters like size and position
    % adjust themselves accordingly.
    paperPos = LGet(sysobj,'PaperPosition');
    paperSize = LGet(sysobj,'PaperSize');
    paperMode = LGet(sysobj,'PaperPositionMode');

    % Restore original settings
    LSet(sysobj,'PaperUnits',paperUnits);    
    
    % Ok, we are now ready to do some painting on the portal !!! Start !!!
    portal = Portal.Portal;
    portal.units = 'pixels';
    portal.size = Portal.Point(paperSize(1),paperSize(2));
else
    if ~strcmpi(portal.units,'pixels')
        error('Simulink:InvalidPortalUnits','Portal units must be in pixels')
    end
    paperSize = [portal.size.x portal.size.y];
    paperPos = [0 portal.size.y portal.size.x portal.size.y]; %[left bottom width height];
    paperMode = 'auto';
end

% Get the transform from frame patches vertices to the portal world
% Note: offset is in portal coordinates
[scale, offset] = LGetTransformForPapersize(frameinfo, paperSize);

% Draw portal rectangle corresponding to each frame in the patch
portalRects = {};

% xxx
% canvas = portal.getCanvas();
% layers = canvas.getLayers();
% overlayLayer = layers(2);
% overlayModel = overlayLayer.getModel();

% First vertex will always represent the full page patch.  Starting at the
% second vertices, they will represent the actual frames or rectangles.
framePatchVertices = frameinfo.vertices(2:end);
for k = 1:length(framePatchVertices)
    portalRect = LGetPortalRectForPatch(framePatchVertices{k},scale,offset);
    portalRects{k} = portalRect;

    % xxx
%     r = overlayModel.createRectNode(portalRect(1),portalRect(2),portalRect(3),portalRect(4));
%     overlayModel.addNode(r);
end

% This will take care of font names in English and Japanese platforms.
% Change made to fix g466337 (sramaswa, May 2008)
if(strncmpi(get(0,'language'),'ja',2))
    fontName = 'MS UI Gothic';
else
    fontName = 'Helvetica';
end

vAlign = 'V_CENTER_TEXT'; % vertical center

% Loop through each text and render it in the portal
texts = frameinfo.texts;

for k = 1:length(texts)

    textProp = texts{k}.properties;

    fontSize = 10;
    fontWeight = 'NORMAL_WEIGHT';
    fontAngle = 'NORMAL_ANGLE';
    hAlign = 'LEFT_TEXT'; % left

    % We need to write text on the frame for each type of text i.e. date,
    % pagenum, model name etc. etc. except for blockdiagram because that is
    % where the block diagram will go. Loop through each valid text and get
    % its position and (fontWeight,fontAngle,fontSize if any. If these 3 are
    % empty then use the default otherwise set these values in portal's text
    % properties). If it is blockdiagram, save its position; we will need
    % it later for validation
    if( isfield(textProp,'String'))

        if(strcmpi(textProp.String,'%<blockdiagram>'))
            blockDiagTextPos = textProp.Position;
            continue;
        end

        % Get the string and its position
        textStr = textProp.String;
        textPos = textProp.Position;

        % Change the portal text properties based on the text's HG values
        if( isfield(textProp,'FontSize'))
            fontSize = textProp.FontSize;
        end

        if( isfield(textProp,'FontAngle'))
            if(strcmpi(textProp.FontAngle,'Normal'))
                fontAngle = 'NORMAL_ANGLE';              
            elseif (strcmpi(textProp.FontAngle,'Italic'))
                fontAngle = 'ITALIC_ANGLE';           
            end
        end

        if( isfield(textProp,'FontWeight'))
            if(strcmpi(textProp.FontWeight,'Normal'))
                fontWeight = 'NORMAL_WEIGHT';
            elseif (strcmpi(textProp.FontWeight,'Bold'))
                fontWeight = 'BOLD_WEIGHT';
            end
        end

        if( isfield(textProp,'HorizontalAlignment'))
            if(strcmpi(textProp.HorizontalAlignment,'left'))
                hAlign = 'LEFT_TEXT';
            elseif (strcmpi(textProp.HorizontalAlignment,'right'))
                hAlign = 'RIGHT_TEXT';
            elseif (strcmpi(textProp.HorizontalAlignment,'center'))
                hAlign = 'H_CENTER_TEXT';
            end
        end

        % get the portal coordinates for HG coordinates
        portalTextPos = LGetPortalXYForHGXY(textPos([1 2]),scale,offset);

        textFormat = 'TEX_FORMAT'; % FRAMEEDIT has TeX turned on by default
        isTex = true;
        if ((isfield(textProp,'Interpreter')) && strcmpi(textProp.Interpreter,'none'))
            textFormat = 'SIMPLE_FORMAT';
            isTex = false;
        end

        % add the label after getting the correct value for the text i.e.
        % corresponding to %<system>, %<fullsystem> etc. etc.
        parsedTextStr = LGetValForStr(textStr,sysobj,frameinfo,isTex);

        % xxx
%         % GLRC API for drawing
%         glrcFont = overlayModel.createFontNode(fontName,fontSize,fontWeight,fontAngle);
%         overlayModel.addNode(glrcFont);
%         glrcText = overlayModel.createTextNode(portalTextPos(1),portalTextPos(2),parsedTextStr,hAlign,vAlign,textFormat);
%         overlayModel.addNode(glrcText);

    end

end

% Find the rectangle that holds %<blockdiagram>. This is where the block
% diagram will go !! Note: There could be more than one patch that holds
% the blockdiagram. Find the one with minimum area.
portalRectForSys = LGetPortalRectForSys(portalRects, framePatchVertices, blockDiagTextPos);

% Render the actual system(i.e. simulink/stateflow) now....
% xxx
% portal.targetObject = sysobj;

% Get model paper position. Note that paper position will be in HG Coords.
% Bottom left on HG coordinate system where y-axis goes upward will be top left
% on portal coordinate system where the y-axis goes down.
sysRect = [paperPos(1), ...
           paperSize(2) - paperPos(2) - paperPos(4), ...
           paperPos(3), ...
           paperPos(4)];

% % Debug code.  Draw the sysRect as a rectangle in the portal
% overlayModel.addNode(overlayModel.createRectNode(sysRect(1),sysRect(2),sysRect(3),sysRect(4)));

% % Minimum padding
% if frameinfo.treatPointsAsPixels
%     quarterInch = 0.25*pointsPerInch;
% else
%     quarterInch = 0.25*ppi*pointsPerInch;
% end


% If the model area fits inside the area allotted by the frame, then we are
% happy.
if strcmpi(paperMode,'manual') && LIsRectInsideOfAnother(sysRect,portalRectForSys)

    % xxx
%     portal.minimumMargins.left = sysRect(1);
%     portal.minimumMargins.top = sysRect(2);
%     portal.minimumMargins.right = paperSize(1) - sysRect(1) - sysRect(3);
%     portal.minimumMargins.bottom = paperSize(2) - sysRect(2) - sysRect(4);

    % Even if the model fits inside the allotted area, the paddings might
    % not be sufficient. Check whether the padding is at least 1/4 inches.
    % If not, set the padding flag to true.
    biggerSysRect = [sysRect(1) - quarterInch, ...
                     sysRect(2) - quarterInch, ...
                     sysRect(3) + 2*quarterInch, ...
                     sysRect(4) + 2*quarterInch];

    if ~LIsRectInsideOfAnother(biggerSysRect,portalRectForSys)
        % xxx
%         portal.minimumMargins.left = portal.minimumMargins.left + quarterInch;
%         portal.minimumMargins.top = portal.minimumMargins.top + quarterInch;
%         portal.minimumMargins.right = portal.minimumMargins.right + quarterInch;
%         portal.minimumMargins.bottom = portal.minimumMargins.bottom + quarterInch;
    end

else % Try to resize object to 100% zoom and center it, if we can't then we shrink it
    %
    %  +-----------------------------------------
    %  |        \                               A
    %  |        outer margin                    |
    %  |        /                               |
    %  +-------------------------               |
    %  |        \                               |
    %  |        inner margin                    |
    %  |        /                               |
    %  |    TARGET OBJECT (MODEL) @ 100%   Portal Size
    %  |        \                               |
    %  |        inner margin                    |
    %  |        /                               |
    %  +-------------------------               |
    %  |        \                               |
    %  |        outer margin                    |
    %  |        /                               V
    %  +------------------------------------------
    %
    %  Note: PortalSize = TopOuterMargin + 2*InnerMargin + TargetObject + Bottom OuterMargin
    %

    % Outer frame margin is the distance from the paper edge to the rectangle
    % that holds the Simulink/Stateflow object (see above pic).
    outerFrameMargin.left = portalRectForSys(1);
    outerFrameMargin.top = portalRectForSys(2);
    outerFrameMargin.right = paperSize(1) - portalRectForSys(1) - portalRectForSys(3);
    outerFrameMargin.bottom = paperSize(2) - portalRectForSys(2) - portalRectForSys(4);

    targetWidth = portal.viewExtents.width;
    targetHeight = portal.viewExtents.height;
    
    if (isa(sysobj, 'Stateflow.Object') && ~frameinfo.treatPointsAsPixels)
        targetWidth = ppi * targetWidth;
        targetHeight = ppi * targetHeight;
    end        

    % Inner frame is the distance from the outer frame to the object extent at
    % 100% scale (see above pic).
    innerFrameMargin.width = (paperSize(1) - targetWidth - outerFrameMargin.left - outerFrameMargin.right)/2;
    innerFrameMargin.height = (paperSize(2) - targetHeight - outerFrameMargin.top - outerFrameMargin.bottom)/2;

    if ((innerFrameMargin.width > quarterInch) && ...
        (innerFrameMargin.height > quarterInch))
        % Object fits inside the system frame at 100%.
        portal.minimumMargins.left = outerFrameMargin.left + innerFrameMargin.width;
        portal.minimumMargins.top = outerFrameMargin.top +  innerFrameMargin.height;
        portal.minimumMargins.right = outerFrameMargin.right + innerFrameMargin.width;
        portal.minimumMargins.bottom = outerFrameMargin.bottom + innerFrameMargin.height;
    else
        % Object does not fit inside the system frame.  Resized to fit and
        % add some padding.
        portal.minimumMargins.left = outerFrameMargin.left + quarterInch;
        portal.minimumMargins.top = outerFrameMargin.top +  quarterInch;
        portal.minimumMargins.right = outerFrameMargin.right + quarterInch;
        portal.minimumMargins.bottom = outerFrameMargin.bottom + quarterInch;
    end
end

% Reset the (persistent) frame info if all pages have been printed !!
if(frameinfo.page == frameinfo.npages)
    frameinfo = [];
end


%--------------------------------------------------------------------------
function val = LIsRectInsideOfAnother(thisrect,anotherrect)
% Check whether one rectangle completely enclodes by another rectangle

val = (thisrect(1) > anotherrect(1)) && (thisrect(2) > anotherrect(2)) && ...
      (thisrect(1) + thisrect(3) < anotherrect(1) + anotherrect(3)) && ...
      (thisrect(2) + thisrect(4) < anotherrect(2) + anotherrect(4));
%--------------------------------------------------------------------------
function portalRectForSys = LGetPortalRectForSys(portalRects,framePatchVertices,blockDiagTextPos)
% Get the rectangle (in Portal Coordinates) in which the blockdiagram is
% supposed to be enclosed. This is found by getting the areas of all the
% portal rectangles in the frame that can holds the blockdiagram text and
% finding the one with the minimum area.

possiblePortalRects = {};
possiblePortalRectAreas = [];

blockX = blockDiagTextPos(1);
blockY = blockDiagTextPos(2);

% Loop through each patch and find the ones that can hold the blockdiagram
% text potentially.
i = 1;
for k = 1:length(framePatchVertices)

    thePatch = framePatchVertices{k};
    minX = thePatch(1,1);
    maxX = thePatch(4,1);

    minY = thePatch(1,2);
    maxY = thePatch(2,2);

    % If a patch can hold the blockdiagram text, then save its area
    if( (blockX > minX) && (blockX < maxX) && (blockY > minY) && (blockY < maxY) )
        portalRect = portalRects{k};
        possiblePortalRectAreas(i) = portalRect(3)*portalRect(4);
        possiblePortalRects{i} = portalRect;
        i = i + 1;
    end

end

[~, idx] = sort(possiblePortalRectAreas);
portalRectForSys = possiblePortalRects{idx(1)};
%--------------------------------------------------------------------------
function orientation = LGetFrameOrientation(figinfo)
% Save the frame's orientation.

orientation = 'landscape';
fields = fieldnames(figinfo);
try %#ok
    orientation = figinfo.(fields{1}).properties.PaperOrientation;
catch e %#ok- For now we catch an exception to avoid lasterror updation and to accomodate lasterror 
        %cleanup in print.m
end
%--------------------------------------------------------------------------
function paperType = LGetFramePaperType(figinfo)
% Save the frame's papertype.

paperType = 'USLetter';
fields = fieldnames(figinfo);
try %#ok
    paperType = figinfo.(fields{1}).properties.PaperType;
catch e %#ok - For now we catch an exception to avoid lasterror updation and to accomodate lasterror 
        %cleanup in print.m
end
%--------------------------------------------------------------------------
function figAxes = LGetHGAxesFromFig(figinfo)
% From the figure information, get the axes

fields = fieldnames(figinfo);
figDetails = figinfo.(fields{1});
figChildren = figDetails.children;

for k = 1:length(figChildren)
    child = figChildren(k);
    if(strcmp(child.type,'axes'))
       figAxes = child;
       break;
    end
end
%--------------------------------------------------------------------------
function types = LGetHGTypeFromAxes(figaxes,type)
% Given a axes find all the HG types of type 'type' i.e. e.g. find all the
% HG type of type 'text' in a axes

axesChildren = figaxes.children;

types = {};
i = 1;
for k = 1:length(axesChildren)

    if( strcmp(axesChildren(k).type,type) )
        types{i} = axesChildren(k);
        i = i + 1;
    end

end
%--------------------------------------------------------------------------
function props = LGetHGPropForType(hgtype,propname)
% Given a hg type structure, get its property with name propname

props = {};

i = 1;
for k = 1:length(hgtype)
    properties = hgtype{k}.properties;
    if(isfield(properties,propname))
        props{i} = properties.(propname);
        i = i + 1;
    end
end
%--------------------------------------------------------------------------
function normPixXY = LGetPixelsPerNormRatio(vertex,papersize)
% Based on the papersize, find the pixels that represent 1 norm unit

normWidth = vertex(4,1) - vertex(1,1);
normHeight = vertex(2,2) - vertex(1,2);

numPixPerNormX = papersize(1)/normWidth;
numPixPerNormY = papersize(2)/normHeight;

normPixXY = [numPixPerNormX numPixPerNormY];
%--------------------------------------------------------------------------
function [scale, offset] = LGetTransformForPapersize(frameinfo,paperSize)
% Get the scale and offset to go from the normalized figure to the portal
% world.  Note that the frameinfo first vertex represents the papersize and is not
% normalized!  It is scaled to the frameinfo.papersize.  To account for this,
% we will use the margin information.

% The second vertex is the mainPatch which represents the main frame.
% Should always be [0 0 1 1].
mainPatch = frameinfo.vertices{2};

paperSizeWithOutMargins = [ ...
    (paperSize(1) - frameinfo.margins.left - frameinfo.margins.right), ... %width
    (paperSize(2) - frameinfo.margins.top - frameinfo.margins.bottom)]; % height

scale = LGetPixelsPerNormRatio(mainPatch,paperSizeWithOutMargins);
offset = [frameinfo.margins.left frameinfo.margins.top];
%--------------------------------------------------------------------------
function rect = LGetPortalRectForPatch(patchVertex,scale,offset)
% Given a patch vertex in HG frame coordinates, find the corresponding rect
% in portal coordinates.

rect = [ ...
    LGetPortalXYForHGXY(patchVertex(2,:),scale,offset), ...% top left
    scale(1)*(patchVertex(3,1) - patchVertex(2,1)), ... % width
    scale(2)*(patchVertex(2,2) - patchVertex(1,2)) % height
    ];
%--------------------------------------------------------------------------
function portalXY = LGetPortalXYForHGXY(hgXY,scale,offset)
% Given a HG normalized frame coordinate, scale and offset, find the
% corresponding portal coordinate.
%
% Note: HG coordinate system starts at the bottom left and the y-axes goes
% upward.  The portal coordinates starts at the top left and the y-axes goes
% down. Since HG coordinates are normalized, we can go from bottom to top
% by subtracting 1.
portalY = scale(2)*(1-hgXY(2)) + offset(2);

portalX = scale(1)*hgXY(1) + offset(1);

portalXY = [portalX portalY];
%--------------------------------------------------------------------------
function result = LGetValForStr(str,sysObj,frameinfo,isTex)
% Get the replacement text for the possible strings in the frame.
% have to deal with arrays of char m:n where m >= 1. Result may
% contain newlines. str may be either a single line or a matrix of
% padded lines. strrep will choke on the latter, so we convert to
% a cell array.
val = cellstr(str);

val = LEscapeVal(val,'%<page>',num2str(frameinfo.page),isTex);
val = LEscapeVal(val,'%<date>',frameinfo.date,isTex);
val = LEscapeVal(val,'%<time>',frameinfo.time,isTex);
val = LEscapeVal(val,'%<npages>',num2str(frameinfo.npages),isTex);
val = LEscapeVal(val,'%<system>',LGetSystemName(sysObj),isTex);
val = LEscapeVal(val,'%<fullsystem>',LGetFullSystemName(sysObj),isTex);
val = LEscapeVal(val,'%<filename>',LGetFileName(sysObj),isTex);
val = LEscapeVal(val,'%<fullfilename>',LGetFullFileName(sysObj),isTex);

result = val{1};
for idx=2:numel(val)
    result = sprintf('%s\n%s',result,val{idx});
end
%--------------------------------------------------------------------------
function out = LEscapeVal(in,keyword,val,isTex)

if isTex
    % Tex special characters _ { } ^ \
    val = regexprep(val,'([\_\{\}\^\\])','\\$1');
end
    
out = strrep(in,keyword,val);
%{
%--------------------------------------------------------------------------
function name = LGetSystemName(obj)
% Get the system name i.e. vdp, sf_car etc.

name = obj.Name;
name = strrep(name,char(10),' ');
%--------------------------------------------------------------------------
function name = LGetFullSystemName(obj)
% Get the fullsystem name i.e. e.g. fuelsys/fuel rate controller

name = '';
if(isa(obj,'Simulink.Object'))
    name = obj.Path;
    if(~strcmp(obj.Name,obj.Path))
        name = [obj.Path '/' obj.Name];
    end
elseif(isa(obj,'Stateflow.Object'))
    % for charts the name is the Path i.e
    % sf_car/shift_logic
    if(isa(obj,'Stateflow.Chart'))
        name = obj.Path;
    else
        % for other sf objects, i.e. Stateflow.Function etc.
        % it will be like "sf_car/shift_logic.gear"
        name = [obj.Path '.' obj.Name];
    end
end
name = strrep(name,char(10),' '); % Carriage returns to spaces
%--------------------------------------------------------------------------
function name = LGetFileName(obj)
% Get the basefile name for a system i.e. e.g. vdp.mdl, sf_car.mdl

fullFileName = LGetFullFileName(obj);
[path, base, ext] = fileparts(fullFileName); %#ok
name = [base ext];
%--------------------------------------------------------------------------
function name = LGetFullFileName(obj)
% Get the fullpath to the main file i.e. e.g.
% $matlabroot/toolbox/simdemos/simdemos/sf_car.mdl etc.

if(isa(obj,'Simulink.BlockDiagram'))
    name = obj.FileName;
else
    upObj = obj.up; % Start traversing up ...
    bdObj = LGetSLBDObj(upObj); % ... until Simulink.BlockDiagram UDD found
    name = bdObj.FileName;
end
%--------------------------------------------------------------------------
function slBlkDiagObj = LGetSLBDObj(obj)
% Get the main Simulink.BlockDiagram UDD object corresponding to a simulink
% model for any block in that model. Only the main blockdiagram object has
% root information like 'FileName' etc.

slBlkDiagObj = obj;
if(~isa(obj,'Simulink.BlockDiagram'))
   while(true)
       tmpObj = obj.up;
       if(isa(tmpObj,'Simulink.BlockDiagram'))
           slBlkDiagObj = tmpObj;
           break;
       else
           obj = tmpObj;
       end
   end
end
%--------------------------------------------------------------------------
function retVal = LGet(slsfObj,propName)
% Some parameters like PaperPosition, PaperType etc. cannot be gotten from
% objects like Stateflow.Function, Stateflow.State etc. So derive that
% information based on the class type of object. Simulink.<Objects> are
% pretty straightforward i.e. all the Simulink.Objects will have Paper*
% parameters

if(isa(slsfObj,'Stateflow.Object'))
    if(isValidProperty(slsfObj,propName))
        retVal = get(slsfObj,propName);
    else
        chartObj = get(slsfObj,'Chart');
        retVal = get(chartObj,propName);
    end
else
    retVal = get(slsfObj,propName);
end
%--------------------------------------------------------------------------
function LSet(slsfObj,propName,propVal)
% Some parameters like PaperPosition, PaperType etc. cannot be set on
% objects like Stateflow.Function, Stateflow.State etc. So set the
% parameter information based on the class type of object.
% Simulink.<Objects> are pretty straightforward i.e. all the
% Simulink.Objects will have Paper* parameters

if(isa(slsfObj,'Stateflow.Object'))
    if(isValidProperty(slsfObj,propName))
        set(slsfObj,propName,propVal);
    else
        chartObj = get(slsfObj,'Chart');
        set(chartObj,propName,propVal);
    end
else
    set(slsfObj,propName,propVal);
end
%}
%--------------------------------------------------------------------------
function margins = LGetPaperMargins(frameinfo)
% Get paper margins based on the papertype and vertices

% Create an invisible figure to get paper size information
objHandle = figure('handlevisibility','off',...
    'integerhandle','off',...
    'visible','off',...
    'tag','FRAMEEDIT_TEST_FIGURE',...
    'name','Simulink Print Frame Test Figure');
set(objHandle,'PaperType',frameinfo.papertype);
set(objHandle,'PaperUnits','points');
set(objHandle,'PaperOrientation',frameinfo.orientation);
paperSize = get(objHandle,'PaperSize');
delete(objHandle);

% First vertex will always be the main full page patch
frameNormPaperVertices = frameinfo.vertices{1};

if ~frameinfo.treatPointsAsPixels
    paperSize = paperSize * get(0,'ScreenPixelsPerInch')/72;
end

% Get correct scaling for the paper margins
scale = LGetPixelsPerNormRatio(frameNormPaperVertices,...
    paperSize);

% Vertices start from lower left hand corner and goes in a clockwise order
% Note: Paper margins vertices lie outside the [0 1] axes.
margins.top =  scale(2)*(frameNormPaperVertices(3,2) - 1);
margins.left = -scale(1)*frameNormPaperVertices(1,1);
margins.bottom = -scale(2)*frameNormPaperVertices(1,2);
margins.right = scale(1)*(frameNormPaperVertices(3,1) - 1);

% [EOF]
