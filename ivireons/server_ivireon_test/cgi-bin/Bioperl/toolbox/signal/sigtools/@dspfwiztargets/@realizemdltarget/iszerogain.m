function y = iszerogain(hTar, blockhandles, H)
%ISZEROGAIN Test for zero gains.

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:42 $

gainval = get_param(blockhandles, 'Gain');
y = str2double(gainval)==0;
