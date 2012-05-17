function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/23 19:01:29 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.FilterType = source.FilterType;
specs.Factor     = evaluatevars(source.Factor);

if strcmpi(this.FilterType, 'sample-rate converter')
    specs.SecondFactor = evaluatevars(source.SecondFactor);
end

specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');

specs.NumberOfSections  = evaluatevars(get(this, 'NumberOfSections'));
specs.DifferentialDelay = evaluatevars(get(this, 'DifferentialDelay'));

spec = lower(getSpecification(this, source));

switch spec
    case 'fp,fst,ap,ast'
        specs.Fpass = getnum(source, 'Fpass');
        specs.Fstop = getnum(source, 'Fstop');
        specs.Apass = evaluatevars(source.Apass);
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = this.MagnitudeUnits;
    case 'n,fc,ap,ast'
        specs.Order = evaluatevars(source.Order);
        specs.F6dB  = getnum(source, 'F6dB');
        specs.Apass = evaluatevars(source.Apass);
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = this.MagnitudeUnits;
    case 'n,fp,ap,ast'
        specs.Order = evaluatevars(source.Order);
        specs.Fpass = getnum(source, 'Fpass');
        specs.Apass = evaluatevars(source.Apass);
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = this.MagnitudeUnits;
    case 'n,fp,fst'
        specs.Order = evaluatevars(source.Order);
        specs.Fpass = getnum(source, 'Fpass');
        specs.Fstop = getnum(source, 'Fstop');
    case 'n,fst,ap,ast'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Apass = evaluatevars(source.Apass);
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = this.MagnitudeUnits;
    case 'n,fst,ast'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = this.MagnitudeUnits;
    otherwise
        disp(sprintf('Finish %s', spec));
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
