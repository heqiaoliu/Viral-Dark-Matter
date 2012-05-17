function [m, xunits] = objspecificdraw(this)
%OBJSPECIFICDRAW Draw the NOISEPOWERSPECTRUM

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2004/10/18 21:10:00 $

h    = get(this, 'Handles');
opts = getoptions(this);

h.axes = h.axes(end);

Hd = get(this, 'Filters');

endx = [];
for indx = 1:length(Hd),
    if ~isa(Hd(indx).Filter, 'qfilt'),
        endx = [endx indx];
    end
end
Hd(endx) = [];

if isempty(Hd),
    warning(generatemsgid('onlyQfilt'), '%s can only operate on QFILT objects.', ...
        get(this, 'Name'));
    h.line = [];
    set(this, 'Handles', h);
    m = 1;
    xunits = '';
    return;
end

% Calculate the data
[H, W, P, Nf] = nlm(Hd, opts{1}, get(this, 'NumberofTrials'), opts{2});
[W, m, xunits] = normalize_w(this, W);

% Get the subclass to convert it for plotting
[W, Y] = getplotdata(this, H, W, P, Nf);

% Plot the data
h.line = freqplotter(h.axes, W, Y);

% Save the handles
set(this, 'Handles', h);

% Put up the ylabel from the subclass
ylabel(h.axes, getylabel(this));

% [EOF]
