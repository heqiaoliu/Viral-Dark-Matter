function B = intlut(varargin)
%INTLUT Convert integer values using lookup table.
%   B = INTLUT(A,LUT) converts values in array A based on lookup table
%   LUT and returns these new values in array B. 
%   
%   For example, if A is a uint8 vector whose kth element is equal
%   to alpha, then B(k) is equal to the LUT value corresponding
%   to alpha, i.e., LUT(alpha+1).
%
%   Class Support
%   -------------
%   A can be uint8, uint16, or int16. If A is uint8, LUT must be
%   a uint8 vector with 256 elements. If A is uint16 or int16, 
%   LUT must be a vector with 65536 elements that has the same class 
%   as A. B has the same size and class as A.
%
%   Example
%   -------
%        A = uint8([1 2 3 4; 5 6 7 8;9 10 11 12])
%        LUT = repmat(uint8([0 150 200 255]),1,64);
%        B = intlut(A,LUT)

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision.3 $  $Date: 2006/06/15 20:09:05 $

B = intlutc(varargin{:});
