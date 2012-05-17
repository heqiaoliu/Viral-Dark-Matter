function zoom(this, optsflag, varargin)
%ZOOM   Zoom into the axis.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/12/05 02:24:27 $

if ischar(optsflag)
    switch lower(optsflag)
        case {'passband', 'stopband'}
            bandzoom(this, optsflag);
        case 'x'
            error(nargchk(3,3,nargin,'struct'));
            x = varargin{1};
            y = get(getbottomaxes(this.CurrentAnalysis), 'YLim');
            lclzoom(this, x, y);
        case 'y'
            error(nargchk(3,3,nargin,'struct'));
            x = get(getbottomaxes(this.CurrentAnalysis), 'XLim');
            y = varargin{1};
            lclzoom(this, x, y);
        case 'default'
            formataxislimits(this.CurrentAnalysis);
        otherwise
            error(generatemsgid('invalidFlag'), ...
                'Invalid flag passed to ZOOM.  See help fvtool for valid flags.');
    end
elseif isnumeric(optsflag)

    if length(optsflag) ~= 4
        error(generatemsgid('invalidLimits'), ...
            'Limits vector must have 4 elements.');
    end
    
    
    x = optsflag(1:2);
    y = optsflag(3:4);
    
    lclzoom(this, x, y);
else
    error(generatemsgid('invalidFlag'), ...
        'Invalid flag passed to ZOOM.  See help fvtool for valid flags.');
end

% -------------------------------------------------------------------------
function lclzoom(this, x, y)

hBottomAxes = getbottomaxes(this.CurrentAnalysis);
if any(isnan(y)) || diff(y) == 0
  set(hBottomAxes, 'XLim', x);
else
  set(hBottomAxes, 'XLim', x, 'YLim', y);
end

% -------------------------------------------------------------------------
function bandzoom(this, band)

Hd = get(this, 'Filters');

if strcmpi(get(getparameter(this, 'freqmode'), 'value'), 'off'),
    fs = get(Hd, 'Fs');
    if iscell(fs)
        fs = fs{1};
    end
    fs = engunits(fs/2)*2;
else
    fs = 2;
end

% Get the filter (DFILT) out of the dfiltwfs.
Hd = get(Hd, 'Filter');

if iscell(Hd)
    Hd = [Hd{:}];
end

ca = get(this, 'CurrentAnalysis');

if ~isa(ca, 'filtresp.magnitude')
    error(generatemsgid('invalidResponse'), ...
        'Can only zoom into the %s for the magnitude response.', band);
end

magunits = get(ca, 'MagnitudeDisplay');
switch lower(magunits)
    case 'magnitude (db)'
        magunits = 'db';
    case {'magnitude', 'zero-phase'}
        magunits = 'linear';
    case 'magnitude squared'
        magunits = 'squared';
end

if strcmpi(band, 'passband')
    [x, y] = passbandzoom(Hd, magunits, fs);
else
    x = nan;
    y = nan;
end
if any([isnan(x) isnan(y)])
    
    if ~isprop(Hd, 'MaskInfo')
        error(generatemsgid('noFDESIGN'), ...
            'Cannot find %s if the filter was not designed with FDESIGN.', band);
    end
    
    mi = get(Hd, 'MaskInfo');
    b  = mi.bands;

    % Find the index of all bands that apply
    indx = [];
    for i = 1:length(b)
        if isfield(b{i}, 'magfcn'),
            if ~isempty(findstr(b{i}.magfcn, band(1:4))),
                if any(strcmpi(b{i}.magfcn, {'cpass', 'wpass', 'wstop'})),
                    band = b{i}.magfcn;
                end
                indx = [indx i]; %#ok
            end
        end
    end

    % Get the frequency and amplitude information from the bands
    if length(indx) == 1,

        f = b{indx}.frequency;
        if ~any(strcmpi(b{indx}.magfcn, {'wstop', 'wpass'})),
            a = b{indx}.amplitude;
        end
    else

        b = [b{indx}];
        f = [b.frequency];
        f = [min(f(:)) max(f(:))];
        a = [b.amplitude];
        a = a(:);
    end

    % Tweak the amplitude information depending on the type of band that we are
    % dealing with.  This will move the zoom out a little for a better view.
    switch band
        case {'pass' 'passband'}

            a = max(a)*1.20;

            switch lower(mi.magunits)
                case 'db'
                    a = [-a a]/2;

                case {'linear', 'squared'}
                    a = [1-a 1+a];
            end
        case 'cpass',
            a = max(a)*1.20;

            switch lower(mi.magunits)
                case 'db'
                    a = [-a a/10];

                case {'linear', 'squared'}
                    a = [1-a 1+a];
            end

            % For the weights we need to get the data itself to get the amplitude.
        case {'pass','passband','cpass', 'wpass'}
            [x,y] = getanalysisdata(this);
            indx = find(x{1} > f(1) & x{1} < f(2));
            a = [min(y{1}(indx))*.9 max(y{1}(indx))*1.1];
        case 'wstop',
            [x,y] = getanalysisdata(this);
            indx = find(x{1} > f(1) & x{1} < f(2));
            a = [0 max(y{1}(indx))]*1.2; %#ok
        case {'stop' 'stopband'}

            [~,y] = getanalysisdata(this);

            switch lower(mi.magunits)
                case 'db'
                    a = [min(y{1}) -min(a)*.8];
                case {'linear', 'squared'}
                    a = [0 min(a)+.1];
            end
    end

    % Zoom the frequency out 5%
    f(1) = f(1)-(f(2)-f(1))*.05;
    f(2) = f(2)+(f(2)-f(1))*.05;

    % Make sure that the frequencies stay within the [0, pi) range.
    if f(1) < 0, f(1) = 0; end
    if f(2) > mi.fs/2, f(2) = mi.fs/2; end

    x = f*fs/mi.fs;
    y = a;
    
end

lclzoom(this, x, y);

% [EOF]
