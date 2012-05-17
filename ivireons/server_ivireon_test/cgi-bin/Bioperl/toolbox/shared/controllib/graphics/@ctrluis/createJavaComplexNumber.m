function out = createJavaComplexNumber(expr) 
% CREATECOMPLEXJAVATYPE static pacakge function to create a java
% ComplexScalarDouble object from a matlab expression.
%
 
% Author(s): A. Stothert 22-Mar-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:11 $

import com.mathworks.widgets.spreadsheet.data.*;

out = [];  %Default empty return;

if ischar(expr)
   %Have expression to evaluate
   expr = evalin('base',expr);
end

%Should have a numerical value by now
if(isscalar(expr))
   %Scalar value
   if(isreal(expr))
      %Real number
      out = ComplexScalarFactory.valueOf(real(expr));
   else
      %Complex number
      out = ComplexScalarFactory.valueOf(real(expr),imag(expr));
   end
end
