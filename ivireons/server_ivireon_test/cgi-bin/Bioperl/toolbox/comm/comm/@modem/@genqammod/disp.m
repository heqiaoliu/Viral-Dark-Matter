function disp(h)
%DISP Display object H

%   @modem/@genqammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:43 $

% Object properties to show up in this order
fn = {'Type', ...
      'M', ...
      'Constellation', ...
      'InputType'};

abstractModDisp(h, fn);
  
%--------------------------------------------------------------------

% [EOF]