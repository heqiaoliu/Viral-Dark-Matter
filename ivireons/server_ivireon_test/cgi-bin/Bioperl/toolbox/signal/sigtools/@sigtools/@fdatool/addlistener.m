function addlistener(hFDA,prop,callback,target)
%ADDLISTENER Add a listener to FDATool
%   ADDLISTENER(hFDA, PROP, CALLBACK) Add a listener to the PROP
%   property of the session of FDATool associated with hFDA whose 
%   callback is CALLBACK.
%
%   ADDLISTENER(hFDA, PROP, CALLBACK, TARGET) An alternative target
%   can also be specified.  TARGET will be passed as the first argument
%   to the callback function, while EVENTDATA will remain as the second
%   input argument.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2010/05/20 03:10:45 $

error(nargchk(3,4,nargin,'struct'));

% Find the package/class/property
fda_p = hFDA.findprop(prop);
fda_e = hFDA.classhandle.findevent(prop);

if isempty(fda_p) && isempty(fda_e),
    error(generatemsgid('NotAnEvent'),'''%s'' is not an event or a property of FDATool.',prop);
end

% If findprop returned empty then prop must be an event.
% Create the listener
if isempty(fda_p),
    lhandle = handle.listener(hFDA, prop, callback);
else
    lhandle = handle.listener(hFDA, fda_p, 'PropertyPostSet', callback);
end

% If there is a 4th input it is the callback target.
if nargin == 4,
    set(lhandle,'CallbackTarget',target);
end

% Save the listener
Listeners = get(hFDA,'Listeners');
if isempty(Listeners),
    Listeners = lhandle;
else
    Listeners(end+1) = lhandle;
end

set(hFDA,'Listeners',Listeners);

% [EOF]
