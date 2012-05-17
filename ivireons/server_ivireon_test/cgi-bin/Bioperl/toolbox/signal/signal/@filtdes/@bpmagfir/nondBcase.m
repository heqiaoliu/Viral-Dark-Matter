function nondBcase(h,d)
%NONDBCASE Handle the linear case.
%
% This should be a private method.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:31:21 $

convertmag(h,d,...
    {'Astop1','Apass','Astop2'},...
    {'Dstop1','Dpass','Dstop2'},...
    {'stop','pass','stop'},...
    @tolinear);