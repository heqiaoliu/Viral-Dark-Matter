classdef tf < pmodel.Generic 
% SISO transfer function.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:36:47 $
      
   properties (Access = public)   
      % Numerator vector (row vector of parameters).
      %
      % Use this property to read the current value of the vector of numerator
      % coefficients or to initialize, fix, or free specific coefficients in
      % the numerator.
      num
      % Denominator vector (row vector of parameters).
      %
      % Use this property to read the current value of the vector of denominator
      % coefficients or to initialize, fix, or free specific coefficients in
      % the denominator.
      den
   end
      
   methods (Access = protected)
      
      % PARAMETER SERIALIZATION INTERFACE (PMODEL.GENERIC)
      function ps = getParamSet(M)
         ps = [M.num ; M.den];
      end
      
      function M = setParamSet(M,ps)
         M.num = ps(1);  M.den = ps(2);
      end
      
   end
   
   % PUBLIC METHODS
   methods
      
      function M = tf(num,den)
         % Constructs pmodel.tf instance
         % Note: The leading denominator coefficient is fixed to 1
         if nargin==0
            return
         end
         % Normalize leading denominator coefficient
         d1 = den(1);
         if d1~=1
            den = den/d1;  num = num/d1;
         end
         M.num = param.Continuous('num',num);
         M.den = param.Continuous('den',den);
         M.den.Free(1) = false;
      end
      
      
   end
   
   methods (Hidden)
      
      function s = iosize(~,~)
         % I/O sizes
         s = [1 1];
         if nargin>1
            s = 1;
         end
      end
      
   end
   
   
end




