function z=subsasgn(x,s,y)
%SUBSASGN Subscripted assignment A(I)=B for GF arrays.
%   A(I) = B assigns the values of B into the elements of A specified by
%   the subscript vector I.  B must have the same number of elements as I
%   or be a scalar. 

%    Copyright 1996-2008 The MathWorks, Inc.
%    $Revision: 1.3.4.3 $  $Date: 2008/05/31 23:15:15 $ 

switch s.type
case '()'
  z=x;
  y=gf(y,x.m,x.prim_poly);
  z.x(s.subs{:}) = y.x;
case '{}'
  error('comm:gf_subsasgn:InvalidParenthesis','{} reference not allowed for assignment')
case '.'
  error('comm:gf_subsasgn:UseOfDotNotAllowed','. reference not allowed for assignment')
end

