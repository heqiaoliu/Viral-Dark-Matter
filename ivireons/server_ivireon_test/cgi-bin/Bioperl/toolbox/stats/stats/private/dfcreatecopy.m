function [new, fittype]=dfcreatecopy(original);

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:40 $
%   Copyright 2003-2004 The MathWorks, Inc.

fittype = original.fittype;

new = copyfit(original);
new = java(new);

