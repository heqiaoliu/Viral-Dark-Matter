function b = isa(h, clz)
%ISA      True if H is a CLZ

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/14 19:34:54 $

% Using the overloaded UDD find and not the built-in method
b = ~isempty(find(h, '-depth', 0, '-isa', clz)); %#ok<GTARG>

% [EOF]
