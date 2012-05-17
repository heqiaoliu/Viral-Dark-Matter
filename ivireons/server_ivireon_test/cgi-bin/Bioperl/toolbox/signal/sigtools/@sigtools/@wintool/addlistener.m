function addlistener(hWT, prop, callback, source, target, filterOnListener)
%ADDLISTENER Add a listener to WinTool
%   ADDLISTENER(hWT, PROP, CALLBACK, SOURCE) Add a listener to the PROP
%   property of the SOURCE object whose callback is CALLBACK.
%
%   ADDLISTENER(hWT, PROP, CALLBACK, SOURCE, TARGET) An alternative target
%   can also be specified.  TARGET will be passed as the first argument
%   to the callback function, while EVENTDATA will remain as the second
%   input argument.
%
%   ADDLISTENER(hWT, PROP, CALLBACK, SOURCE, TARGET, FILTERONLISTENER) 
%   An alternative filter on the listener can also be specified.  By default
%   the listener is stored in the 'WhenRenderedListener' property so that it is 
%   fired only when the object is rendered.

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2010/05/20 03:10:50 $

error(nargchk(4,6,nargin,'struct'));
if nargin<6, filterOnListener = 'WhenRenderedListeners'; end

% Find the properties and event we can listen to
wt_p = findprop(source.classhandle, prop);
wt_e = findevent(source.classhandle, prop);

% Error checking
if isempty(wt_p) && isempty(wt_e),
    error(generatemsgid('NotAnEvent'),...
        '''%s'' is not an event or a property of WinTool.',prop);
end

% If findprop returned empty then prop must be an event.
% Create the listener
if isempty(wt_p),
    h = handle.listener(source, prop, callback);
else
    h = handle.listener(source, wt_p, 'PropertyPostSet', callback);
end

% If there is a 5th input it is the callback target.
if nargin >= 5,
    set(h,'CallbackTarget',target);
end

% Save the listener
Listeners = get(hWT, filterOnListener);
prop = lower(prop);
if isfield(Listeners,prop),
    indx = length(getfield(Listeners,prop)) + 1;
else
    indx = 1;
end
Listeners = setfield(Listeners,prop,{indx},h);

set(hWT, filterOnListener, Listeners);


% [EOF]
