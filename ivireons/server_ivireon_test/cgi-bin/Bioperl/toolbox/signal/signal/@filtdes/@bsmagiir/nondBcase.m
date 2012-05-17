function nondBcase(h,d)
%nondBcase Handle the linear case.
%
% This should be a private method.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:34:22 $

convertmag(h,d,...
    {'Apass1','Astop','Apass2'},...
    {'Epass1','Estop','Epass2'},...
    {'pass','stop','pass'},...
    @tosquared);
