function varargout = impulse(this, varargin)
%IMPULSE Impulse response of digital filter
%   H = IMPULSE(Hb) returns the impulse response object H.
%
%   H = IMPULSE(Hb, PV Pairs) returns the response object H based on PV
%   Pairs.  Valid options are:
%   Parameter                Default     Description/Valid values
%   ---------                -------     ------------------------
%   'NormalizedFrequency'    true        
%   'Fs'                     1          Not used when NormalizedFrequency
%                                       is true.
%   'LengthOption'           'Default'  {'Default', 'Specified'}
%   'Length'                 20         Not used when LengthOption is set
%                                       to 'Default'.
%
%   These options are all contained in the DSPOPTS.TIMERESP object.
%
%   For additional parameters, see SIGNAL/IMPZ.
%
%   See also DFILT, SIGNAL/IMPZ.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:17:43 $

feature('TimeSeriesTools',1);

hopts = uddpvparse('dspopts.timeresp', varargin{:});

inputs = oldinputs(hopts);

[y, t] = base_resp(this, 'computeimpz', inputs{:});

h = tsdata.timeseries(y, t);

if nargout,
    varargout = {h};
else
    hax = newplot;
    
    t = get(h, 'Time');
    
    if hopts.NormalizedFrequency
        xunits = 'samples';
    else
        [t, m, xunits] = engunits(t, 'time', 'latex'); %#ok
        xunits = [xunits 's'];
    end
    stem(hax, t, h.Data);
    xlabel(hax, sprintf('Time (%s)', xunits));
    ylabel(hax, 'Amplitude');
    title(hax, 'Impulse Response');
%     hs = stem(h);
%     title(ancestor(hs, 'axes'), 'Impulse Response');
end

% [EOF]
