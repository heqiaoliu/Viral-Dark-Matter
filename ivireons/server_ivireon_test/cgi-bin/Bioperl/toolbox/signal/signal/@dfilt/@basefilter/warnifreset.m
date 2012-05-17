function warnifreset(h, prop, value)
%WARNIFRESET Throw a warning if PersistentMemory is false
%   WARNIFRESET(H, PROP) Throw a warning using PROP as the property name.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.6 $  $Date: 2005/06/16 08:18:06 $

% This should be private/protected

% If the prop is empty, this must be the constructor, do not warn.
if nargin < 3, value = get(h, prop); end
if isempty(value), return; end

% Only warn if PersistentMemory is false
if ~h.PersistentMemory,
    
    if nargin < 2,
        prop = '';
    else
        prop = sprintf('''%s'' ', prop);
    end
    
    % Turn the backtrace off, we will build our own.
    w = warning('query', 'backtrace');
    warning('off', 'backtrace');
    
    % Send the warning
    id = generatemsgid('PropWillBeReset');
    warning(id, 'The %s%s\n%s', prop, ...
                'property will be reset to the value specified at construction before filtering.', ...
                'Set the ''PersistentMemory'' flag to ''true'' to avoid changing this property value.');
    
    % Reset the warning states
    warning('backtrace', w.state);
    
    wid  = warning('query', id);
    
    % If all the warning states are ON show the stack
    if ~isdeployed && all(strcmpi({wid.state, w.state}, 'on')),
        dbstack(2)
    end
end

% [EOF]
