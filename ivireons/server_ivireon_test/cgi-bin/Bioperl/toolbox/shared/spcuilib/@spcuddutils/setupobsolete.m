function setupobsolete(p, newprop, warn)
%SETUPOBSOLETE Setup a property to be obsolete.
%   SETUPOBSOLETE(HP) setup the property specified by the SCHEMA.PROP
%   object to be obsolete.  A warning will be thrown when this property is
%   accessed.
%
%   SETUPOBSOLETE(HP, NEWPROP) setup the property so that in addition to
%   the warning the property NEWPROP is used as the storage property.
%
%   SETUPOBSOLETE(HP, NEWPROP, false) do not throw a warning, but simply
%   set and get the new property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 22:41:28 $

% NEWPROP and WARN are optional.
if nargin < 3, warn    = true; end
if nargin < 2, newprop = '';   end
if islogical(newprop)
    warn = newprop;
    newprop = '';
end

% Get the property name from P, so callers don't have to pass it.
oldprop = get(p, 'Name');

set(p, 'AccessFlags.Init', 'off', ...
    'SetFunction', {@setobsoleteprop, oldprop, newprop, warn}, ...
    'GetFunction', {@getobsoleteprop, oldprop, newprop, warn}, ...
    'Visible', 'off');

% -------------------------------------------------------------------------
function value = setobsoleteprop(this, value, oldprop, newprop, warn)

p = findprop(this, oldprop);

% Do not warn in the set when the abortset is on because the get will warn.
if strcmpi(get(p, 'AccessFlags.AbortSet'), 'on')
    warn = false;
end

if warn
    obsoletewarning(oldprop, newprop);
end

if ~isempty(newprop)
    % Store the value in the new property.
    set(this, newprop, value)
    
    % Don't store anything.  The property needs to have a get function as well.
    value = [];
end

% -------------------------------------------------------------------------
function value = getobsoleteprop(this, value, oldprop, newprop, warn)

if nargin < 5, warn    = false; end
if nargin < 4, newprop = '';    end
if islogical(newprop)
    warn = newprop;
    newprop = '';
end

if warn
    obsoletewarning(oldprop, newprop);
end

if ~isempty(newprop)
    % Store the value in the new property.
    value = get(this, newprop);
end

% -------------------------------------------------------------------------
function varargout = obsoletewarning(oldprop, newprop)

if isempty(newprop)
    advice = '';
else
    advice = sprintf('  Use the ''%s'' property instead.', newprop);
end

warnmsg.identifier = generatemsgid('obsoleteProp');
warnmsg.message = sprintf('The ''%s'' property is obsolete.  %s %s', oldprop, ...
    sprintf('Using the ''%s'' property still works,', oldprop), ...
    sprintf('but will be removed in the future.%s', advice));

if nargout
    varargout = {warnmsg};
else
    warning(warnmsg.identifier, warnmsg.message);
end

% [EOF]
