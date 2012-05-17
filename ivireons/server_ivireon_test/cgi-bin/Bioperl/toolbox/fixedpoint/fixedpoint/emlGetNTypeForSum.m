function [Tsum, errmsg] = emlGetNTypeForSum(Ta,Fa,sizeA,isConstSize,sumDim,maxWL)
%emlGetNTypeForSum  Get numerictype for SUM
%   [T,ERRMSG]=emlGetNTypeForSum(numerictype(A),fimath(A),size(A),isConstSize,SUMDIM,maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(sum(A,SUMDIM)).  If an error is detected, then an error
%   message will be returned in string ERRMSG. isConstSize is false if the caller
%   is an Embedded MATLAB library function and the sizes of the inputs are not known 
%   at compile-time; it is true otherwise.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/30 23:33:54 $

error(nargchk(3,6,nargin,'struct'));

if nargin == 5
    maxWL = uint32(32);
elseif nargin == 4
    maxWL = uint32(32);
    sumDim = 2;
elseif nargin == 3
    maxWL = uint32(32);
    sumDim = 2;
    isConstSize = true; 
end
if ~isConstSize&&(~strcmpi(Fa.SumMode,'SpecifyPrecision')&&~strcmpi(Fa.SumMode,'KeepLSB'))
    Tsum = numerictype; %dummy output numerictype
    errmsg = ['Embedded MATLAB only supports SumModes ''SpecifyPrecision'' and ''KeepLSB'' for ''sum'' when the size of the input can vary at run-time'];
else
    [Tsum,errmsg] = embedded.fi.GetNumericTypeForSum(Ta,Fa,double(sizeA),double(sumDim),int32(maxWL));
end
