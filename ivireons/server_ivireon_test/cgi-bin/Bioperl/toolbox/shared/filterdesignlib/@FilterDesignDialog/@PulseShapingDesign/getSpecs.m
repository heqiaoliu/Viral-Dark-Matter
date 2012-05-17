function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:13:35 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.FilterType = source.FilterType;
specs.Factor     = evaluatevars(source.Factor);
if strcmpi(specs.FilterType, 'sample-rate converter')
    specs.SecondFactor = evaluatevars(source.SecondFactor);
end

specs.FrequencyUnits   = source.FrequencyUnits;
specs.InputSampleRate  = getnum(source, 'InputSampleRate');
specs.SamplesPerSymbol = evaluatevars(source.SamplesPerSymbol);

switch lower(getSpecification(this, source))
    case 'ast,beta'
        specs.Beta  = evaluatevars(source.Beta);
        if strcmpi(this.PulseShape, 'square root raised cosine')
            specs.Astop = evaluatevars(source.AstopSQRT);
        else
            specs.Astop = evaluatevars(source.Astop);
        end
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,beta'
        specs.Order = evaluatevars(source.Order);
        specs.Beta  = evaluatevars(source.Beta);
    case 'nsym,beta'
        specs.NumberOfSymbols = evaluatevars(source.NumberOfSymbols);
        specs.Beta            = evaluatevars(source.Beta);
    case 'nsym,bt'
        specs.NumberOfSymbols = evaluatevars(source.NumberOfSymbols);
        specs.BT              = evaluatevars(source.BT);
    otherwise
        fprintf('Finish %s\n', spec);
end

% -------------------------------------------------------------------------
function value = getnum(source, prop)

value = source.(prop);
value = evaluatevars(value);

funits = source.FrequencyUnits;
if ~strncmpi(funits, 'normalized', 10)
    value = convertfrequnits(value, funits, 'Hz');
end

% [EOF]
