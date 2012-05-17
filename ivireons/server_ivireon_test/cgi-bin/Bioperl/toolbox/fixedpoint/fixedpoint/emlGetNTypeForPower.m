function [Tpower, errmsg] = emlGetNTypeForPower(a,k,Fa,maxWL)
%emlGetNTypeForPower Get numerictype for POWER
%   [T,ERRMSG]=emlGetNTypeForPower(A,K,fimath(A),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(POWER(A,K)).  If an error is detected, then an error
%   message will be returned in string ERRMSG.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/28 20:18:46 $

error(nargchk(3,4,nargin));
errmsg = '';
if nargin == 3
    
    maxWL = uint32(32);
end
a1 = fi(a, Fa);
try
    
    y = a1.^k;
catch ME
    
    errmsg = ME.message;
    Tpower = [];
    return;
end
Tpower = numerictype(y);
if (Tpower.wordlength > maxWL)
    errmsg = sprintf(['The computed word length of the result is %d bits. ' ...
        'This exceeds the maximum supported wordlength of %d bits.'],Tpower.wordlength,maxWL);
    Tpower = [];
end