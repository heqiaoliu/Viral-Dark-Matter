function varargout=propedit(h,varargin)
%PROPEDIT  Graphical property editor
%   PROPEDIT edits all properties of any selected HG object through the
%   use of a graphical interface.  PROPEDIT(HandleList) edits the
%   properties for the object(s) in HandleList.  If HandleList is omitted,
%   the property editor will edit the current figure.
%
%   Launching the property editor will enable plot editing for the figure.
%
%   Example:
%       f=figure;
%       u1 = uicontrol('Style','push', 'parent', f,'pos',...
%           [20 100 100 100],'string','button1');
%       u2 = uicontrol('Style','push', 'parent', f,'pos',...
%           [150 250 100 100],'string','button2');
%       u3 = uicontrol('Style','push', 'parent', f,'pos',...
%           [250 100 100 100],'string','button3');
%       hlist = [u1 u2 u3];
%       propedit(hlist);
%
%   See also INSPECT, PLOTEDIT, PROPERTYEDITOR

%   PROPEDIT(HandleList,'-noselect') will not put selection handles around
%   the objects or update the SCRIBE internal list of selected handles.  Be
%   careful using this - it is really only intended to be used if you have already
%   used SCRIBE to select the object.
%
%   PROPEDIT(HandleList,'-noopen') will not force the property editor to open.
%   If the property editor has not been opened yet or is invisible, it will
%   not pop open.
%
%   PROPEDIT(HandleList,'-tTABNAME') will open the property editor to the
%   requested tab.  Note that TABNAME is case sensitive and may be affected by
%   internationalization.
%
%   PROPEDIT(HandleList,'v6') used to open the property editor window used in
%   versions 6 and earlier, but is now deprecated.
%
%   WARNSTR = PROPEDIT(...) will return warning messages as a string instead of
%   calling the warning command.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.127.4.21 $ $Date: 2006/12/20 07:19:14 $


%---- Error if the conditions are bad:
v6 = nargin > 1 && isa(varargin{1},'char') && any(strcmpi(varargin,'v6'));
if v6
    error ('MATLAB:propedit:V6', ...
    'The Version 6 property editor is no longer available. Sorry!')
end

error(javachk('awt'));

if (nargin > 0) && isa(h, 'char')
    if strcmpi(h, '-noopen')
        error ('MATLAB:propedit:NoopenFirst', ...
        'The -noopen argument requires that you provide a handle.')
    elseif strcmpi(h, '-noselect')
        error ('MATLAB:propedit:NoselectFirst', ...
            'The -noselect argument requires that you provide a handle.')
    elseif strmatch('-t', h)
        error ('MATLAB:propedit:TabFirst', ...
        'The -t argument requires that you provide a handle.')
    elseif strcmpi(h, 'v6')
        error ('MATLAB:propedit:V6', ...
        'The Version 6 property editor is no longer available. Sorry!')
    else
        error ('MATLAB:propedit:NeedsHandle', ...
        'The first argument must be an object or a list of objects, not a string.')
    end
end


%---- Parse the arguments:   
noOpen=any(strcmpi(varargin,'-noopen'));

noSelect=any(strcmpi(varargin,'-noselect'));
if (nargin > 0) && ~noSelect
    if ishandle(h)
        noSelect = ~plotedit(ancestor(h, 'figure'),'isactive');
    else
        noSelect = false;
    end
end

matchedTab = strmatch('-t',varargin);
if length(matchedTab)>0
    tabName=varargin{matchedTab(1)};
    tabName=tabName(3:end); %#ok<NASGU>
else
    tabName=''; %#ok<NASGU>
end

% Make sure a figure exists and that currentFigure is properly initialized.
if nargin == 0 || isempty(h)
    h = gcf;
end
h=unique(h(ishandle(h)));  % strips out duplicates and invalid handles
if (numel(h) == 0)
    error ('MATLAB:propedit:NoValidHandles', ...
        'No valid objects or handles were provided to propedit.');
end
currentFigure = ancestor(h(1),'figure');
if isempty(currentFigure)
    if isa(h(1), 'graphics.datacursormanager')
        currentFigure = get(h(1), 'Figure');
    else
        currentFigure = gcf;
    end
end

if isa(handle(h), 'figure') && ...
    (strncmpi (get(handle(h),'Tag'), 'Msgbox', 6) || ...
     strcmpi (get(handle(h),'WindowStyle'), 'Modal'))
    return
end


if ~isempty(h)
    a = requestJavaAdapter(h);
    com.mathworks.mlservices.MLInspectorServices.inspectIfOpen(a);
    if ~noSelect && any (h ~= 0),
        selectobject (h,'replace');
    end
    if ~noOpen
        propertyeditor (double(currentFigure), 'show');
        drawnow;
    end
    if propeditorIsOpen
        props = getplottool (currentFigure, 'propertyeditor');
        if ~isempty (a) && ~isempty(props)
            if iscell (a)
                a = [a{:}];
                awtinvoke (props, 'setObjects', a);
            else
                awtinvoke (props, 'setObject(Ljava/lang/Object;)', a);
            end
            drawnow
        end
    end
    warnStr='';
else
    warnStr='No valid objects passed to propedit';
end

if nargout>0
    varargout{1}=warnStr;
elseif ~isempty(warnStr)
    warning('MATLAB:propedit:InvalidObjectsPassed',warnStr);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isOpen = propeditorIsOpen
if ispref('plottools', 'isdesktop')
    rmpref('plottools', 'isdesktop');
end
dt=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
isOpen = dt.isClientShowing('Property Editor');
