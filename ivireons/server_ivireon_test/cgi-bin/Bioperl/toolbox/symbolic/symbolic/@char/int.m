function y = int(f,varargin)
%INT    Alternative entry to the symbolic integration function.
%   INT(F,...) is the same as int(sym(F),...). This method will
%   be removed in a future release. Use int(sym(F)...) instead.
%   See also SYM/INT.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 07:32:12 $

warning('symbolic:char:int:ToBeRemoved','The method char/int will be removed in a future relase. Use sym/int instead. For example int(sym(''x^2'')).');

y = int(sym(f),varargin{:});
