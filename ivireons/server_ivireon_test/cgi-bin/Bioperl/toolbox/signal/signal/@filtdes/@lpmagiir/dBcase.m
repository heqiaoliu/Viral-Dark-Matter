function dBcase(h,d)
%DBCASE Handle the dB case.
%
% This should be a private method.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:45:29 $

convertmag(h,d,...
    {'Epass','Estop'},...
    {'Apass','Astop'},...
    {'pass','stop'},...
    'todb');