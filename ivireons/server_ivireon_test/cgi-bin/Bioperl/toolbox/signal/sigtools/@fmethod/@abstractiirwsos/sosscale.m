function sosscale(this, Hd)
%SOSSCALE   Scale the SOS Filter.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:47 $

% If the user has specified either the scaling norm or the scaling
% options, scale the filter if it is an SOS.
if ~isa(Hd, 'dfilt.abstractsos')
    return;
end
norm = get(this, 'SOSScaleNorm');
opts = get(this, 'SOSScaleOpts');
if ~isempty(norm) 
    if isempty(opts)
        opts = scaleopts(Hd);
        opts.NumeratorConstraint  = 'unit';
        opts.ScaleValueConstraint = 'none';
        this.SOSScaleOpts = opts;
    end

    % We cannot use 'auto' because it relies on the FDESIGN object
    % being attached to the DFILT.
    if strcmpi(opts.sosReorder, 'auto')
        opts.sosReorder = getsosreorder(this);
    end

    scale(Hd, norm, opts);
end

% [EOF]
