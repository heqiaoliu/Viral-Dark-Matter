function thisdraw(this)
%THISDRAW Draw the zplane object

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.8 $  $Date: 2005/06/16 08:41:57 $

Hd = get(this, 'Filters');

h = get(this, 'Handles');
h.axes = h.axes(end);

if isempty(Hd),
    z = {[]};
    p = {[]};
else
    opts.showref  = showref(this.FilterUtils);
    opts.showpoly = showpoly(this.FilterUtils);
    opts.sosview  = this.SOSViewOpts;
    
    [z, p] = zplane(Hd, opts);
end

% Set up the default handles.
hunit = [];
hline = [];

% Delete any old unitcircles
if ishandlefield(this, 'unitcircle'),
    delete(h.unitcircle);
end

delete(getline(this));
deletelineswithtag(this);

for indx = 1:length(z),

    % Delete the unitcircle each time so that we only have 1 at the end
    if ~isempty(hunit), delete(hunit); end

    % If there is more than 1 zero vector it must be quantized
    if size(z{indx},2) > 1 && ~(isempty(z{indx}) || isempty(p{indx}))
        marker = {'s', '+', 'o', 'x'};
        % If we have a single row, we need to pad with NaNs to get a matrix
        % for ZPLANEPLOT.  If ZPLANEPLOT sees a row vector it assumes they
        % are all zeros/poles of a double filter, instead of working column
        % wise.
        if size(z{indx}, 1) == 1
            z{indx} = [z{indx}; NaN NaN];
        end
        if size(p{indx}, 1) == 1
            p{indx} = [p{indx}; NaN NaN];
        end
    else
        marker = {'o', 'x'};
    end

    % Draw the zplaneplot
    [hz, hp, hunit] = zplaneplot(z{indx}, p{indx}, h.axes, marker);

    % Make sure that the color matches the order correctly.
    set([hz, hp], 'Color', getcolorfromindex(h.axes, indx));

    hline = [hline hz' hp'];
end

h.line       = hline;
h.unitcircle = hunit;
set(h.unitcircle, 'tag', 'zplane_unitcircle');

set(this, 'Handles', h);

send(this, 'NewPlot', handle.EventData(this, 'NewPlot'));

% [EOF]
