classdef SlDemoSign < Simulink.IntEnumType
% SLDEMOSIGN Enumerated class to represent sign of real numbers
%
%   Allowable values:
%   - SlDemoSign.Positive
%   - SlDemoSign.Zero
%   - SlDemoSign.Negative

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:16:20 $

  enumeration
    Positive(1)
    Zero(0)
    Negative(-1)
  end

end

% EOF
