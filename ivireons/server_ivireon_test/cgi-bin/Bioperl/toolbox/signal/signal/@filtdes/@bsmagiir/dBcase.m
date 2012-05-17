function dBcase(h,d)
%DBCASE Handle the dB case.
%
% This should be a private method.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:34:37 $

convertmag(h,d,...
    {'Epass1','Estop','Epass2'},...
    {'Apass1','Astop','Apass2'},...
    {'pass','stop','pass'},...
    'todb');