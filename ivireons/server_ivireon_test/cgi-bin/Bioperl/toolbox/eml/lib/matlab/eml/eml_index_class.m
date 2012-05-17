function cls = eml_index_class
%Embedded MATLAB Private Function

%   Returns the default class for an index variable.
%   Properties:
%   1) This class is always an integer class.
%   2) The elements of a SIZE vector can always be cast to EML_INDEX_CLASS 
%      without saturation.
%   3) This class may be signed or unsigned.  No algorithm should depend on
%      it being signed or unsigned.  When an unsigned class is required, 
%      EML_UNSIGNED_CLASS can be used to map EML_INDEX_CLASS to the unsigned 
%      integer class with the same number of bits.  Note that a corresponding 
%      function EML_SIGNED_CLASS could be added, but it would return a class 
%      that might not satisfy property #2, so it is usually preferable to 
%      reformulate an algorithm so that index variables take on non-negative
%      values only.

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml 

cls = 'int32';
