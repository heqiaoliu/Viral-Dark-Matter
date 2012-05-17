function setspecs(this, sps, varargin)
%SETSPECS Set the specs
%   OUT = SETSPECS(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:00:23 $

if nargin < 2
    return;
end

if ischar(sps)
    error(generatemsgid('invalidInput'), ...
        'The first input must be a scalar number (SamplesPerSymbol).');
end

set(this, 'SamplesPerSymbol', sps);

abstract_setspecs(this, varargin{:});

% [EOF]
