function schema
%SCHEMA defines the scribe.scriberect schema
%

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $  $  $

hPk = findpackage('scribe'); % Scribe package
cls = schema.class(hPk, 'scriberect', hPk.findclass('scribeobject2D'));

% Obtain a handle to the width check function:
widthFun = {@graph2dhelper,'widthCheck'};
% Obtain a handle to the color filter function:
colorFun = {@graph2dhelper,'colorFilter'};

% Define the properties of the rectangle:

% Face Properties:
% Store a handle to the Face:
p = schema.prop(cls,'FaceHandle','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Face Color:
p = schema.prop(cls,'FaceColor','surfaceFaceColorType');
p.FactoryValue = 'none';
p.Visible = 'on';
p.AccessFlags.Init = 'on';
p.SetFunction = @localSetFaceColor;
p.GetFunction = @localGetFaceColor;

% Face Alpha Property:
p = schema.prop(cls,'FaceAlpha','NReals');
p.AccessFlags.Init = 'on';
p.FactoryValue = 1.0;
p.SetFunction = {@localSetToSurf,'FaceAlpha'};
p.GetFunction = {@localGetFromSurf,'FaceAlpha'};

% Image Property:
p = schema.prop(cls,'Image','surfaceCDataType');
p.Visible = 'off';
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'off';
p.FactoryValue = [];

% Rectangle Properties:
% Store a handle to the Rectange:
p = schema.prop(cls,'RectHandle','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Line Width Property. This corresponds to the width of the edges of the
% rectangle.
p = schema.prop(cls,'LineWidth','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToRect,'LineWidth',widthFun};
p.GetFunction = {@localGetFromRect,'LineWidth'};

% Edge Color Property:
% This property is set by the "Color" property, so it will be set to
% "Visible" off.
p = schema.prop(cls,'EdgeColor','surfaceEdgeColorType');
p.AccessFlags.Init = 'on';
p.Visible = 'off';
p.FactoryValue = get(0,'DefaultLineColor');
p.SetFunction = {@localSetToRect,'EdgeColor'};
p.GetFunction = {@localGetFromRect,'EdgeColor',colorFun};

% Line Style Property. This corresponds to the line style of the edges of
% the rectangle.
p = schema.prop(cls,'LineStyle','surfaceLineStyleType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.SetFunction = {@localSetToRect,'LineStyle'};
p.GetFunction = {@localGetFromRect,'LineStyle'};

%------------------------------------------------------------------%
function valueStored = localSetFaceColor(hThis, valueProposed)
% Set the face color of the rectangle.
if ~isempty(hThis.FaceHandle) && ishandle(hThis.FaceHandle)
    % If the "Image" property has been set, do not forward the set to the
    % underlying object. Otherwise, do.
    if isempty(hThis.Image)
        set(hThis.FaceHandle,'FaceColor',valueProposed);
    end
end
valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueToCaller = localGetFaceColor(hThis, valueStored)
% Get the face color of the rectangle.

if ~isempty(hThis.FaceHandle) && ishandle(hThis.FaceHandle)
    % If the "Image" property has been set, do not forward the get to the
    % underlying object. Otherwise, do.
    color = get(hThis.FaceHandle,'FaceColor');
    if isempty(hThis.Image) && ~strcmpi(color,'texturemap')
        valueToCaller = get(hThis.FaceHandle,'FaceColor');
    else
        valueToCaller = valueStored;
    end
else
    valueToCaller = valueStored;
end

if isempty(valueToCaller)
    valueToCaller = [0 0 0];
end

%-------------------------------------------------------------------%
function valueStored = localSetToRect(hThis, valueProposed, propName, errFun)
% Set a property on the line object using the option error function
% "errFun" as input checking
if ~isempty(hThis.RectHandle) && ishandle(hThis.RectHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.RectHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromRect(hThis, valueStored, propName, filterFun)
% Return a property from the line object

if ~isempty(hThis.RectHandle) && ishandle(hThis.RectHandle)
    valueToCaller = get(hThis.RectHandle,propName);
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
function valueStored = localSetToSurf(hThis, valueProposed, propName, errFun)
% Set a property on the line object using the optional error function
% "errFun" as input checking
if ~isempty(hThis.FaceHandle) && ishandle(hThis.FaceHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.FaceHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromSurf(hThis, valueStored, propName)
% Return a property from the line object

if ~isempty(hThis.FaceHandle) && ishandle(hThis.FaceHandle)
    valueToCaller = get(hThis.FaceHandle,propName);
else
    valueToCaller = valueStored;
end