function schema
%Schema for the uitab class. 
%   This is a subclass of the uicontainer
%   component. It defines one new property in addition to the default
%   uicontainer properties
%
%   Title - The title of the tab

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/09/12 19:01:07 $

%% Package and class info
pk = findpackage('uitools');
hg = findpackage('hg');
c = schema.class(pk,'uitab', hg.findclass('uicontainer'));

% Override the Type property
p = schema.prop(c, 'Type', 'String');
set(p, 'AccessFlags.PublicGet','on','AccessFlags.PublicSet','off');
set(p, 'GetFunction', @getType);

% Title property
schema.prop(c, 'Title', 'String');

% This is a property designed to ensure that the 'Visible' property is
% read only to the users.  However, when the uitabgroup needs to change the
% visibility of its children, it will call the updateVisibility method on
% the uitab.  The uitab will determine its own 'Visiblity' based on whether
% self is selected in the uitabgroup
p = schema.prop(c, 'OKToModifyVis', 'bool');
set(p, 'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off', ...
       'AccessFlags.PrivateGet','on','AccessFlags.PrivateSet','on', ...
       'Visible', 'off');

% Add a listener for whenever an instance that is created.
schema.prop(p, 'ClassListener', 'handle');
p.ClassListener = handle.listener(c, 'ClassInstanceCreated', @instanceCreated);

%//////////////////////////////////////////////////////////////////////////
function instanceCreated(src, evt)
h = evt.Instance;
h.OKToModifyVis = false;
h.updateVisibility;
h.BackgroundColor = 'none';

listener = handle.listener(h, h.findprop('BackgroundColor'), ...
    'PropertyPostSet', @backgroundColorCallback);
listener(end+1) = handle.listener(h, h.findprop('Visible'), ...
    'PropertyPostSet', {@setVisibleCallback, h});
setappdata(double(h),'Listener', listener);

%//////////////////////////////////////////////////////////////////////////
function result = getType(src, evt)
result = 'uitab';

% %//////////////////////////////////////////////////////////////////////////
function setVisibleCallback(src, evt, tp)
tp = handle(tp);
if (tp.isVisHidden == true)
    tp.updateVisibility;
    warning('MATLAB:schema:CannotSetVisible', ...
            ['Cannot set the Visible property of the uitab.\n', ...
             'This will become an error in a future release']);
end

%//////////////////////////////////////////////////////////////////////////
function backgroundColorCallback(src, evt)
warning('MATLAB:schema:CannotSetBackgroundColor', ...
        ['Cannot set the BackgroundColor property of the uitab.\n', ...
         'This will become an error in a future release']);
tp = double(evt.AffectedObject);
set(tp, 'BackgroundColor', 'none');









