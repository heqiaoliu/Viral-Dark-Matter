function out = convertJavaComplexToDouble(hJavaComplex)
% CONVERTJAVACOMPLEXTODOUBLE static pacakge function to convert a Java
% ComplexScalarDouble to a matlab double
%
 
% Author(s): A. Stothert 22-Mar-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:10 $

if(isa(hJavaComplex,'com.mathworks.widgets.spreadsheet.data.ComplexScalarDouble'))
   out = hJavaComplex.doubleValueReal + ...
      hJavaComplex.doubleValueImaginary*i;
elseif( isa(hJavaComplex,'double'))
   out = hJavaComplex;
else
   out = [];
end