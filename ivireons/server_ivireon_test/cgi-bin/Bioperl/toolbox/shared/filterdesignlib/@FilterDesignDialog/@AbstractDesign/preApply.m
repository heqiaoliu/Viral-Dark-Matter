function [b, str] = preApply(this)
%PREAPPLY

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/05 02:22:19 $

b   = true;
str = '';

variableName = get(this, 'VariableName');

% If the specified variable name is not valid, error out without
% continuing.
if ~isvarname(variableName)
    b = false;
    str = '''Variable name'' must be a valid variable name.';
    return;
end

% Capture the state so we can design the filter based on the last applied
% settings as opposed to the current settings which may not be applied.
captureState(this);

% Clear out the last applied filter.  We will need to redesign, but only
% when necessary.
set(this, 'LastAppliedFilter', []);

% If the design errors out, clean up the message and return early.
try
    [Hd same] = design(this);
catch e
    b = false;
    str = cleanerrormsg(e.message);
    return;
end

if strcmpi(this.OperatingMode, 'matlab')
    assignin('base', variableName, Hd);
    disp(sprintf('The variable ''%s'' has been exported to the command window.', variableName));
elseif ~same
    % The filter needs to be redesigned in the fdesignblkfcn
    set(this, 'LastAppliedSpecs', [], ...
    'LastAppliedDesignOpts',  []);
end

% [EOF]
