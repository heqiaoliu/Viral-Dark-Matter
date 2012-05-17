function nondBcase(h,d)
%nondBcase Handle the linear case.
%
% This should be a private method.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:13:27 $

convertmag(h,d,...
    {'Apass'},...
    {'Dpass'},...
    {'pass'},...
    @tolinear);