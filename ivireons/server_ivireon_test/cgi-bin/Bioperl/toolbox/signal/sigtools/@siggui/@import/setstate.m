function setstate(hIT, state)
%SETSTATE Sets the state of the Import Tool.
%   SETSTATE(hIT, STATE) Sets the state of the Import Tool with the data
%   structure STATE.
%
%   See also GETSTATE.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.4 $  $Date: 2007/12/14 15:18:57 $

error(nargchk(2,2,nargin,'struct'));

% Check for R12 & R12.1 versions
if isfield(state,'impfiltstruct')
    
    % Convert if necessary
    state = convert(state);
end

sigcontainer_setstate(hIT, state);

% ---------------------------------------------------------
function sout = convert(sin)

sout.coeffspecifier.Coefficients = convertcoeffs(sin.impfiltstruct);
sout.coeffspecifier.SelectedStructure = sin.impfiltstruct.struct;

oldFs = sin.fs;
sout.fsspecifier.Value = oldFs.Fs;
sout.fsspecifier.Units = oldFs.freqUnits;

% ---------------------------------------------------------
function coeffs = convertcoeffs(coeffs)

% The old method (FDATool) stored the "short" strings which did not match the
% constructors.  Convert to the constructors as fields
oldtags = fieldnames(rmfield(coeffs,{'struct','qfiltVarStrs'}));
newtags = {'tf','sos','statespace','latticearma', ...
        'latticeallpass','latticemamin','latticemamax'};

for i = 1:length(oldtags)
    value  = coeffs.(oldtags{i});
    coeffs.(newtags{i}) = value;
    coeffs = rmfield(coeffs,oldtags{i});
end

% [EOF]
