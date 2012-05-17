function hfdesign = createMultiRateVersion(~, hfdesign, ftype, ...
    factor, secondfactor)
%createMultiRateVersion Create multi rate version of the design

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/16 06:38:08 $

if ~isfdtbxinstalled, return, end

switch lower(ftype)
    case 'decimator'
        hfdesign = fdesign.decimator(factor, hfdesign);
    case 'interpolator'
        hfdesign = fdesign.interpolator(factor, hfdesign);
    case 'sample-rate converter'
        hfdesign = fdesign.rsrc(factor, secondfactor, hfdesign);
end

