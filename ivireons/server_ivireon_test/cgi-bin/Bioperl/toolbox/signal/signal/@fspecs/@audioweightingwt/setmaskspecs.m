function setmaskspecs(this)
%SETMASKSPECS   Set mask specs.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:06 $

switch lower(this.WeightingType)
    case 'cmessage'
        setcmessageweightingmask(this);
    case 'itut041'
        setitut041weightingmask(this);
    case 'itur4684'
        setitur4684weightingmask(this);
end

% [EOF]
