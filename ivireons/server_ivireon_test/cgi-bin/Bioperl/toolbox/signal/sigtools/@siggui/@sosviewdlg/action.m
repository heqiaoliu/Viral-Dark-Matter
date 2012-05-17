function success = action(this)
%ACTION   Test the settings.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:20:01 $

success = true;

% Test that the 'Custom' entry is valid.
if strcmpi(get(this, 'ViewType'), 'userdefined')
    try
        % Ask for an output from evalin so that we do not get the values
        % echoed to the command line. g381461
        suppress = evalin('base', this.Custom); %#ok
    catch ME
        throwAsCaller(ME)
    end
end

% [EOF]
