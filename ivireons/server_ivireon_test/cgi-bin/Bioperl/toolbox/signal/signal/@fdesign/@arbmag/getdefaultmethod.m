function defaultmethod = getdefaultmethod(this)
%GETDEFAULTMETHOD   Get the defaultmethod.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:33 $

switch this.Specification,
    case 'N,F,A',
        defaultmethod = 'freqsamp';
    case 'Nb,Na,F,A', 
        defaultmethod = 'iirlpnorm';
    case 'N,B,F,A', 
        defaultmethod = 'equiripple';
    case 'Nb,Na,B,F,A',
        defaultmethod = 'iirlpnorm';
    otherwise,
        error(generatemsgid('InternalError'),'No default method for this specification set.');
end

% [EOF]
