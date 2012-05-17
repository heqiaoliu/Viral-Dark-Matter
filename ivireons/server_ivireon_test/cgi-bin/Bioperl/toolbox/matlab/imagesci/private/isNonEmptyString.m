function tf = isNonEmptyString(strIn)
%ISNONEMPTYSTRING Returns true if the input is a nonempty string

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:15:01 $

tf = ischar(strIn) && ~isempty(strIn);