function schema
%SCHEMA defines the scribe.scriberect schema
%
%  See also PLOTEDIT

%   Copyright 1984-2006 The MathWorks, Inc.

hPk = findpackage('scribe'); % Scribe package
cls = schema.class(hPk, 'scribeellipse', hPk.findclass('scribeobject2D'));

% Obtain a handle to the width check function:
widthFun = {@graph2dhelper,'widthCheck'};
% Obtain a handle to the color filter function:
colorFun = {@graph2dhelper,'colorFilter'};

% Ellipse Properties:
p = schema.prop(cls,'EllipseHandle','handle');
p.AccessFlags.Serialize = 'off';
p.Visible='off';

% Face Color Property:
p = schema.prop(cls,'FaceColor','surfaceFaceColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'none';
p.SetFunction = {@localSetToEllipse,'FaceColor'};
p.GetFunction = {@localGetFromEllipse,'FaceColor',colorFun};

% Line Width Property. This corresponds to the width of the edges of the
% rectangle.
p = schema.prop(cls,'LineWidth','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToEllipse,'LineWidth',widthFun};
p.GetFunction = {@localGetFromEllipse,'LineWidth'};

% Edge Color Property:
% This property is set by the "Color" property, so it will be set to
% "Visible" off.
p = schema.prop(cls,'EdgeColor','surfaceEdgeColorType');
p.AccessFlags.Init = 'on';
p.Visible = 'off';
p.FactoryValue = get(0,'DefaultLineColor');
p.SetFunction = {@localSetToEllipse,'EdgeColor'};
p.GetFunction = {@localGetFromEllipse,'EdgeColor',colorFun};

% Line Style Property. This corresponds to the line style of the edges of
% the ellipse.
p = schema.prop(cls,'LineStyle','surfaceLineStyleType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.SetFunction = {@localSetToEllipse,'LineStyle'};
p.GetFunction = {@localGetFromEllipse,'LineStyle'};

% We have a bounding rectangle that is used for hittest purposes. Store a
% handle to it.
p = schema.prop(cls,'BoundingRectHandle','handle');
p.AccessFlags.Serialize = 'off';
p.Visible='off';

%-------------------------------------------------------------------%
function valueStored = localSetToEllipse(hThis, valueProposed, propName, errFun)
% Set a property on the line object using the option error function
% "errFun" as input checking
if ~isempty(hThis.EllipseHandle) && ishandle(hThis.EllipseHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.EllipseHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromEllipse(hThis, valueStored, propName, filterFun)
% Return a property from the line object

if ~isempty(hThis.EllipseHandle) && ishandle(hThis.EllipseHandle)
    valueToCaller = get(hThis.EllipseHandle,propName);
else
    valueToCaller = valueStored;
end

if nargin > 3
    if ~iscell(filterFun)
        filterFun = {filterFun};
    end
    valueToCaller = feval(filterFun{:},valueToCaller);
end