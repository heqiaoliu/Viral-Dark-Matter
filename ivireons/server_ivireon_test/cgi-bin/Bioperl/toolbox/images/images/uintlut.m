function B = uintlut(varargin)
%UINTLUT computes new values of A based on lookup table LUT.
%   UINTLUT(A,LUT) is an obsolete version of INTLUT(A,LUT). UINTLUT may be
%   removed in a future version of the toolbox.
%
%   UINTLUT(A,LUT) creates an array containing new values of A based on the
%   lookup table, LUT.  For example, if A is a vector whose kth element is equal
%   to alpha, then B(k) is equal to the LUT value corresponding to alpha, i.e.,
%   LUT(alpha+1).
%
%   Class Support
%   -------------
%   A must be uint8 or uint16. If A is uint8, then LUT must be a uint8 vector
%   with 256 elements.  If A is uint16, then LUT must be a uint16 vector with
%   65536 elements. B has the same size and class as A.
%
%
%   Example
%   -------
%        A = uint8([1 2 3 4; 5 6 7 8;9 10 11 12]);
%        LUT = repmat(uint8([0 150 200 255]),1,64);
%        B = uintlut(A,LUT);
%        figure, imshow(A), figure, imshow(B);
%
%   See also INTLUT.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/08/10 01:46:52 $

wid = sprintf('Images:%s:obsoleteFunction',mfilename);
msg = 'UINTLUT is obsolete and may be removed in a future release.';
msg2 = ' Using INTLUT instead of UINTLUT.';
warning(wid,'%s%s',msg,msg2);
B = intlut(varargin{:});
