function [T,errmsg] = emlGetNTypeForMTimes(Ta,Tb,Fa,Aisreal,Bisreal,p,isConstSize,maxWL,callerName)
%emlGetNTypeForMTimes  Get numerictype for matrix times (MTIMES)
%   [T,ERRMSG]=emlGetNTypeForMTimes(numerictype(A),numerictype(B),fimath(A),isreal(A),isreal(B),size(A,2),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(A*B).  If an error is detected, then an error message will be
%   returned in string ERRMSG.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 03:18:06 $

error(nargchk(6,9,nargin,'struct'));
if nargin == 8
    callerName = 'mtimes';
elseif nargin == 7
    callerName = 'mtimes';    
    maxWL = uint32(32);
elseif nargin == 6
    callerName = 'mtimes';        
    isConstSize = true;
    maxWL = uint32(32);
end

if ~isConstSize&&(~strcmpi(Fa.SumMode,'SpecifyPrecision')&&~strcmpi(Fa.SumMode,'KeepLSB'))
    T = numerictype; %dummy output numerictype
    errmsg = ['Embedded MATLAB only supports SumModes ''SpecifyPrecision'' and ''KeepLSB'' for ''' callerName ''' when the size of the inputs can vary at run-time'];
else
    [T,errmsg] = embedded.fi.GetNumericTypeForMatrixTimes(Ta,Tb,Fa,Aisreal,Bisreal,double(p),int32(maxWL));
end
    
