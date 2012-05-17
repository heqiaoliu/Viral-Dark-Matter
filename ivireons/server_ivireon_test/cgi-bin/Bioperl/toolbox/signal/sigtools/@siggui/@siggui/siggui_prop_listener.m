function siggui_prop_listener(this, eventData)
%SIGGUI_PROP_LISTENER Listener to the public properties of the Filter Wizard

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.7.6.10 $  $Date: 2009/05/23 08:16:59 $ 

% If prop_listener is called with no inputs, we treat it as a global
% update.  If called with a string input we just update that property.
if nargin > 1,
    if ischar(eventData), prop = lower(eventData);
    else                  prop = lower(get(eventData.Source, 'Name')); end
else
    props = fieldnames(getstate(this));
    for indx = 1:length(props)
        prop_listener(this, props{indx});
    end
    return;
end

h = get(this, 'Handles');

% If is the property is not a field in the handles structure, ignore it
if ~isfield(h, prop), return; end
uistyle = lower(get(h.(prop), 'style'));

hprop = findprop(this, prop);

switch uistyle,
case 'checkbox',
    switch lower(get(hprop, 'DataType'))
        case {'bool', 'strictbool'}
            val = get(this, prop);
        case 'on/off'
            if strcmpi(get(this, prop), 'on'), val = 1;
            else                               val = 0; end
        case 'yes/no'
            if strcmpi(get(this, prop), 'yes'), val = 1;
            else                                val = 0; end
        otherwise
            error(generatemsgid('InternalError'), ...
                'Internal error: A checkbox cannot be mapped to a property of datatypes ''%s''.', ...
                get(findprop(this, prop), 'DataType'));
    end
    set(h.(prop), 'Value', val);
case {'edit', 'text'},
    switch lower(get(hprop, 'DataType')),
        case {'double', 'double_vector'}
            value = get(this, prop);
            if isreal(value)
                str = sprintf('%g', value);
            else
                if sign(imag(value)) == 1
                    signstr = '+';
                else
                    signstr = '';
                end
                str = sprintf('%g%s%gi', real(value), signstr, imag(value));
            end
        case 'string'
            str = get(this, prop);
        case 'string vector'
            str = get(this, prop);
            if isempty(str),
                str = '';
            else
                str = sprintf('%s\n', str{:});
                str(end) = [];
            end
    end
    set(h.(prop), 'String', str);
case 'popupmenu',
    value = lower(get(this, prop));
    if isnumeric(value), value = num2str(value); end
    
    % If we store the popupstrings (always english), get those, otherwise
    % get the strings in the popups.
    if isappdata(h.(prop), 'PopupStrings')
        allvs = lower(getappdata(h.(prop), 'PopupStrings'));
    else
        allvs = lower(get(h.(prop), 'String'));
    end
    % try for an exact match first.
    indx  = find(strcmpi(value, allvs));
    if isempty(indx),
        indx = strmatch(value, allvs);
        if isempty(indx)
            indx = 1;
        else
            indx = indx(1);
        end
    end
    set(h.(prop), 'Value', indx);
end

% [EOF]
