function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:48:15 $

%#function fmethod.butterbpmin
%#function fmethod.cheby1bpmin
%#function fmethod.cheby2bpmin
%#function fmethod.ellipbpmin
designobj.butter     = 'fmethod.butterbpmin';
designobj.cheby1     = 'fmethod.cheby1bpmin';
designobj.cheby2     = 'fmethod.cheby2bpmin';
designobj.ellip      = 'fmethod.ellipbpmin';

if isfdtbxinstalled
    %#function fdfmethod.eqripbpmin
    designobj.equiripple = 'fdfmethod.eqripbpmin';
else
    %#function fmethod.eqripbpmin
    designobj.equiripple = 'fmethod.eqripbpmin';
end

%#function fmethod.kaiserbpmin
designobj.kaiserwin  = 'fmethod.kaiserbpmin';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
