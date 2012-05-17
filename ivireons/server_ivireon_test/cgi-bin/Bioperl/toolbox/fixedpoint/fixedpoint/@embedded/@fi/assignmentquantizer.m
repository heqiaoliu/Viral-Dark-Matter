function q = assignmentquantizer(this)
%ASSIGNMENTQUANTIZER  Assignment quantizer for this fi object.  
%    Q = ASSIGNMENTQUANTIZER(A) returns the quantizer object Q that is
%    used in assigment operations for fi object A.

%   Thomas A. Bryan
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/08/10 01:35:53 $

q = quantizer;
setQuantizerFromFi(this,q);
