function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/23 19:02:02 $

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

switch lower(getSpecification(this, source))
    case 'fp,fst,ap,ast'
        specs.Fpass          = getnum(source, 'Fpass');
        specs.Fstop          = getnum(source, 'Fstop');
        specs.Apass          = evaluatevars(source.Apass);
        specs.Astop          = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
    case 'n,f3db,ap'
        specs.Order          = evaluatevars(source.Order);
        specs.F3dB           = getnum(source, 'F3dB');
        specs.Apass          = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db,ap,ast'
        specs.Order          = evaluatevars(source.Order);
        specs.F3dB           = getnum(source, 'F3dB');
        specs.Apass          = evaluatevars(source.Apass);
        specs.Astop          = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db,ast'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
        specs.Astop = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,f3db,fst'
        specs.Order = evaluatevars(source.Order);
        specs.F3dB  = getnum(source, 'F3dB');
        specs.Fstop = getnum(source, 'Fstop');
    case 'n,fc'
        specs.Order = evaluatevars(source.Order);
        specs.F6dB  = getnum(source, 'F6dB');
    case 'n,fc,ap,ast'
        specs.Order          = evaluatevars(source.Order);
        specs.F6dB           = getnum(source, 'F6dB');
        specs.Apass          = evaluatevars(source.Apass);
        specs.Astop          = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fp,ap'
        specs.Order          = evaluatevars(source.Order);
        specs.Fpass          = getnum(source, 'Fpass');
        specs.Apass          = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fp,ap,ast'
        specs.Order          = evaluatevars(source.Order);
        specs.Fpass          = getnum(source, 'Fpass');
        specs.Apass          = evaluatevars(source.Apass);
        specs.Astop          = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fp,f3db'
        specs.Order = evaluatevars(source.Order);
        specs.Fpass = getnum(source, 'Fpass');
        specs.F3dB  = getnum(source, 'F3dB');
    case 'n,fp,fst'
        specs.Order = evaluatevars(source.Order);
        specs.Fpass = getnum(source, 'Fpass');
        specs.Fstop = getnum(source, 'Fstop');
    case 'n,fp,fst,ap'
        specs.Order          = evaluatevars(source.Order);
        specs.Fpass          = getnum(source, 'Fpass');
        specs.Fstop          = getnum(source, 'Fstop');
        specs.Apass          = evaluatevars(source.Apass);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fp,fst,ast'
        specs.Order          = evaluatevars(source.Order);
        specs.Fpass          = getnum(source, 'Fpass');
        specs.Fstop          = getnum(source, 'Fstop');
        specs.Astop          = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fst,ap,ast'
        specs.Order          = evaluatevars(source.Order);
        specs.Fstop          = getnum(source, 'Fstop');
        specs.Apass          = evaluatevars(source.Apass);
        specs.Astop          = evaluatevars(source.Astop);
        specs.MagnitudeUnits = source.MagnitudeUnits;
    case 'n,fst,ast'
        specs.Order          = evaluatevars(source.Order);
        specs.Fstop          = getnum(source, 'Fstop');
        specs.Astop          = evaluatevars(source.Astop);
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
