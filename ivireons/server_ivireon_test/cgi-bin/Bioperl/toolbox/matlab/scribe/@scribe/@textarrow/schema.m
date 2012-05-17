function schema
%SCHEMA defines the scribe.textarrow class
%

%   Copyright 1984-2006 The MathWorks, Inc.
%   $  $  $

hPk = findpackage('scribe'); % Scribe package
cls = schema.class(hPk, 'textarrow', hPk.findclass('scribeobject1D'));

if isempty(findtype('ArrowHeadType'))
    schema.EnumType('ArrowHeadType', ...
        {'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2',...
        'cback3','fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'});
end

% Obtain a handle to the width check function:
widthFun = {@graph2dhelper,'widthCheck'};
% Obtain a handle to the color filter function:
colorFun = {@graph2dhelper,'colorFilter'};

% Properties that affect both the head and the tail:
p = schema.prop(cls,'LineWidth','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localChangeAll,'LineWidth',widthFun};

p = schema.prop(cls,'LineStyle','lineLineStyleType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.SetFunction = {@localChangeAll,'LineStyle'};

% Tail properties:
% Store a handle to the line:
p = schema.prop(cls,'TailHandle','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Since there is a global color property which the tail color shadows, hide
% the property
p = schema.prop(cls,'TailColor','lineColorType');
p.Visible = 'off';
p.SetFunction = {@localSetToTail,'Color'};
p.GetFunction = {@localGetFromTail,'Color',colorFun};
p.FactoryValue = get(0,'DefaultLineColor');

% Line Width:
p = schema.prop(cls,'TailLineWidth','double');
p.Visible = 'off';
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToTail,'LineWidth',widthFun};
p.GetFunction = {@localGetFromTail,'LineWidth'};

% Line Style:
p = schema.prop(cls,'TailLineStyle','lineLineStyleType');
p.Visible = 'off';
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.SetFunction = {@localSetToTail,'LineStyle'};
p.GetFunction = {@localGetFromTail,'LineStyle'};

% Head Properties:
p = schema.prop(cls,'HeadHandle','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

p = schema.prop(cls,'HeadStyle','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';

p = schema.prop(cls,'HeadBackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p.SetFunction = @localSetHeadBackDepth;

p = schema.prop(cls,'HeadRosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p.SetFunction = @localSetHeadRosePQ;

p = schema.prop(cls,'HeadHypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p.SetFunction = @localSetHeadHypocycloidN;

p = schema.prop(cls,'HeadColor','patchEdgeColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible = 'off';
p.SetFunction = @localSetHeadColor;

p = schema.prop(cls,'HeadColorMode','axesXLimModeType');
p.FactoryValue = 'auto';
p.Visible = 'off';
p.SetFunction = @localSetHeadColorMode;

p = schema.prop(cls,'HeadFaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHead,'FaceColor'};
p.GetFunction = {@localGetFromHead,'FaceColor',colorFun};

p = schema.prop(cls,'HeadFaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p.SetFunction = {@localSetToHead,'FaceAlpha'};
p.GetFunction = {@localGetFromHead,'FaceAlpha'};

p = schema.prop(cls,'HeadLineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p.SetFunction = {@localSetToHead,'LineWidth',widthFun};
p.GetFunction = {@localGetFromHead,'LineWidth'};

p = schema.prop(cls,'HeadEdgeColor','patchEdgeColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHead,'EdgeColor'};
p.GetFunction = {@localGetFromHead,'EdgeColor',colorFun};

p = schema.prop(cls,'HeadLineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p.SetFunction = {@localSetToHead,'LineStyle'};
p.GetFunction = {@localGetFromHead,'LineStyle'};

p = schema.prop(cls,'HeadWidth','double');
p.AccessFlags.Init = 'off'; 
p.FactoryValue = 10;

p = schema.prop(cls,'HeadLength','double');
p.AccessFlags.Init = 'off'; 
p.FactoryValue = 10;

p = schema.prop(cls,'HeadSize','double');
p.AccessFlags.Init = 'on';
p.Visible='off';
p.FactoryValue = 10;
p.SetFunction = {@localSetHeadSize,widthFun};

% Text Properties:
p = schema.prop(cls,'TextHandle','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible = 'off';

p = schema.prop(cls,'String','textStringType');
p.FactoryValue = {''};
p.SetFunction = {@localSetToText,'String'};
p.GetFunction = {@localGetFromText,'String'};

p = schema.prop(cls,'TextEraseMode','textEraseModeType');
p.FactoryValue = 'normal';
p.Visible = 'off';
p.SetFunction = {@localSetToText,'EraseMode'};
p.GetFunction = {@localGetFromText,'EraseMode'};

p = schema.prop(cls,'Editing','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';
p.SetFunction = {@localSetToText,'Editing'};
p.GetFunction = {@localGetFromText,'Editing'};

p = schema.prop(cls,'FontAngle','textFontAngleType');
p.FactoryValue = get(0,'DefaultTextFontAngle');
p.SetFunction = {@localSetToText,'FontAngle'};
p.GetFunction = {@localGetFromText,'FontANgle'};

p = schema.prop(cls,'FontName','textFontNameType');
p.FactoryValue = get(0,'DefaultTextFontName');
p.SetFunction = {@localSetToText,'FontName'};
p.GetFunction = {@localGetFromText,'FontName'};

p = schema.prop(cls,'FontSize','double');
p.FactoryValue = get(0,'DefaultTextFontSize');
p.SetFunction = {@localSetToText,'FontSize'};
p.GetFunction = {@localGetFromText,'FontSize'};

p = schema.prop(cls,'FontUnits','textFontUnitsType');
p.FactoryValue = get(0,'DefaultTextFontUnits');
p.SetFunction = {@localSetToText,'FontUnits'};
p.GetFunction = {@localGetFromText,'FontUnits'};

p = schema.prop(cls,'FontWeight','textFontWeightType');
p.FactoryValue = get(0,'DefaultTextFontWeight');
p.SetFunction = {@localSetToText,'FontWeight'};
p.GetFunction = {@localGetFromText,'FontWeight'};

p = schema.prop(cls,'HorizontalAlignment','textHorizontalAlignmentType');
p.FactoryValue = 'center';
p.SetFunction = {@localSetToText,'HorizontalAlignment'};
p.GetFunction = {@localGetFromText,'HorizontalAlignment'};

p = schema.prop(cls,'VerticalAlignment','textVerticalAlignmentType');
p.FactoryValue = 'middle';
p.SetFunction = {@localSetVerticalAlignment};
p.GetFunction = {@localGetFromText,'VerticalAlignment'};

p = schema.prop(cls,'VerticalAlignmentMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'auto';

p = schema.prop(cls,'Interpreter','textInterpreterType');
p.FactoryValue = get(0,'DefaultTextInterpreter');
p.SetFunction = {@localSetToText,'Interpreter'};
p.GetFunction = {@localGetFromText,'Interpreter'};

p = schema.prop(cls,'TextMargin','double');
p.FactoryValue = 2;
p.SetFunction = {@localSetToText,'Margin'};
p.GetFunction = {@localGetFromText,'Margin'};

p = schema.prop(cls,'TextRotation','double');
p.FactoryValue = 0;
p.SetFunction = {@localSetToText,'Rotation'};
p.GetFunction = {@localGetFromText,'Rotation'};

p = schema.prop(cls,'TextBackgroundColor','patchFaceColorType');
p.SetFunction = {@localSetToText,'BackgroundColor'};
p.GetFunction = {@localGetFromText,'BackgroundColor',colorFun};
p.FactoryValue = get(0,'DefaultTextBackgroundColor');

p = schema.prop(cls,'TextColor','textColorType');
p.FactoryValue = get(0,'DefaultTextColor');
p.SetFunction = @localSetTextColor;
p.GetFunction = {@localGetFromText,'Color',colorFun};

p = schema.prop(cls,'TextColorMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'auto';
p.SetFunction = @localSetTextColorMode;

p = schema.prop(cls,'TextLineWidth','double');
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToText,'LineWidth',widthFun};
p.GetFunction = {@localGetFromText,'LineWidth'};

p = schema.prop(cls,'TextEdgeColor','textEdgeColorType');
p.FactoryValue = get(0,'DefaultTextEdgeColor');
p.SetFunction = @localSetTextEdgeColor;
p.GetFunction = {@localGetFromText,'EdgeColor',colorFun};

p = schema.prop(cls,'TextEdgeColorMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'manual';
p.SetFunction = @localSetTextEdgeColorMode;


%-------------------------------------------------------------------%
function valueStored = localSetVerticalAlignment(hThis, valueProposed)

valueStored = valueProposed;
set(hThis.TextHandle,'VerticalAlignment',valueProposed);
if ~hThis.UpdateInProgress
    hThis.VerticalAlignmentMode = 'manual';
end

%-------------------------------------------------------------------%
function valueStored = localSetHeadHypocycloidN(hThis, valueProposed) %#ok
% Ensure the HypocycloidN value is stored properly

valueProposed = floor(valueProposed);
if valueProposed < 3
    valueStored = 3;
else
    valueStored = valueProposed;
end

%-------------------------------------------------------------------%
function valueStored = localSetHeadRosePQ(hThis, valueProposed) %#ok
% Ensure the RosePQ value is stored properly

if valueProposed < 0
    valueStored = 0;
elseif mod(valueProposed,2) > 0
    valueStored = 2*floor(valueProposed/2);
else
    valueStored = valueProposed;
end

%-------------------------------------------------------------------%
function valueStored = localSetHeadBackDepth(hThis, valueProposed) %#ok
% Ensure the stored value for the head back depth is confined to the range
% [0 1]

if valueProposed < 0
    valueStored = 0;
elseif valueProposed > 1
    valueStored = 1;
else
    valueStored = valueProposed;
end

%-------------------------------------------------------------------%
function valueStored = localSetHeadSize(hThis, valueProposed, errFun)
% Change the head size

% Error-check the input
if ~iscell(errFun)
    errFun = {errFun};
end
error(feval(errFun{:},valueProposed));

% If the value is 0, bail out
if valueProposed == 0
    valueStored = valueProposed;
    return
end

hThis.UpdateInProgress = true;
hThis.HeadLength = valueProposed;
hThis.HeadWidth = valueProposed;
hThis.UpdateInProgress = false;

valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueStored = localChangeAll(hThis, valueProposed, propName, errFun)
% Set a property on all children of the object.

% Set a property on all children of the object.
if nargin < 4
    localSetToTail(hThis,valueProposed,propName);
else
    localSetToTail(hThis,valueProposed,propName,errFun);
end
% Since the error checking has already been accomplished, leave out the
% last argument in the second call.
localSetToHead(hThis,valueProposed,propName);
localSetToText(hThis,valueProposed,propName);

valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueStored = localSetToText(hThis, valueProposed, propName, errFun)
% Set a property on the text object using the option error function
% "errFun" as input checking
if ~isempty(hThis.TextHandle) && ishandle(hThis.TextHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.TextHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromText(hThis, valueStored, propName, filterFun)
% Return a property from the text object

if ~isempty(hThis.TextHandle) && ishandle(hThis.TextHandle)
    valueToCaller = get(hThis.TextHandle,propName);
else
    valueToCaller = valueStored;
end

if nargin > 3
    if ~iscell(filterFun)
        filterFun = {filterFun};
    end
    valueToCaller = feval(filterFun{:},valueToCaller);
end

%-------------------------------------------------------------------%
function valueStored = localSetToTail(hThis, valueProposed, propName, errFun)
% Set a property on the line object using the option error function
% "errFun" as input checking
if ~isempty(hThis.TailHandle) && ishandle(hThis.TailHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.TailHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromTail(hThis, valueStored, propName, filterFun)
% Return a property from the line object

if ~isempty(hThis.TailHandle) && ishandle(hThis.TailHandle)
    valueToCaller = get(hThis.TailHandle,propName);
else
    valueToCaller = valueStored;
end

if nargin > 3
    if ~iscell(filterFun)
        filterFun = {filterFun};
    end
    valueToCaller = feval(filterFun{:},valueToCaller);
end

%-------------------------------------------------------------------%
function valueStored = localSetToHead(hThis, valueProposed, propName, errFun)
% Set a property on the head object using the option error function
% "errFun" as input checking
if ~isempty(hThis.HeadHandle) && ishandle(hThis.HeadHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.HeadHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromHead(hThis, valueStored, propName, filterFun)
% Return a property from the head object

if ~isempty(hThis.HeadHandle) && ishandle(hThis.HeadHandle)
    valueToCaller = get(hThis.HeadHandle,propName);
else
    valueToCaller = valueStored;
end

if nargin > 3
    if ~iscell(filterFun)
        filterFun = {filterFun};
    end
    valueToCaller = feval(filterFun{:},valueToCaller);
end

%---------------------------------------------------------------------%
function valueStored = localSetTextEdgeColor(hThis, valueProposed)
% Update the head color.

valueStored = valueProposed;
set(hThis.TextHandle,'EdgeColor',valueProposed)

% If there is not an update in progress, set the "TextColorMode" property
% to "manual"
if ~hThis.UpdateInProgress
    hThis.TextEdgeColorMode = 'manual';
end

%---------------------------------------------------------------------%
function valueStored = localSetTextEdgeColorMode(hThis, valueProposed)
% Update the head color mode.

valueStored = valueProposed;
if strcmpi(valueProposed,'manual');
    hThis.ColorProps(strcmpi(hThis.ColorProps,'TextEdgeColor')) = [];
else
    hThis.ColorProps{end+1} = 'TextEdgeColor';
    hThis.TextEdgeColor = hThis.Color;
end

%---------------------------------------------------------------------%
function valueStored = localSetTextColor(hThis, valueProposed)
% Update the head color.

valueStored = valueProposed;
set(hThis.TextHandle,'Color',valueProposed)

% If there is not an update in progress, set the "TextColorMode" property
% to "manual"
if ~hThis.UpdateInProgress
    hThis.TextColorMode = 'manual';
end

%---------------------------------------------------------------------%
function valueStored = localSetTextColorMode(hThis, valueProposed)
% Update the head color mode.

valueStored = valueProposed;
if strcmpi(valueProposed,'manual');
    hThis.ColorProps(strcmpi(hThis.ColorProps,'TextColor')) = [];
else
    hThis.ColorProps{end+1} = 'TextColor';
    hThis.TextColor = hThis.Color;
end

%---------------------------------------------------------------------%
function valueStored = localSetHeadColor(hThis, valueProposed)
% Update the head color.

valueStored = valueProposed;
hThis.HeadFaceColor = valueProposed;
hThis.HeadEdgeColor = valueProposed;
% If there is not an update in progress, set the "HeadColorMode" property
% to "manual"
if ~hThis.UpdateInProgress
    hThis.HeadColorMode = 'manual';
end

%---------------------------------------------------------------------%
function valueStored = localSetHeadColorMode(hThis, valueProposed)
% Update the head color mode.

valueStored = valueProposed;
if strcmpi(valueProposed,'manual');
    hThis.ColorProps(strcmpi(hThis.ColorProps,'HeadColor')) = [];
else
    hThis.ColorProps{end+1} = 'HeadColor';
    hThis.HeadColor = hThis.Color;
end