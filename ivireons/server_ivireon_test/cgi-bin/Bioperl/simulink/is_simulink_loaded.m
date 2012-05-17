% IS_SIMULINK_LOADED
%   Determine whether Simulink has been loaded into memory without forcing it to load.
%   Calls to this function from outside of Simulink should be protected as shown below:
%
%         ans = exist('is_simulink_loaded') && is_simulink_loaded
%
%  See also IS_SIMULINK_HANDLE.

% Copyright 2007-2008 The MathWorks, Inc.

function loaded = is_simulink_loaded
    try
        % This feature is registered when the Simulink
        % DLL is loaded.  If the feature is not registered
        % an error will be thrown.
        feature SimulinkTargets;
        loaded = true;
    catch e
        if strcmp(e.identifier,'MATLAB:unknownFeature')
            % This is the expected "Simulink not loaded"
            % result.
            loaded = false;
        else
            % We didn't expect this
            rethrow(e);
        end
    end
end
