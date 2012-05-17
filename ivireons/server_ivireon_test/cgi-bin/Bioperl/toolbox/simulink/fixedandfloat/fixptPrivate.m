function res = fixptPrivate( action, varargin );
% fixptPrivate This is function for private use by Simulink-Fixed-Point
%              

% Copyright 1994-2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  
% $Date: 2007/12/10 22:39:53 $

if strcmp(action,'fhpBestPrecisionQuantizeParts')
  
  value    = varargin{1};
  mantBits = varargin{2};
  isSigned = varargin{3};
  
  Slope  = 0;
  FixExp = 0;
  
  if value ~= 0
  
    recipValue = 1.0 / value;
    
    fe = fixptbestexp( recipValue, mantBits, isSigned );
    
    recipValue = num2fixpt( recipValue, fixdt(isSigned,mantBits), 2^fe, 'Nearest', 'on' );
    
    if recipValue ~= 0
      
      value = 1.0 / recipValue;
      
      [Slope,FixExp] = log2(value);
      
      Slope = 2 * Slope;
      
      FixExp = FixExp - 1;
      
    end
  end
  
  res = [Slope FixExp];
  
else
  error('Simulink:fixandfloat:unknownAct','Unknown action');
end
  
