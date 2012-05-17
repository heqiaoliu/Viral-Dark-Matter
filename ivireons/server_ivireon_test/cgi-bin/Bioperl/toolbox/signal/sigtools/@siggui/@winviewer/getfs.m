function [fs, xunits, multiplier] = getfs(hView, varargin)
%GETFS Returns the sampling frequency specified in winviewer
%   [FS, XUNITS, M] = GETFS(hView, FREQTIME) Returns the sampling frequency FS specified
%   in the winviewer associated with hView.  XUNITS is a string which contains the
%   units of the sampling frequency, i.e. 'Hz', 'kHz', 'MHz'.  If winviewer
%   is in 'Normalized' display mode, 'rad/sample' will be returned in XUNITS
%   and FS will be empty.  M is the multiplier used to convert the Fs from the
%   units in XUNITS to Hz.  FREQTIME is either 'freq' or 'time', depending on which
%   you want the function to return.  If 'time' is specified, the sampling time will
%   be returned.  'freq' is the default FREQTIME.
%
%   GETFS(hView, LINEARFLAG) Returns the sampling frequency specified in winviewer
%   ignoring the 'FreqDisplayMode' property if LINEARFLAG is 1.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:20:20 $

error(nargchk(1,3,nargin,'struct'));

[freqtime, linearflag] = parse_inputs(varargin{:});

fs = get(getparameter(hView, 'sampfreq'), 'Value');

if strcmpi(freqtime, 'freq'),
    if ~linearflag, linearflag = ~strcmpi(hView.FreqDisplayMode, 'Normalized'); end
    [fs, xunits, multiplier] = lclgetfs(fs, linearflag);
else
    if ~linearflag, linearflag = ~strcmpi(hView.FreqDisplayMode, 'Normalized'); end
    [fs, xunits, multiplier] = lclgetts(fs, linearflag);
end

% -------------------------------------------------------------------
function [fs, xunits, multiplier] = lclgetfs(fs, linearflag)

if linearflag,
    [fs, multiplier, u] = engunits(fs);
    xunits = [u 'Hz'];
else
    fs = [];
    xunits = 'rad/sample';
    multiplier = 1;
end


% -------------------------------------------------------------------
function [ts, xunits, multiplier] = lclgetts(fs, linearflag)

if linearflag,
    [ts, multiplier, xunits] = engunits(1/fs, 'time');
else
    ts = [];
    xunits = 'samples';
    multiplier = 1;
end


% -------------------------------------------------------------------
function [freqtime, linearflag] = parse_inputs(varargin)

freqtime   = 'freq';
linearflag = 0;

for indx = 1:length(varargin)
    if ischar(varargin{indx}),
        freqtime = varargin{indx};
    elseif isnumeric(varargin{indx}),
        linearflag = varargin{indx};
    end
end

% [EOF]
