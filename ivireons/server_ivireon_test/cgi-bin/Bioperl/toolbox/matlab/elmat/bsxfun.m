% BSXFUN  Binary Singleton Expansion Function
%   C = BSXFUN(FUNC,A,B) applies the element-by-element binary operation
%   specified by the function handle FUNC to arrays A and B, with singleton
%   expansion enabled. FUNC must be able to accept as input either two column
%   vectors of the same size, or one column vector and one scalar, and return
%   as output a column vector of the same size as the input(s).  FUNC can
%   either be a function handle for an arbitrary function satisfying the above
%   conditions or one of the following built-in functions:
%
%               @plus           Plus
%               @minus          Minus
%               @times          Array multiply
%               @rdivide        Right array divide
%               @ldivide        Left array divide
%               @power          Array power
%               @max            Binary maximum
%               @min            Binary minimum
%               @rem            Remainder after division
%               @mod            Modulus after division
%               @atan2	        Four-quadrant inverse tangent
%               @hypot	        Square root of sum of squares
%               @eq             Equal
%               @ne             Not equal
%               @lt             Less than
%               @le             Less than or equal
%               @gt             Greater than
%               @ge             Greater than or equal
%               @and            Element-wise logical AND
%               @or             Element-wise logical OR
%               @xor            Logical EXCLUSIVE OR
%
%   Each dimension of A and B must be equal to each other, or equal to one.
%   Whenever a dimension of one of A or B is singleton (equal to 1), the array
%   is virtually replicated along that dimension to match the other array
%   (or diminished if the corresponding dimension of the other array is 0).
%   The size of the output array C is equal to
%   max(size(A),size(B)).*(size(A)>0 & size(B)>0). For example, if
%   size(A) == [2 5 4] and size(B) == [2 1 4 3], then size(C) == [2 5 4 3].
%
%   Examples:
%
%   Subtract the column means from the matrix A:
%     A = magic(5);
%     A = bsxfun(@minus, A, mean(A));
%
%   Scale each row of A by its maximum absolute value:
%     A = rand(5);
%     A = bsxfun(@rdivide, A, max(abs(A),[],2));
%
%   Compute z(x, y) = x.*sin(y) on a grid:
%     x = 1:10;
%     y = x.';
%     z = bsxfun(@(x, y) x.*sin(y), x, y);
%
%   See also REPMAT, ARRAYFUN

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/13 17:38:52 $
%   Built-in function.

