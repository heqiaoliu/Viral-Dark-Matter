function dBcase(h,d)
%DBCASE Handle the dB case.
%
% This should be a private method.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:34:07 $

convertmag(h,d,...
    {'Dpass1','Dstop','Dpass2'},...
    {'Apass1','Astop','Apass2'},...
    {'pass','stop','pass'},...
    @todb);