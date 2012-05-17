function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/10/23 18:42:27 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.FilterType = source.FilterType;
specs.Factor     = evaluatevars(source.Factor);
specs.Scale      = strcmpi(this.Scale, 'on');
specs.ForceLeadingNumerator = strcmpi(this.ForceLeadingNumerator, 'on');

if strcmpi(this.FilterType, 'sample-rate converter')
    specs.SecondFactor = evaluatevars(source.SecondFactor);
end

specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');
specs.Order           = evaluatevars(source.Order);

spec = lower(getSpecification(this, source));

switch spec
    case 'n,f,a'
        specs.Band1.Frequencies = getnum(source, 'Band1', 'Frequencies');
        specs.Band1.Amplitudes  = evaluatevars(source.Band1.Amplitudes);
    case 'n,b,f,a'
        specs.NumberOfBands = this.NumberOfBands+1;
        for indx = 1:specs.NumberOfBands
            band_str = sprintf('Band%d', indx);
            specs.(band_str).Frequencies = getnum(source, band_str, 'Frequencies');
            specs.(band_str).Amplitudes  = evaluatevars(source.(band_str).Amplitudes);
        end
    case 'nb,na,f,a'
        specs.DenominatorOrder  = evaluatevars(this.DenominatorOrder);
        specs.Band1.Frequencies = getnum(source, 'Band1', 'Frequencies');
        specs.Band1.Amplitudes  = evaluatevars(source.Band1.Amplitudes);
    case 'nb,na,b,f,a'
        specs.DenominatorOrder = evaluatevars(this.DenominatorOrder);
        specs.NumberOfBands    = this.NumberOfBands+1;
        for indx = 1:specs.NumberOfBands
            band_str = sprintf('Band%d', indx);
            specs.(band_str).Frequencies = getnum(source, band_str, 'Frequencies');
            specs.(band_str).Amplitudes  = evaluatevars(source.(band_str).Amplitudes);
        end
    case 'n,f,h'
        specs.Band1.Frequencies = getnum(source, 'Band1', 'Frequencies');
        specs.Band1.FreqResp    = getFreqResp(source, 1);
    case 'n,b,f,h'
        specs.NumberOfBands = this.NumberOfBands+1;
        for indx = 1:specs.NumberOfBands
            band_str = sprintf('Band%d', indx);
            specs.(band_str).Frequencies = getnum(source, band_str, 'Frequencies');
            specs.(band_str).FreqResp    = getFreqResp(source, indx);
        end
    case 'nb,na,f,h'
        specs.DenominatorOrder  = evaluatevars(this.DenominatorOrder);
        specs.NumberOfBands     = this.NumberOfBands+1;
        specs.Band1.Frequencies = getnum(source, 'Band1', 'Frequencies');
        specs.Band1.FreqResp    = getFreqResp(source, 1);
    case 'nb,na,b,f,h'
        specs.DenominatorOrder = evaluatevars(this.DenominatorOrder);
        specs.NumberOfBands    = this.NumberOfBands+1;
        for indx = 1:specs.NumberOfBands
            band_str = sprintf('Band%d', indx);
            specs.(band_str).Frequencies = getnum(source, band_str, 'Frequencies');
            specs.(band_str).FreqResp    = getFreqResp(source, indx);
        end
    otherwise
        disp(sprintf('Finish %s', spec));
end

% -------------------------------------------------------------------------
function fresp = getFreqResp(source, indx)

% Return a frequency response, either from the single vector or created
% from the magnitude and phase.
band_str = sprintf('Band%d', indx);
if strcmpi(source.ResponseType, 'Frequency response')
    fresp = evaluatevars(source.(band_str).FreqResp);
else
    mag   = evaluatevars(source.(band_str).Magnitudes);
    phase = evaluatevars(source.(band_str).Phases);
    if length(mag) ~= length(phase)
        error(generatemsgid('vectorMismatch'), ...
            'The vectors ''Magnitudes'' and ''Phases'' must have the same length.');
    end
    fresp = mag.*cos(phase)+mag.*sin(phase)*i;
end

% -------------------------------------------------------------------------
function value = getnum(source, varargin)

value = source;
for indx = 1:length(varargin)
    value = value.(varargin{indx});
end
value = evaluatevars(value);

funits = source.FrequencyUnits;
if ~strncmpi(funits, 'normalized', 10)
    value = convertfrequnits(value, funits, 'Hz');
end

% [EOF]
