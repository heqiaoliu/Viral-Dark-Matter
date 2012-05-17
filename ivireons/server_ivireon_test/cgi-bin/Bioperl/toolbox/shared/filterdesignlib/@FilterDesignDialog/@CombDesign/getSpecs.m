function specs = getSpecs(this, varargin)
%GETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:41 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.CombType        = source.CombType;
specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');

switch lower(getSpecification(this, source))
    case 'l,bw,gbw,nsh'
        specs.NumPeaksOrNotches = evaluatevars(source.NumPeaksOrNotches);
        specs.BW                = getnum(source, 'BW');
        specs.GBW               = evaluatevars(source.GBW);
        specs.ShelvingFilterOrder = evaluatevars(source.ShelvingFilterOrder);
    case 'n,q'
        specs.Order = evaluatevars(source.Order);
        specs.Q     = evaluatevars(source.Q);
    case 'n,bw'
        specs.Order = evaluatevars(source.Order);
        specs.BW    = getnum(source, 'BW');
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
