function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:59 $

switch lower(this.WeightingType)
    case 'cmessage'
        designobj.freqsamp = 'fdfmethod.freqsampaudioweightcmessage';
        designobj.equiripple = 'fdfmethod.eqripaudioweightcmessage';
        designobj.bell41009 = 'fdfmethod.bell41099audioweight';
    case 'itut041'
        designobj.freqsamp = 'fdfmethod.freqsampaudioweightitut041';
        designobj.equiripple = 'fdfmethod.eqripaudioweightitut041';
    case 'itur4684'
        designobj.freqsamp = 'fdfmethod.freqsampaudioweightitur4684';
        designobj.equiripple = 'fdfmethod.eqripaudioweightitur4684';
         designobj.iirlpnorm  = 'fdfmethod.lpnormaudioweightitur4684';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
