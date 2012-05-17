function init(this, hApplication, hRegister, hConfig)
%INIT     Initialize the class.
%   INIT(H, HAPP, HREG, HCON) initializes the object with the inputs passed
%   to the constructor by the extension manager.  HAPP, the handle to the
%   application, HREG, the handle to the Register, HCON, the handle to the
%   Config.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:37:14 $

isMatching = strcmpi(hConfig.Type, hRegister.Type) ...
          && strcmpi(hConfig.Name, hRegister.Name);
if ~isMatching
    
    % This is an internal error of the extension manager, and is therefore
    % tagged as an assertion.
    error(generatemsgid('NonMatchingConfig'), ...
        'ASSERT:Config does not match type/name of extension register.');
end

set(this, ...
    'Application', hApplication, ...
    'Register',    hRegister, ...
    'Config',      hConfig);

this.PropertyListener = handle.listener(hConfig, 'PropertyChanged', ...
    @(hSrc, ed) propertyChanged(this, ed));

% [EOF]
