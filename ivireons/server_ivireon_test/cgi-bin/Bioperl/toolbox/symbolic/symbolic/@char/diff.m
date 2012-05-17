function y = diff(f,varargin)
%DIFF   Alternative entry to the symbolic differentiation function.
%   DIFF(F,...) is the same as diff(sym(F),...). This method will
%   be removed in a future release. Use diff(sym(F)...) instead.
%   See also SYM/DIFF.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 07:32:11 $

warning('symbolic:char:diff:ToBeRemoved','The method char/diff will be removed in a future release. Use sym/diff instead. For example diff(sym(''x^2'')). After removal diff(''x^2'') will return diff(double(''x^2'')).');
y = diff(sym(f),varargin{:});
