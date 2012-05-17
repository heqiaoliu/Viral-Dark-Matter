function varargout = step(this, varargin)
%STEP   Step response.
%   H = STEP(Hb) computes the step response object H.
%
%   For additional parameters see DFILT.BASEFILTER/IMPULSE.
%
%   See also DFILT, SIGNAL/STEPZ.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:17:55 $

feature('TimeSeriesTools',1);

hopts = uddpvparse('dspopts.timeresp', varargin{:});

inputs = oldinputs(hopts);

[y, t] = base_resp(this, 'computestepz', inputs{:});

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
    title(hax, 'Step Response');

%     hs = stem(h);
%     title(ancestor(hs, 'axes'), 'Step Response');
end

% [EOF]
