function isemp = isempty(Obj)
%ISEMPTY True for empty timer arrays
%
%    ISEMPTY(X) returns 1 if X is an empty timer array and 0 otherwise. An
%    empty timer array has no elements, that is length(X)==0.
%

%    Copyright 2001-2008 The MathWorks, Inc.
%    $Revision: 1.2.4.3 $  $Date: 2008/10/02 19:01:53 $

%Note that numel is NOT equivalent to length for all objects.
isemp = (length(Obj) == 0); %#ok<ISMT>

