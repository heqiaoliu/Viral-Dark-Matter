function tf = isinparfor
%ISINPARFOR                      Private utility function for parallel

%ISINPARFOR   True inside the body of a PARFOR loop
%   TF = ISINPARFOR returns true inside the body of a PARFOR loop
%   and false otherwise.
%
%   Example:
%
%      a = isinparfor
%      parfor i = 1:numlabs
%         b = isinparfor
%      end
%
%      returns a = false, b = true
%
%   See also PARFOR, NUMLABS.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/14 15:08:00 $

tf = parfor_depth > 0;
