function [blk, delCoeffName] = makeunused(blk)
%MAKEUNUSED Sets a block as unused or DUMMY

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/11 16:08:14 $

setblocktype(blk,'DUMMY');
blk.mainParam = ''; blk.label = '';

% collect deleted coefficient name
delCoeffName = blk.coeffnames;