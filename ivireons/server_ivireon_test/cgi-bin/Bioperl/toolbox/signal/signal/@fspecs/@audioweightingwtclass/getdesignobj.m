function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:12 $

switch lower(this.WeightingType)
    case 'a'
        designobj.ansis142 = 'fdfmethod.ansis142audioweighta';
    case 'c'
        designobj.ansis142 = 'fdfmethod.ansis142audioweightc';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
