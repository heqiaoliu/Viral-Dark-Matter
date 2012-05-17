function out = openmdla(filename)
%OPENMDLA   Open *.MDLA Simulink Software Component in SCP.  Helper function for OPEN.
%
%   See OPEN.

%   Salman Qadri 7-17-09
%   Copyright 1984-2009 The MathWorks, Inc.

if nargout, out = []; end

% disabling scpStudio unless the feature is turned on.
if(~exist('scpFeature','file') || scpFeature('scp') ~= 1)

    % this error message is for internal consumption. It should be disabled
    % before release.
    %error('sam:scpStudio:featureNotOn','scpFeature is not on. please type: scpFeature(''scp'', 1); to enable scp');

    % Turn the following line on before release
    error('sam:scpStudio:featureNotOn','??? Undefined function or variable ''scpStudio''.');
else
    evalin('base', ['scpStudio(''' filename ''');'] );
end
