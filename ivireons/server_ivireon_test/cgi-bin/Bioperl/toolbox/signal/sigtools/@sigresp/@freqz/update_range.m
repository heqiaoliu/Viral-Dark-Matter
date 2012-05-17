function update_range(this,W)
%UPDATE_RANGE   Update the values of the Frequency Range Values.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:44 $

hPrm = getparameter(this,getfreqrangevaluestag(this));
if isempty(this.Spectrum) | isempty(hPrm),
    % Return if still initializing.
    return;
end

if nargin < 2,
    inputs = getdatainputs(this);
    [H, W] = getdata(this.Spectrum, inputs{:});
end

range = [min(W) max(W)];
if strcmpi(get(getparameter(this, 'freqmode'),'value'),'on'),
    str = sprintf('[%1.2g  %1.2g] x pi', range);
else
    str = sprintf('[%1.3g  %1.3g]',range);
end

if isrendered(this),
    set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'Off');
end
setvalue(hPrm,str);
if isrendered(this),
    set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'On');
end

% [EOF]
