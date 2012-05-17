function s = super_blockparams(Hd)
%SUPER_BLOCKPARAMS   

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/06/13 15:29:08 $

s = blockparams(Hd.filterquantizer);

refHd = reffilter(Hd);

sv = get(refHd, 'ScaleValues');
nsecs = Hd.nsections;
if length(sv) > nsecs+1
    warning('dfilt:basefilter:block:ExtraScaleValues', ...
        'Cannot use more Scale Values than the number of sections plus one.');
    sv = sv(1:nsecs+1);
end

s.BiQuadCoeffs = mat2str(refHd.sosMatrix);
s.ScaleValues  = mat2str(sv);
if Hd.OptimizeScaleValues
    s.OptimizeScaleValues = 'on';
else
    s.OptimizeScaleValues = 'off';
end

% [EOF]
