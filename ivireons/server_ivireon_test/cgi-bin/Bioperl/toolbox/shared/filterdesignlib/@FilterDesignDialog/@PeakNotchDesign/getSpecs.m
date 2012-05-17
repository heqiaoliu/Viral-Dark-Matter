function specs = getSpecs(this, varargin)
%GETSPECS Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/27 21:27:23 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.Response   = get(this, 'ResponseType');

specs.Scale      = strcmpi(this.Scale, 'on');
specs.ForceLeadingNumerator = strcmpi(this.ForceLeadingNumerator, 'on');

specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');

specs.Order = evaluatevars(source.Order);
specs.F0    = getnum(source, 'F0');

switch lower(getSpecification(this, source))
    case 'n,f0,q'
        specs.Q     = evaluatevars(source.Q);
    case 'n,f0,q,ap'
        specs.Q     = evaluatevars(source.Q);
        specs.Apass = evaluatevars(source.Apass);
    case 'n,f0,q,ast'
        specs.Q     = evaluatevars(source.Q);
        specs.Astop = evaluatevars(source.Astop);
    case 'n,f0,q,ap,ast'
        specs.Q     = evaluatevars(source.Q);
        specs.Apass = evaluatevars(source.Apass);
        specs.Astop = evaluatevars(source.Astop);
    case 'n,f0,bw'
        specs.BW    = getnum(source, 'BW');
    case 'n,f0,bw,ap'
        specs.BW    = getnum(source, 'BW');
        specs.Apass = evaluatevars(source.Apass);
    case 'n,f0,bw,ast'
        specs.BW    = getnum(source, 'BW');
        specs.Astop = evaluatevars(source.Astop);
    case 'n,f0,bw,ap,ast'
        specs.BW    = getnum(source, 'BW');
        specs.Apass = evaluatevars(source.Apass);
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
