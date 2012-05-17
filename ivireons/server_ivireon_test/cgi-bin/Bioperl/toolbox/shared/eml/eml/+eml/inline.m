function inline(~)
% EML.INLINE controls inlining of the current function.
%
%  Usage:
%
%  EML.INLINE('always') forces the current function to be inlined
%  in the generated code.
%
%  EML.INLINE('never') ensures the current function is never
%  inlined in the generated code.
%
%  EML.INLINE('default') restores the default inlining behavior. A
%  heuristic decides whether or not to inline the function.
%
%  Example:
%    function y = foo(x)
%       eml.inline('never');
%       y = x;
%    end
%
%  This function has no effect in MATLAB; it applies to Embedded MATLAB only.
%
%  Copyright 2007-2010 The MathWorks, Inc.

