%|   Logical OR.
%   A | B performs a logical OR of arrays A and B and returns an array
%   containing elements set to either logical 1 (TRUE) or logical 0
%   (FALSE).  An element of the output array is set to 1 if either input
%   array contains a non-zero element at that same array location.
%   Otherwise, that element is set to 0.  A and B must have the same 
%   dimensions unless one is a scalar.  
%
%   C = OR(A,B) is called for the syntax 'A | B' when A or B is an
%   object.
%
%   Note that there are two logical OR operators in MATLAB.  The |
%   operator performs an element-by-element OR between matrices, while 
%   the || operator performs a short-circuit OR between scalar values.
%   These operations are explained in the MATLAB Programming documentation 
%   on logical operators, under the topic of Basic Program Components.
%
%   See also RELOP, AND, XOR, NOT

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.10.4.6 $  $Date: 2005/06/21 19:36:33 $

