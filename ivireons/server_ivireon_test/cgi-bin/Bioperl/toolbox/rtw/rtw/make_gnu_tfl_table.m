function hLib = make_gnu_tfl_table

% Copyright 2003-2007 The MathWorks, Inc.

% $Revision $
% $Date: 2007/06/18 23:02:06 $

  hLib = RTW.TflTable;

  hLib.registerCFunctionEntry(98, 1,'ten_u', 'double', 'exp10', 'double', '<math.h>','','');
  hLib.registerCFunctionEntry(98, 1,'ten_u', 'single', 'exp10f', 'single', '<math.h>','','');

