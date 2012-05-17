function disp(h)
%DISP Display object H

%   @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:42 $

% Object properties to show up in this order
fn = {'Type', ...
      'M', ...
      'SamplesPerSymbol', ...
      'Precoding', ...
      'OutputType', ...
      'DecisionType', ...
      'NoiseVariance'};

abstractDemodDisp(h, fn);
  
%--------------------------------------------------------------------

% [EOF]