function q = quantizer(this)
%QUANTIZER Assignment quantizer for this fi object  
%   Q = QUANTIZER(A) returns the quantizer object Q that is
%   used in assigment operations for fi object A.
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:12:44 $

q = assignmentquantizer(this);
