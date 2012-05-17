function dBcase(h,d)
%DBCASE Handle the dB case.
%
% This should be a private method.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:09:47 $

convertmag(h,d,...
    {'Dpass','Dstop'},...
    {'Apass','Astop'},...
    {'pass','stop'},...
    'todb');

% [EOF]