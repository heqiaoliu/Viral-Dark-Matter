function disp(h)
%DISP Display object H

%   @modem/@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:01 $

% Object properties to show up in this order
fn = {'Type', ...
      'M', ...
      'Constellation', ...
      'SymbolOrder', ...
      'SymbolMapping', ...
      'OutputType', ...
      'DecisionType', ...
      'NoiseVariance'};
  
abstractDemodDisp(h, fn);
  
%--------------------------------------------------------------------

% [EOF]