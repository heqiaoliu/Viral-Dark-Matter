function t = issigned(this)
%ISSIGNED True for signed fixed-point object
%   ISSIGNED(A) returns 1 if fixed-point object A is signed, and 0 if
%   it is unsigned.

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:28 $

t = this.signed;
