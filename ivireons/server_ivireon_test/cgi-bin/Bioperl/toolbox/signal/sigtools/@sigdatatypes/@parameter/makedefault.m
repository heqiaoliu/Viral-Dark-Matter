function makedefault(hPrm, tool, defaults)
%MAKEDEFAULT Make the current setting of the parameter the default
%   MAKEDEFAULT(H, TOOL) Make the current setting of the parameter
%   the default parameter in the TOOL group.
%
%   See also USEDEFAULT.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:17:53 $

error(nargchk(2,3,nargin,'struct'));

prefs = [];
if ispref('SignalProcessingToolbox', 'DefaultParameters')
    prefs = getpref('SignalProcessingToolbox', 'DefaultParameters');
end

pstruct = param2struct(hPrm);
if nargin > 2,
    
    if length(defaults) ~= length(hPrm),
        error(generatemsgid('InvalidDimensions'),'Defaults must be the same length as the parameters.');
    end
    
    fnames = fieldnames(pstruct);
    for i = 1:length(fnames)
        pstruct.(fnames{i}) = defaults{i};
    end
end

if isfield(prefs, tool),
    prefs.(tool) = setstructfields(prefs.(tool), pstruct);
else
    prefs.(tool) = pstruct;
end

setpref('SignalProcessingToolbox', 'DefaultParameters', prefs);

% [EOF]
