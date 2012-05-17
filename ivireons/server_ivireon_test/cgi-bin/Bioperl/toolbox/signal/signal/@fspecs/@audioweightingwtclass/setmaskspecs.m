function setmaskspecs(this)
%SETMASKSPECS   Set mask specs.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:17 $

switch lower(this.WeightingType)
    case 'a'
        setaweightingmask(this);                
    case 'c'        
        setcweightingmask(this);
end

% [EOF]
