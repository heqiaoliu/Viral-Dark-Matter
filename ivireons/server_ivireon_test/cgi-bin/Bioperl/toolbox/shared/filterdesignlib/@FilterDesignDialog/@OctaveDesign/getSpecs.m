function specs = getSpecs(this, source)
%GETSPECS Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:29:24 $

if nargin < 2
    source = this;
end

specs.FilterType            = source.FilterType;
specs.Factor                = evaluatevars(source.Factor);
specs.Order                 = evaluatevars(source.Order);
specs.Scale                 = strcmpi(source.Scale, 'on');
specs.F0                    = getnum(source, 'F0');
specs.ForceLeadingNumerator = strcmpi(source.ForceLeadingNumerator, 'on');
specs.BandsPerOctave        = evaluatevars(source.BandsPerOctave);
specs.FrequencyUnits        = source.FrequencyUnits;
specs.InputSampleRate       = getnum(source, 'InputSampleRate');


% -------------------------------------------------------------------------
function value = getnum(source, prop)

value = source.(prop);
value = evaluatevars(value);

funits = source.FrequencyUnits;
if ~strncmpi(funits, 'normalized', 10)
    value = convertfrequnits(value, funits, 'Hz');
end

% [EOF]
