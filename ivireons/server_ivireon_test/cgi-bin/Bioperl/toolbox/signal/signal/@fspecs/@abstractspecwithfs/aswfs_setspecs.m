function aswfs_setspecs(this,varargin)
%ASWFS_SETSPECS   

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/12/22 19:02:30 $

if nargin == 1, return; end

p = thisprops2add(this,varargin{:});

if ischar(varargin{end})
    magtype = varargin{end};
    varargin(end) = [];
else
    magtype = 'db';
end

magtypes = {'db', 'linear', 'squared'};
indx     = find(strncmpi(magtype, magtypes, length(magtype)));
if isempty(indx)
    error(generatemsgid('invalidMagUnits'), ...
        '''%s'' is not a valid magnitude unit.', magtype);
end
magtype  = magtypes{indx};

% If there is an extra input, it must be the Fs.
if length(varargin) > length(p),
    if length(varargin) == length(p)+1 && isnumeric(varargin{end})
        this.privNormalizedFreq = false;
        set(this, 'Fs', varargin{end});
        varargin(end) = [];
    else
        error(generatemsgid('tooManyInputs'), 'Too many input arguments.');
    end
end

[pass, stop] = magprops(this);

% Loop over all the properties and set them.
for indx = 1:min(length(p), length(varargin))
    val = varargin{indx};
    if any(strcmpi(p{indx}, pass))
        band = 'pass';
    elseif any(strcmpi(p{indx}, stop))
        band = 'stop';
    else
        band = '';
    end
    if isempty(band)
        set(this, p{indx}, varargin{indx});
    else
        set(this, p{indx}, convertmagunits(val, magtype, 'db', band));
    end
end

% [EOF]
