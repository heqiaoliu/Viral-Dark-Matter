function y = isunitgain(hTar, blockhandles, H)
%ISUNITGAIN Test for unity gain.

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:41 $

gainval = get_param(blockhandles, 'Gain');
y = str2double(gainval)==1;
        