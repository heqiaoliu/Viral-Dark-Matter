function setsumstr(hTar, blockhandles, str)
%SETSUMSTR Set the string of signs of the adder.

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:58 $

set_param(blockhandles, 'Inputs', str);
        