function [T,errmsg] = emlGetNTypeForTimes(Ta,Tb,Fa,Aisreal,Bisreal,maxWL)
%emlGetNTypeForTimes  Get numerictype for TIMES
%   [T,ERRMSG]=emlGetNTypeForTimes(numerictype(A),numerictype(B),fimath(A),isreal(A),isreal(B),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(A.*B).  If an error is detected, then an error message will be
%   returned in string ERRMSG.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/08 17:10:51 $

error(nargchk(5,6,nargin,'struct'));
if nargin == 5
    maxWL = uint32(32);
end
errmsg = '';

if ~isfixed(Tb)
    if isslopebiasscaled(Ta)&&~strcmpi(Fa.ProductMode,'SpecifyPrecision')
        errmsg = 'Math is only supported for slope-bias FIs when the ProductMode is SpecifyPrecision.';        
    end
elseif ~isfixed(Ta)
    if isslopebiasscaled(Tb)&&~strcmpi(Fa.ProductMode,'SpecifyPrecision')
        errmsg = 'Math is only supported for slope-bias FIs when the ProductMode is SpecifyPrecision.';        
    end
else
    if (isslopebiasscaled(Ta)||isslopebiasscaled(Tb))&&~strcmpi(Fa.ProductMode,'SpecifyPrecision')
        errmsg = 'Math is only supported for slope-bias FIs when the ProductMode is SpecifyPrecision.';        
    end

end

if isempty(errmsg)
    [T,errmsg] = embedded.fi.GetNumericTypeForTimes(Ta,Tb,Fa,Aisreal,Bisreal,int32(maxWL));
else
    T = Ta;
end
    
