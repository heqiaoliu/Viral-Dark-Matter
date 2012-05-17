function hfdesign = createMultiRateVersion(this, hfdesign, ftype, ...
    factor, secondfactor)
%createMultiRateVersion Create multi rate version of the design

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/05 02:22:27 $

if strcmpi(ftype, 'single-rate') || ~isfdtbxinstalled
    return;
end

hfdesign = getPSObj(hfdesign);
    
switch lower(ftype)
    case 'decimator'
        hfdesign = fdesign.decimator(factor, hfdesign);
    case 'interpolator'
        hfdesign = fdesign.interpolator(factor, hfdesign);
    case 'sample-rate converter'
        hfdesign = fdesign.rsrc(factor, secondfactor, hfdesign);
end

