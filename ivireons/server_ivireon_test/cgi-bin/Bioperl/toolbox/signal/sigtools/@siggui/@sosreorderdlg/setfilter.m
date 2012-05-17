function Hd = setfilter(this, Hd)
%SETFILTER   PreSet function for the filter property

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/07/14 06:47:18 $

if isempty(this.Filter),
    this.refFilter = Hd;
    this.isApplied = false;
    updatecustom(this);
else
    
    % If the sosMatrix and ScaleValues match don't change the refFilter
    if ~this.isScaling
        this.refFilter = Hd;
        this.isApplied = false;
        
        updatecustom(this);
    end
end

% -------------------------------------------------------------------------
function updatecustom(this)

hc = getcomponent(this, 'custom');

% Do this last so GETREORDERINPUTS returns the last entered values.
hc.NumeratorOrder = sprintf('[1:%d]', nsections(this.refFilter));
hc.DenominatorOrder = sprintf('[1:%d]', nsections(this.refFilter));
hc.ScaleValuesOrder = sprintf('[1:%d]', nsections(this.refFilter)+1);

opts = scaleopts(this.refFilter);

set(this, ...
    'MaxNumerator', num2str(opts.MaxNumerator), ...
    'NumeratorConstraint', map(opts.NumeratorConstraint), ...
    'OverflowMode', opts.OverflowMode, ...
    'ScaleValueConstraint', map(opts.ScaleValueConstraint));

if ~strcmpi(opts.MaxScaleValue, 'Not used'),
    set(this, 'MaxScaleValue', num2str(opts.MaxScaleValue));
end

set(this, ...
    'Scale',       'off', ...
    'ReorderType', 'None', ...
    'isApplied',   true);

% -------------------------------------------------------------------------
function m = map(m)

if strcmpi(m, 'po2')
    m = 'Power of 2';
end

% [EOF]
