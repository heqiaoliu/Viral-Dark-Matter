function schema
%SCHEMA defines the scribe.TEXTBOX schema
%

%   Copyright 1984-2009 The MathWorks, Inc.

pkg   = findpackage('scribe'); % Scribe package
cls = schema.class(pkg, 'textbox', pkg.findclass('scribeobject2D'));

% Obtain a handle to the width check function:
widthFun = {@graph2dhelper,'widthCheck'};
% Obtain a handle to the color filter function:
colorFun = {@graph2dhelper,'colorFilter'};

% Rectangle properties:
p = schema.prop(cls,'RectHandle','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(cls,'BackgroundColor','surfaceFaceColorType');
p.FactoryValue = 'none';
p.SetFunction = @localSetBackgroundColor;
p.GetFunction = @localGetBackgroundColor;

p = schema.prop(cls,'FaceAlpha','NReals');
p.FactoryValue = 1.0;
p.SetFunction = {@localSetToRect,'FaceAlpha'};
p.GetFunction = {@localGetFromRect,'FaceAlpha'};

p = schema.prop(cls,'Image','MATLAB array');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = [];
p.Visible = 'off';

p = schema.prop(cls,'LineWidth','double');
p.FactoryValue = get(0,'DefaultAxesLineWidth');
p.SetFunction = {@localSetToRect,'LineWidth',widthFun};
p.GetFunction = {@localGetFromRect,'LineWidth'};

p = schema.prop(cls,'EdgeColor','surfaceEdgeColorType');
p.FactoryValue = get(0,'DefaultAxesXColor');
p.SetFunction = {@localSetToRect,'EdgeColor'};
p.GetFunction = {@localGetFromRect,'EdgeColor',colorFun};

p = schema.prop(cls,'LineStyle','surfaceLineStyleType');
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.SetFunction = {@localSetToRect,'LineStyle'};
p.GetFunction = {@localGetFromRect,'LineStyle'};

p = schema.prop(cls,'FirstEdit','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';

% Special Textbox Properties:

p = schema.prop(cls,'Editable','on/off');
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(cls,'Maxw','double');
p.FactoryValue = 700;
p.Visible = 'off';

p = schema.prop(cls,'Maxh','double');
p.FactoryValue = 700;
p.Visible = 'off';

p = schema.prop(cls,'Minw','double');
p.FactoryValue = 25;
p.Visible = 'off';

p = schema.prop(cls,'Minh','double');
p.FactoryValue = 25;
p.Visible = 'off';

% Text Properties:

p = schema.prop(cls,'TextHandle','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% The "Color" property will maintain the text color
p = schema.prop(cls,'TextColor','textColorType');
p.FactoryValue = get(0,'DefaultTextColor');
p.Visible = 'off';
p.SetFunction = {@localSetToText,'Color'};
p.GetFunction = {@localGetFromText,'Color',colorFun};

p = schema.prop(cls,'Editing','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';
p.SetFunction = {@localSetToText,'Editing'};
p.GetFunction = {@localGetFromText,'Editing'};

p = schema.prop(cls,'FitHeightToText','on/off');
p.FactoryValue = 'off';
p.Visible = 'off';

p = schema.prop(cls,'FitBoxToText','on/off');
p.FactoryValue = 'on';

p = schema.prop(cls,'EditListener','handle');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'FontAngle','textFontAngleType');
p.FactoryValue = get(0,'DefaultTextFontAngle');
p.SetFunction = {@localSetToText,'FontAngle'};
p.GetFunction = {@localGetFromText,'FontAngle'};

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
p.FactoryValue = 'left';
p.SetFunction = {@localSetToText,'HorizontalAlignment'};
p.GetFunction = {@localGetFromText,'HorizontalAlignment'};

% Margin is distance between outer rect and inner text
% and is distinct from margin within the text object, which is set to 1.
p = schema.prop(cls,'Margin','double');
p.FactoryValue = 5;

% Keep track whether the last string edited was a new line.
p = schema.prop(cls,'EndsWithNewLine','bool');
p.Visible = 'off';
p.FactoryValue = false;

p = schema.prop(cls,'String','textStringType');
p.FactoryValue = {''};

p = schema.prop(cls,'Interpreter','textInterpreterType');
p.FactoryValue = get(0,'DefaultTextInterpreter');
p.SetFunction = {@localSetToText,'Interpreter'};
p.GetFunction = {@localGetFromText,'Interpreter'};

p = schema.prop(cls,'VerticalAlignment','textVerticalAlignmentType');
p.FactoryValue = 'top';
p.SetFunction = @localSetVerticalAlignment;

%------------------------------------------------------------------%
function valueStored = localSetBackgroundColor(hThis, valueProposed)
% Set the face color of the rectangle.

if ~isempty(hThis.RectHandle) && ishandle(hThis.RectHandle)
    % If the "Image" property has been set, do not forward the set to the
    % underlying object. Otherwise, do.
    if isempty(hThis.Image)
        set(hThis.RectHandle,'FaceColor',valueProposed);
        % Also set the background color on the text object
        if ~isempty(hThis.TextHandle) && ishandle(hThis.TextHandle)
            set(hThis.TextHandle,'BackgroundColor',valueProposed);
        end
    end
end
valueStored = valueProposed;

%-------------------------------------------------------------------%
function valueToCaller = localGetBackgroundColor(hThis, valueStored)
% Get the face color of the rectangle.

if ~isempty(hThis.RectHandle) && ishandle(hThis.RectHandle)
    % If the "Image" property has been set, do not forward the get to the
    % underlying object. Otherwise, do.
    color = get(hThis.RectHandle,'FaceColor');
    if isempty(hThis.Image) && ~strcmpi(color,'texturemap')
        valueToCaller = get(hThis.RectHandle,'FaceColor');
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
function valueStored = localSetVerticalAlignment(hThis, valueProposed)
% Set VerticalAlignment on the text object appropriately
if ~isempty(hThis.TextHandle) && ishandle(hThis.TextHandle)
    switch valueProposed
        case 'cap'
            textVAlign = 'top';
        case 'bottom'
            % visually, baseline is more natural for text alignment
            % 'bottom' would align with the tail of "g" as opposed to the
            % circle
            textVAlign = 'baseline';
        otherwise
            textVAlign = valueProposed;
    end
    set(hThis.TextHandle,'VerticalAlignment',textVAlign);
end
valueStored = valueProposed;
