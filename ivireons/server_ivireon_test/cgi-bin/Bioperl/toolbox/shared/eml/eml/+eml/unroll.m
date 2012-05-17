function y = unroll(x, ~)
%EML.UNROLL Completely unroll a FOR loop, repeating its body several times.
% 
%  Usage:
% 
%  for i = EML.UNROLL(RANGE) 
%    Generates the FOR loop similar to "for i = RANGE", but the 
%    generated code has no loop construction: the FOR loop body is just
%    cloned as many times as necessary, and the loop variable (i) is
%    assigned proper value at the beginning of each copy of the loop body.
%
%  for i = EML.UNROLL(RANGE, FLAG) 
%    FLAG is evaluated at compile time. If the evaluated value is FALSE, 
%    EML.UNROLL is ignored, and the generated code is exactly as for 
%    "for i = RANGE". If the value is TRUE, the loop is unrolled as described above.
% 
%  Example:
% 
%    for i = eml.unroll(1:nargin)
%      sum = sum + varargin{i};
%    end;
% 
%  This function has no effect in MATLAB; it just returns RANGE unchanged and
%  thus executes the ordinary FOR loop.

%   Copyright 2007-2010 The MathWorks, Inc.
  y = x;
