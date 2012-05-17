function varargout = validate(this, d)
%VALIDATE Returns true if this object is valid

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:10:16 $

% Get all the specs.
allSpecs = whichspecs(this);

% Some specs do not add any specs, return early and don't check anything.
if isempty(allSpecs)
    if nargout
        varargout = {true, MException.empty};
    end
    return;
end

% Find all the frequency specs.
freqSpecs = allSpecs(strcmp({allSpecs.descript}, 'freqspec'));

% Validate that the frequencies are below nyquist.
[success, exception] = validateFreqSpec(this, d, freqSpecs.name);

if nargout
    varargout = {success, exception};
elseif ~success
    throw(exception)
end

% [EOF]
