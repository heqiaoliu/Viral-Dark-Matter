function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:49:06 $

%#function fmethod.butterhpmin
%#function fmethod.cheby1hpmin
%#function fmethod.cheby2hpmin
%#function fmethod.elliphpmin
designobj.butter     = 'fmethod.butterhpmin';
designobj.cheby1     = 'fmethod.cheby1hpmin';
designobj.cheby2     = 'fmethod.cheby2hpmin';
designobj.ellip      = 'fmethod.elliphpmin';

if isfdtbxinstalled
    %#function fdfmethod.eqriphpmin
    %#function fdfmethod.ifirhpmin
    designobj.equiripple = 'fdfmethod.eqriphpmin';
    designobj.ifir       = 'fdfmethod.ifirhpmin';
else
    %#function fmethod.eqriphpmin
    designobj.equiripple = 'fmethod.eqriphpmin';
end
%#function fmethod.kaiserhpmin
designobj.kaiserwin  = 'fmethod.kaiserhpmin';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
