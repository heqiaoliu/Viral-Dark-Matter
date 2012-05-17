function schema
%SCHEMA defines the scribe.line schema
%

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $  $  $

hPk = findpackage('scribe'); % Scribe package
cls = schema.class(hPk, 'line', hPk.findclass('scribeobject1D'));

% Obtain a handle to the width check function:
widthFun = {@graph2dhelper,'widthCheck'};
% Obtain a handle to the color filter function:
colorFun = {@graph2dhelper,'colorFilter'};

% Line properties:
% Store a handle to the line:
p = schema.prop(cls,'LineHandle','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Since there is a global color property, and there is only one object in
% this particular group, hide the color
p = schema.prop(cls,'LineColor','lineColorType');
p.Visible = 'off';
p.SetFunction = {@localSetToLine,'Color'};
p.GetFunction = {@localGetFromLine,'Color',colorFun};
p.FactoryValue = get(0,'DefaultLineColor');

% Line Width:
p = schema.prop(cls,'LineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.SetFunction = {@localSetToLine,'LineWidth',widthFun};
p.GetFunction = {@localGetFromLine,'LineWidth'};

% Line Style:
p = schema.prop(cls,'LineStyle','lineLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.SetFunction = {@localSetToLine,'LineStyle'};
p.GetFunction = {@localGetFromLine,'LineStyle'};

%-------------------------------------------------------------------%
function valueStored = localSetToLine(hThis, valueProposed, propName, errFun)
% Set a property on the line object using the option error function
% "errFun" as input checking
if ~isempty(hThis.LineHandle) && ishandle(hThis.LineHandle)
    if nargin > 3
        if ~iscell(errFun)
            errFun = {errFun};
        end
        error(feval(errFun{:},valueProposed));
    end
    set(hThis.LineHandle,propName,valueProposed);
end
valueStored = valueProposed;

%--------------------------------------------------------------------%
function valueToCaller = localGetFromLine(hThis, valueStored, propName, filterFun)
% Return a property from the line object

if ~isempty(hThis.LineHandle) && ishandle(hThis.LineHandle)
    valueToCaller = get(hThis.LineHandle,propName);
else
    valueToCaller = valueStored;
end

if nargin > 3
    if ~iscell(filterFun)
        filterFun = {filterFun};
    end
    valueToCaller = feval(filterFun{:},valueToCaller);
end