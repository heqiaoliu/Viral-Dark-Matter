function [Tplus,errmsg] = emlGetNTypeForPlus(Ta,Tb,Fa,maxWL)
%emlGetNTypeForPlus  Get numerictype for plus
%   [T,ERRMSG]=emlGetNTypeForPlus(numerictype(A),numerictype(B),fimath(A),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(A+B).  If an error is detected, then an error message will be
%   returned in string ERRMSG.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/08 17:10:50 $

error(nargchk(3,4,nargin,'struct'));
if nargin == 3
    maxWL = uint32(32);
end
errmsg = '';

if ~isfixed(Tb)
    if isslopebiasscaled(Ta)&&~strcmpi(Fa.SumMode,'SpecifyPrecision')
        errmsg = 'Math is only supported for slope-bias FIs when the SumMode is SpecifyPrecision.';        
    end
elseif ~isfixed(Ta)
    if isslopebiasscaled(Tb)&&~strcmpi(Fa.SumMode,'SpecifyPrecision')
        errmsg = 'Math is only supported for slope-bias FIs when the SumMode is SpecifyPrecision.';        
    end
else
    if (isslopebiasscaled(Ta)||isslopebiasscaled(Tb))&&~strcmpi(Fa.SumMode,'SpecifyPrecision')
        errmsg = 'Math is only supported for slope-bias FIs when the SumMode is SpecifyPrecision.';        
    end

end

if isempty(errmsg)
    [Tplus,errmsg] = embedded.fi.GetNumericTypeForPlus(Ta,Tb,Fa,int32(maxWL));
else
    Tplus = Ta;
end
