function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:57 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');
specs.FracDelay       = evaluatevars(source.FracDelay);
specs.Order           = evaluatevars(source.Order);

% -------------------------------------------------------------------------
function value = getnum(source, prop)

value = source.(prop);
value = evaluatevars(value);

funits = source.FrequencyUnits;
if ~strncmpi(funits, 'normalized', 10)
    value = convertfrequnits(value, funits, 'Hz');
end

% [EOF]
