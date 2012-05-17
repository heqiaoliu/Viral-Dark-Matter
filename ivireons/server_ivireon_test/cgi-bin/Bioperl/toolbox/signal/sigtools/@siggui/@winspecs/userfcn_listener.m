function userfcn_listener(hSpecs, eventData)
%USERFCN_LISTENER Listener to the MATLAB_expression property

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2008/04/21 16:31:50 $

% This can be a private method

str = get(hSpecs, 'MATLAB_expression');

if ~isempty(str),
    
    try
        % Error checking
        data = evalin('base', str);
        if ~isnumeric(data),
            senderror(hSpecs, 'Numeric array expected.');
            return
        else,
            [M,N] = size(data);
            if M==1,
                data = data(:);
            end
            if size(data,2)~=1,
                senderror(hSpecs, 'Vector expected.');
                return
            end
        end
    catch ME
        senderror(hSpecs, ME.identifier, ME.message);
        return
    end
    
    % Instantiate a new window object
    newwin = sigwin.userdefined;
    newwin.MATLAB_expression = str;
    data = generate(newwin);
    
    % Set the 'Window' property
    set(hSpecs, 'Window', newwin);
    
    % Set the Length property
    set(hSpecs, 'Length', length(data));
    
    % Set the 'Data' property
    set(hSpecs, 'Data', data(:));

end

% Update the User-Defined uicontrol
hndls = get(hSpecs,'Handles');
if isfield(hndls, 'controls'),
    huserdef = findobj(hndls.controls, 'Tag', 'userdef');
    set(huserdef, 'String', str);
end


% [EOF]
