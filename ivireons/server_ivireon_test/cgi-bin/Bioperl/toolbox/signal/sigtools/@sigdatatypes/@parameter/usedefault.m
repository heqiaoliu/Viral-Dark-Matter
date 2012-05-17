function usedefault(hPrm, tool)
%USEDEFAULT Use the default parameter
%   USEDEFAULT(H, TOOL) Use the default parameters from TOOL's group.
%
%   See also MAKEDEFAULT.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:17:59 $

error(nargchk(2,2,nargin,'struct'));

prefs = [];
if ispref('SignalProcessingToolbox', 'DefaultParameters')
    prefs = getpref('SignalProcessingToolbox', 'DefaultParameters');
end

if isfield(prefs, tool),
    struct2param(hPrm, prefs.(tool));
end

% [EOF]
