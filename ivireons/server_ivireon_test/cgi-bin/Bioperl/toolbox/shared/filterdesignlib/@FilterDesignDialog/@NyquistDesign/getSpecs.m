function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/23 19:02:04 $

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
specs.Scale      = strcmpi(this.Scale, 'on');
specs.ForceLeadingNumerator = strcmpi(this.ForceLeadingNumerator, 'on');

specs.Band           = {evaluatevars(source.Band)};
specs.MagnitudeUnits = this.MagnitudeUnits;

specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');

spec = lower(getSpecification(this, source));

switch spec
    case 'tw,ast'
        specs.TransitionWidth = getnum(source, 'TransitionWidth');
        specs.Astop           = evaluatevars(source.Astop);
    case 'n,tw'
        specs.Order           = evaluatevars(source.Order);
        specs.TransitionWidth = getnum(source, 'TransitionWidth');
    case 'n'
        specs.Order = evaluatevars(source.Order);
    case 'n,ast'
        specs.Order = evaluatevars(source.Order);
        specs.Astop = evaluatevars(source.Astop);
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
