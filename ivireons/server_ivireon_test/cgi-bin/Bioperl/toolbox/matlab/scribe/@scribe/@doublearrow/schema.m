function schema
%SCHEMA defines the scribe.DOUBLEARROW schema
%

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $  $  $

hPk = findpackage('scribe'); % Scribe package
cls = schema.class(hPk, 'doublearrow', hPk.findclass('scribeobject1D'));

if isempty(findtype('DoubleArrowHeadType'))
    schema.EnumType('DoubleArrowHeadType', ...
        {'mixed','none','plain','ellipse','vback1','vback2','vback3','cback1','cback2',...
        'cback3','fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'});
end
if isempty(findtype('ArrowHeadType'))
    schema.EnumType('ArrowHeadType', ...
        {'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2',...
        'cback3','fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'});
end

% Obtain a handle to the width check function:
widthFun = {@graph2dhelper,'widthCheck'};
% Obtain a handle to the color filter function:
colorFun = {@graph2dhelper,'colorFilter'};

% Properties that affect both the heads and the tail:
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
p.FactoryValue = get(0,'DefaultLineColor');
p.SetFunction = {@localSetToTail,'Color'};
p.GetFunction = {@localGetFromTail,'Color',colorFun};

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

% Head 1 Properties:
p = schema.prop(cls,'Head1Handle','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible = 'off';

p = schema.prop(cls,'Head1Style','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';

p = schema.prop(cls,'Head1BackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p.SetFunction = @localSetHeadBackDepth;

p = schema.prop(cls,'Head1RosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p.SetFunction = @localSetHeadRosePQ;

p = schema.prop(cls,'Head1HypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p.SetFunction = @localSetHeadHypocycloidN;

p = schema.prop(cls,'Head1FaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHead1,'FaceColor'};
p.GetFunction = {@localGetFromHead1,'FaceColor',colorFun};

p = schema.prop(cls,'Head1FaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p.SetFunction = {@localSetToHead1,'FaceAlpha'};
p.GetFunction = {@localGetFromHead1,'FaceAlpha'};

p = schema.prop(cls,'Head1LineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToHead1,'LineWidth',widthFun};
p.GetFunction = {@localGetFromHead1,'LineWidth'};
p.Visible='off';

p = schema.prop(cls,'Head1EdgeColor','patchEdgeColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHead1,'EdgeColor'};
p.GetFunction = {@localGetFromHead1,'EdgeColor',colorFun};

p = schema.prop(cls,'Head1Color','lineColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible = 'off';
p.SetFunction = @localSetHead1Color;

p = schema.prop(cls,'Head1ColorMode','axesXLimModeType');
p.FactoryValue = 'auto';
p.Visible = 'off';
p.SetFunction = @localSetHead1ColorMode;

p = schema.prop(cls,'Head1LineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p.SetFunction = {@localSetToHead1,'LineStyle'};
p.GetFunction = {@localGetFromHead1,'LineStyle'};

p = schema.prop(cls,'Head1Width','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;

p = schema.prop(cls,'Head1Length','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;

p = schema.prop(cls,'Head1Size','double');
p.AccessFlags.Init = 'on';
p.Visible = 'off';
p.FactoryValue = 10;
p.SetFunction = {@localSetHead1Size,widthFun};

% Head 2 Properties:
p = schema.prop(cls,'Head2Handle','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible = 'off';

p = schema.prop(cls,'Head2Style','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';

p = schema.prop(cls,'Head2BackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p.SetFunction = @localSetHeadBackDepth;

p = schema.prop(cls,'Head2RosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p.SetFunction = @localSetHeadRosePQ;

p = schema.prop(cls,'Head2HypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p.SetFunction = @localSetHeadHypocycloidN;

p = schema.prop(cls,'Head2FaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHead2,'FaceColor'};
p.GetFunction = {@localGetFromHead2,'FaceColor',colorFun};

p = schema.prop(cls,'Head2FaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p.SetFunction = {@localSetToHead2,'FaceAlpha'};
p.GetFunction = {@localGetFromHead2,'FaceAlpha'};

p = schema.prop(cls,'Head2LineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToHead2,'LineWidth',widthFun};
p.GetFunction = {@localGetFromHead2,'LineWidth'};
p.Visible='off';

p = schema.prop(cls,'Head2EdgeColor','lineColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHead2,'EdgeColor'};
p.GetFunction = {@localGetFromHead2,'EdgeColor',colorFun};

p = schema.prop(cls,'Head2Color','patchEdgeColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible = 'off';
p.SetFunction = @localSetHead2Color;

p = schema.prop(cls,'Head2ColorMode','axesXLimModeType');
p.FactoryValue = 'auto';
p.Visible = 'off';
p.SetFunction = @localSetHead2ColorMode;

p = schema.prop(cls,'Head2LineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p.SetFunction = {@localSetToHead2,'LineStyle'};
p.GetFunction = {@localGetFromHead2,'LineStyle'};

p = schema.prop(cls,'Head2Width','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;

p = schema.prop(cls,'Head2Length','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;

p = schema.prop(cls,'Head2Size','double');
p.AccessFlags.Init = 'on';
p.Visible = 'off';
p.FactoryValue = 10;
p.SetFunction = {@localSetHead2Size,widthFun};

% Properties that reference both heads. These are all non-visible and are
% used by the scribe context menus and plot edit toolbar:
p = schema.prop(cls,'HeadStyle','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';
p.Visible = 'off';
p.SetFunction = {@localSetToHeads,{'Head1Style','Head2Style'},@localStyleCheck};
p.GetFunction = {@localGetFromHeads,{'Head1Style','Head2Style'},'mixed'};

p = schema.prop(cls,'HeadBackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1BackDepth','Head2BackDepth'}};
p.GetFunction = {@localGetFromHeads,{'Head1BackDepth','Head2BackDepth'},[]};

p = schema.prop(cls,'HeadRosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1RosePQ','Head2RosePQ'}};
p.GetFunction = {@localGetFromHeads,{'Head1RosePQ','Head2RosePQ'},[]};

p = schema.prop(cls,'HeadHypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1HypocycloidN','Head2HypocycloidN'}};
p.GetFunction = {@localGetFromHeads,{'Head1HypocycloidN','Head2HypocycloidN'},[]};

p = schema.prop(cls,'HeadColor','patchFaceColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible = 'off';
p.SetFunction = {@localSetToHeads,{'Head1Color','Head2Color'}};
p.GetFunction = {@localGetFromHeads,{'Head1Color','Head2Color'},'none',colorFun};

p = schema.prop(cls,'HeadColorMode','axesXLimModeType');
p.FactoryValue = 'auto';
p.Visible = 'off';
p.SetFunction = {@localSetToHeads,{'Head1ColorMode','Head2ColorMode'}};
p.GetFunction = {@localGetFromHeads,{'Head1ColorMode','Head2ColorMode'},'manual'};

p = schema.prop(cls,'HeadFaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1FaceColor','Head2FaceColor'}};
p.GetFunction = {@localGetFromHeads,{'Head1FaceColor','Head2FaceColor'},'none',colorFun};

p = schema.prop(cls,'HeadFaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1FaceAlpha','Head2FaceAlpha'}};
p.GetFunction = {@localGetFromHeads,{'Head1FaceAlpha','Head2FaceAlpha'},[]};

p = schema.prop(cls,'HeadLineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1LineWidth','Head2LineWidth'}};
p.GetFunction = {@localGetFromHeads,{'Head1LineWidth','Head2LineWidth'},[]};

p = schema.prop(cls,'HeadEdgeColor','lineColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1EdgeColor','Head2EdgeColor'}};
p.GetFunction = {@localGetFromHeads,{'Head1EdgeColor','Head2EdgeColor'},'none',colorFun};

p = schema.prop(cls,'HeadLineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p.SetFunction = {@localSetToHeads,{'Head1LineStyle','Head2LineStyle'}};
p.GetFunction = {@localGetFromHeads,{'Head1LineStyle','Head2LineStyle'},[]};

p = schema.prop(cls,'HeadWidth','double');
p.AccessFlags.Init = 'off'; 
p.FactoryValue = 10;
p.Visible = 'off';
p.SetFunction = {@localSetToHeads,{'Head1Width','Head2Width'}};
p.GetFunction = {@localGetFromHeads,{'Head1Width','Head2Width'},[]};

p = schema.prop(cls,'HeadLength','double');
p.AccessFlags.Init = 'off'; 
p.FactoryValue = 10;
p.Visible = 'off';
p.SetFunction = {@localSetToHeads,{'Head1Length','Head2Length'}};
p.GetFunction = {@localGetFromHeads,{'Head1Length','Head2Length'},[]};

p = schema.prop(cls,'HeadSize','double');
p.AccessFlags.Init = 'on';
p.Visible='off';
p.FactoryValue = 10;
p.SetFunction = {@localSetToHeads,{'Head1Size','Head2Size'}};
p.GetFunction = {@localGetFromHeads,{'Head1Size','Head2Size'}};

%-------------------------------------------------------------------%
function errorStruct = localStyleCheck(propValue)
% Make sure the value passed in for the double arrow style is not "mixed".

errorStruct = [];

if strcmpi(propValue,'mixed')
    errorStruct.message = sprintf('Cannot set the HeadStyle property to mixed');
    errorStruct.identifier = 'MATLAB:doublearrow:changedHeadStyle';
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
function valueStored = localSetHead1Size(hThis, valueProposed, errFun)
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
hThis.Head1Length = valueProposed;
hThis.Head1Width = valueProposed;
hThis.UpdateInProgress = false;

valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueStored = localSetHead2Size(hThis, valueProposed, errFun)
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
hThis.Head2Length = valueProposed;
hThis.Head2Width = valueProposed;
hThis.UpdateInProgress = false;

valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueStored = localChangeAll(hThis, valueProposed, propName, errFun)

% Set a property on all children of the object.
if nargin < 4
    localSetToTail(hThis,valueProposed,propName);
else
    localSetToTail(hThis,valueProposed,propName,errFun);
end

% Since the error checking has already been accomplished, leave out the
% last argument in the second call.
localSetToHead1(hThis,valueProposed,propName);
localSetToHead2(hThis,valueProposed,propName);

valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueStored = localSetToHeads(hThis, valueProposed, propName, errFun)
% Set a property on both heads using the optional error function "errFun"
% as input checking. The input argument "propName" is a cell array
% containing the properties that should be set.

if isempty(hThis.Head1Handle) || ~ishandle(hThis.Head1Handle)
    valueStored = valueProposed;
    return;
end
if isempty(hThis.Head2Handle) || ~ishandle(hThis.Head2Handle)
    valueStored = valueProposed;
    return;
end
if nargin > 3
    if ~iscell(errFun)
        errFun = {errFun};
    end
    error(feval(errFun{:},valueProposed));
end
% Set the properties
set(hThis,propName{1},valueProposed,propName{2},valueProposed);
valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueToCaller = localGetFromHeads(hThis, valueStored, propName, defaultResult, filterFun)
% Gets a property from both heads. If the values to not match, return a
% default result specified by the user.

if isempty(hThis.Head1Handle) || ~ishandle(hThis.Head1Handle)
    valueToCaller = valueStored;
elseif isempty(hThis.Head2Handle) || ~ishandle(hThis.Head2Handle)
    valueToCaller = valueStored;
else
    % Check if the two properties are equal. If they are, return the property.
    % Otherwise, return the default answer
    storedVal1 = get(hThis,propName{1});
    storedVal2 = get(hThis,propName{2});
    if isequal(storedVal1,storedVal2)
        valueToCaller = storedVal1;
    else
        valueToCaller = defaultResult;
    end
end

if nargin > 4
    if ~iscell(filterFun)
        filterFun = {filterFun};
    end
    valueToCaller = feval(filterFun{:},valueToCaller);
end

%-------------------------------------------------------------------%
function valueStored = localSetToTail(hThis, valueProposed, propName, errFun)
% Set a property on the line object using the optional error function
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
function valueToCaller = localGetFromTail(hThis, valueStored, propName,filterFun)
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
function valueStored = localSetToHead1(hThis, valueProposed, propName, errFun)
% Set a property on the head object using the option error function
% "errFun" as input checking
if ~isempty(hThis.Head1Handle) && ishandle(hThis.Head1Handle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.Head1Handle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromHead1(hThis, valueStored, propName, filterFun)
% Return a property from the head object

if ~isempty(hThis.Head1Handle) && ishandle(hThis.Head1Handle)
    valueToCaller = get(hThis.Head1Handle,propName);
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
function valueStored = localSetHead1Color(hThis, valueProposed)
% Update the head color.

valueStored = valueProposed;
hThis.Head1FaceColor = valueProposed;
hThis.Head1EdgeColor = valueProposed;
% If there is not an update in progress, set the "HeadColorMode" property
% to "manual"
if ~hThis.UpdateInProgress
    hThis.Head1ColorMode = 'manual';
end

%---------------------------------------------------------------------%
function valueStored = localSetHead1ColorMode(hThis, valueProposed)
% Update the head color mode.

valueStored = valueProposed;
if strcmpi(valueProposed,'manual');
    hThis.ColorProps(strcmpi(hThis.ColorProps,'Head1Color')) = [];
else
    hThis.ColorProps{end+1} = 'Head1Color';
    hThis.Head1Color = hThis.Color;
end

%-------------------------------------------------------------------%
function valueStored = localSetToHead2(hThis, valueProposed, propName, errFun)
% Set a property on the head object using the option error function
% "errFun" as input checking
if ~isempty(hThis.Head2Handle) && ishandle(hThis.Head2Handle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.Head2Handle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromHead2(hThis, valueStored, propName, filterFun)
% Return a property from the head object

if ~isempty(hThis.Head2Handle) && ishandle(hThis.Head2Handle)
    valueToCaller = get(hThis.Head2Handle,propName);
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
function valueStored = localSetHead2Color(hThis, valueProposed)
% Update the head color.

valueStored = valueProposed;
hThis.Head2FaceColor = valueProposed;
hThis.Head2EdgeColor = valueProposed;
% If there is not an update in progress, set the "HeadColorMode" property
% to "manual"
if ~hThis.UpdateInProgress
    hThis.Head2ColorMode = 'manual';
end

%---------------------------------------------------------------------%
function valueStored = localSetHead2ColorMode(hThis, valueProposed)
% Update the head color mode.

valueStored = valueProposed;
if strcmpi(valueProposed,'manual');
    hThis.ColorProps(strcmpi(hThis.ColorProps,'Head2Color')) = [];
else
    hThis.ColorProps{end+1} = 'Head2Color';
    hThis.Head2Color = hThis.Color;
end