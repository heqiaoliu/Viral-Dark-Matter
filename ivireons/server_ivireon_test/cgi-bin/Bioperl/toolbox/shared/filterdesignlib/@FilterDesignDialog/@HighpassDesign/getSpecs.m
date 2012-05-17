function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/23 19:01:57 $

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

spec = getSpecification(this, source);

switch lower(spec)
    case 'fst,fp,ast,ap'
        specs.Fstop = getnum(source, 'Fstop');
        specs.Fpass = getnum(source, 'Fpass');
        specs.Astop = evaluatevars(source.Astop);
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
    case 'n,f3db,ap'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db,ast'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db,ast,ap'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
        specs.Astop = evaluatevars(source.Astop);
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db,fp'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
        specs.Fpass = getnum(source, 'Fpass');
    case 'n,fc'
        specs.Order = evaluatevars(source.Order);
        specs.F6dB  = getnum(source, 'F6dB');
    case 'n,fc,ast,ap'
        specs.Order = evaluatevars(source.Order);
        specs.F6dB  = getnum(source, 'F6dB');
        specs.Astop = evaluatevars(source.Astop);
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fp,ap'
        specs.Order = evaluatevars(source.Order);
        specs.Fpass = getnum(source, 'Fpass');
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fp,ast,ap'
        specs.Order = evaluatevars(source.Order);
        specs.Fpass = getnum(source, 'Fpass');
        specs.Astop = evaluatevars(source.Astop);
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fst,ast'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fst,ast,ap'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Astop = evaluatevars(source.Astop);
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fst,f3db'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.F3dB  = getnum(source, 'F3dB');
    case 'n,fst,fp'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Fpass = getnum(source, 'Fpass');
    case 'n,fst,fp,ap'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Fpass = getnum(source, 'Fpass');
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fst,fp,ast'
        specs.Order = evaluatevars(source.Order);
        specs.Fstop = getnum(source, 'Fstop');
        specs.Fpass = getnum(source, 'Fpass');
        specs.Astop = evaluatevars(source.Astop);
        specs.Apass = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
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
