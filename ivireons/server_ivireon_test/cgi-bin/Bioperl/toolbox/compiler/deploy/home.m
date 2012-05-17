function status = home

% Copyright 2004 The MathWorks, Inc.

  warning('Compiler:NoHome', ....
           'The HOME function will do nothing in compiled applications.' );

   % Always fail
   status = 1;