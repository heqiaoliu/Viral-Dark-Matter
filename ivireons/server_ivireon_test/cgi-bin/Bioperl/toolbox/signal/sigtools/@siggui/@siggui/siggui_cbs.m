function cbs = siggui_cbs(this) %#ok
%SIGGUI_CBS Generic Callbacks for SIGGUI objects
%   SIGGUI_CBS Returns a structure of function handles to be used as
%   callbacks.
%
%   method_cb(hcbo, eventStruct, this, method, transstr, varargin) will
%   call the method like this:
%
%   method(this, varargin{:})
%
%   property_cb(hcbo, eventStruct, property, transstr) will set the
%   property to sync up with the UIControl hcbo that sent the callback.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.11 $  $Date: 2009/05/23 08:16:58 $ 

cbs.method   = @method_cb;
cbs.property = @property_cb;
cbs.event    = @event_cb;

% ----------------------------------------------------------------
function method_cb(hcbo, eventStruct, this, method, transstr, varargin) %#ok

error(nargchk(4,inf,nargin,'struct'));

% Change the pointer to a 'watch'
hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

% Set the warning state to off
w = warning('off'); %#ok
lastwarn('');

% Call the method
try
    
    feval(method, this, varargin{:});
catch ME
    try
        
        % Send the error, clean up the message to work around
        % udd/mexception issue.
        senderror(this, ME.identifier, cleanerrormsg(ME.message));

    catch
        % NO OP, if there is something wrong with the transaction we dont
        % want to send an error.
    end
    
end

% Reset the warning state and send any new warnings
warning(w);
sendwarning(this);

% Reset the figure pointer
set(hFig, p{:});

% ----------------------------------------------------------------
function property_cb(hcbo, eventStruct, this, property, tstr) %#ok

error(nargchk(4,5,nargin,'struct'));

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

w = warning('off'); %#ok
lastwarn('');

uistyle = lower(get(hcbo, 'Style'));

% Listboxes that can only select one thing act like popups.
if strcmpi(uistyle, 'listbox') && (get(hcbo, 'Max')-get(hcbo, 'Min')) < 2,
    uistyle = 'popupmenu';
end

hprop = findprop(this, property);

% Get the new value from the callback object
switch uistyle
    case 'checkbox'
        switch lower(get(hprop, 'DataType'))
            case {'bool', 'strictbool'}
                newvalue = get(hcbo, 'Value');
            case 'on/off'
                if get(hcbo, 'Value'), newvalue = 'On';
                else                   newvalue = 'Off'; end
            case 'yes/no'
                if get(hcbo, 'Value'), newvalue = 'Yes';
                else                   newvalue = 'No'; end
        end
        
    case 'edit'
        newvalue = fixup_uiedit(hcbo);
        newvalue = newvalue{1};
        if strcmpi(get(hprop, 'DataType'), 'string vector'),
            newvaluecell = cell(1, size(newvalue, 1));
            for indx = 1:size(newvalue, 1),
                newvaluecell{indx} = deblank(newvalue(indx, :));
            end
            newvalue = newvaluecell;
        end
    case 'popupmenu'
        newvalue = lclpopupstr(hcbo);
    case 'listbox'
        indx = get(hcbo, 'Value');
        str  = get(hcbo, 'String');
        newvalue = str(indx);
end

% Perform the property setting.
try
    set(this, property, newvalue);
    sendfiledirty(this);
    send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));
catch ME
    senderror(this, ME.identifier, ME.message);
end

warning(w);
sendwarning(this);

set(hFig, p{:});

%-------------------------------------------------------------------------
function string = lclpopupstr(hcbo)

if isappdata(hcbo, 'PopupStrings')
    strings = getappdata(hcbo, 'PopupStrings');
else
    strings = get(hcbo, 'String');
end

index  = get(hcbo, 'Value');
string = strings{index};

%-------------------------------------------------------------------------
function event_cb(hcbo, eventStruct, this, event, data) %#ok

error(nargchk(4,5,nargin,'struct'));

% Set up the figure's pointer
hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

w = warning('off'); %#ok
lastwarn('');

% Build the eventdata.  If data was passed in, use sigeventdata.
if nargin > 4, ed = sigdatatypes.sigeventdata(this, event, data);
else           ed = handle.EventData(this, event); end

% Send the event
send(this, event, ed);

warning(w);
sendwarning(this);

% Reset the figure's pointer
set(hFig, p{:});

% [EOF]
