function disp(h)
%DISP Display object H

%   @modem/@pammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:14 $

% Object properties to show up in this order
fn = {'Type', ...
      'M', ...
      'Constellation', ...
      'SymbolOrder', ...
      'SymbolMapping', ...
      'InputType'};

abstractModDisp(h, fn);
  
%--------------------------------------------------------------------

% [EOF]