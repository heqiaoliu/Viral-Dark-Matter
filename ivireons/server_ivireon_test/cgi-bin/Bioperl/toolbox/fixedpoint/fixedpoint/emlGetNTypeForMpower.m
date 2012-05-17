function [Tpower, errmsg] = emlGetNTypeForMpower(a,szA,k,Fa,maxWL)
%emlGetNTypeForMpower Get numerictype for MPOWER
%   [T,ERRMSG]=emlGetNTypeForMpower(A,K,fimath(A),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(MPOWER(A,K)).  If an error is detected, then an error
%   message will be returned in string ERRMSG.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/24 19:04:00 $

error(nargchk(4,5,nargin));
errmsg = '';
if nargin == 4
    
    maxWL = uint32(32);
end
try
    
    smode = Fa.SumMode;
    swl = Fa.SumWordLength;
    sfl = Fa.SumFractionLength;
    if strcmpi(smode, 'SpecifyPrecision')
         Tpower = numerictype(a.signed, swl, sfl);
    else
         ar = real(a);
         tmp = ar.^k;
         issmodefp = strcmpi(smode, 'FullPrecision');
         issmodekmsb = strcmpi(smode, 'KeepMSB');
         if (issmodefp||issmodekmsb)
             if isreal(a)
                 nb = ceil(log2(szA(1)));
             else
                 nb = ceil(log2(szA(1)+1));
             end
             if issmodefp
                 Tpower = numerictype(a.signed, tmp.wordlength + (k-1)*nb, tmp.fractionlength);
             else
                 Tpower = numerictype(a.signed, swl, swl - tmp.wordlength + tmp.fractionlength - (k-1)*nb);
             end
         else
             Tpower = numerictype(a.signed, swl, tmp.fractionlength);
         end
    end
    
catch ME
    
    errmsg = ME.message;
    Tpower = [];
    return;
end

if (Tpower.wordlength > maxWL)
    
    errmsg = sprintf(['The computed word length of the result is %d bits. ' ...
        'This exceeds the maximum supported wordlength of %d bits.'],Tpower.wordlength,maxWL);
    Tpower = [];
end
