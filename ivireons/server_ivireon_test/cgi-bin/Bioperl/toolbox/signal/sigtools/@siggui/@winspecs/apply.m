function apply(this)
%APPLY Update the GUI and send an event

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2008/08/22 20:33:26 $

% If the Apply button is disabled or the GUI not rendered
isModified = get(this, 'isModified');
if ~isModified
    return;
end

new_length = evaluatevars(this.Length);

window = get(this, 'Window');

if isa(window, 'sigwin.variablelength')
    set(window, 'Length', new_length);
end

p = getparameter(this);

if ~isempty(p)
    set(window, p{1}, evaluatevars(this.Parameters.(p{1})));
    if ~isempty(p{2})
        set(window, p{2}, evaluatevars(this.Parameters.(p{2})));
    end
    data = generate(window);
elseif isa(window, 'sigwin.samplingflagwin')
    set(window, 'SamplingFlag', this.SamplingFlag);
    data = generate(window);
elseif isa(window, 'sigwin.userdefined')
    str = get(this, 'MATLABExpression');

    if isempty(str),
        error(generatemsgid('GUIErr'),'Specify a MATLAB Expression.');
    end

    % Error checking
    data = evalin('base', str);
    if ~isnumeric(data),
        error(generatemsgid('MustBeNumeric'),'Numeric array expected.');
    else,
        [M,N] = size(data);
        if M==1,
            data = data(:);
        end
        if size(data,2)~=1,
            error(generatemsgid('InvalidDimensions'),'Vector expected.');
        end
    end

    % Instantiate a new window object
    window.MATLAB_expression = str;
    data = generate(window);

    % Set the Length property
    set(this, 'Length', sprintf('%d', length(data)));
else
    data = generate(window);
end

% Set the 'Data' property
set(this, 'Data', data(:));

% Send an event
newstate = getstate(this);
hEventData = sigdatatypes.sigeventdata(this, 'NewState', newstate);
send(this, 'NewState', hEventData);

% Reset the isModified flag
set(this, 'isModified', 0);

% [EOF]
