% Fixed-Point Toolbox
% Version 3.2 (R2010b) 03-Aug-2010
%
% Fixed-Point Objects.
%   fi                     - Fixed-point object constructor.
%   fimath                 - Fixed-point math object constructor.
%   numerictype            - Numeric type object constructor.
%
% Display preferences.
%   fipref                 - Fixed-point display preferences.
%   savefipref             - Save fixed-point display preferences.
%
% NUMERICTYPE properties of fi.
%   Bias                   - Bias.
%   DataType               - Data type: Fixed
%   DataTypeMode           - Data type mode: combination of DataType and Scaling.
%   FixedExponent          - Fixed exponent = -FractionLength.
%   FractionLength         - Fraction length = -FixedExponent.
%   Scaling                - Scaling: {BinaryPoint, SlopeBias, Unspecified}
%   Signed                 - Signed: true = signed, false = unsigned.
%   Slope                  - Slope = SlopeAdjustmentFactor * 2^FixedExponent.
%   SlopeAdjustmentFactor  - Slope adjustment factor.
%   WordLength             - Word length, in bits.
%
% FIMATH properties of fi.
%   CastBeforeSum          - Cast both operands in A+B to the sum type before addition.
%   MaxProductWordLength   - Maximum word length for products.  Can be set from 2 to 2147483647.
%   MaxSumWordLength       - Maximum word length for sums.  Can be set from 2 to 2147483647.
%   OverflowMode           - Overflow mode: {Saturate, Wrap}
%   ProductFractionLength  - Product length when ProductMode is SpecifyPrecision.
%   ProductMode            - Product mode: {FullPrecision, KeepLSB, KeepMSB, SpecifyPrecision}.
%   ProductWordLength      - Product word length when ProductMode is one of KeepLSB, KeepMSB, or SpecifyPrecision.
%   RoundMode              - Round mode: {ceil, convergent, fix, floor, nearest, round}
%   SumFractionLength      - Sum fraction length, when ProductMode is SpecifyPrecision.
%   SumMode                - Sum mode: {FullPrecision, KeepLSB, KeepMSB, SpecifyPrecision}.
%   SumWordLength          - Sum word length when ProductMode is one of KeepLSB, KeepMSB, or SpecifyPrecision.
%
% Data access properties of fi.  In the following, let A=fi(pi);
%   double                 - A.double = 3.1416015625 sets A's real-world-value from the double value.
%   int                    - A.int    = 25736 sets A's stored integer from the integer.
%
%   bin                    - A.bin = '0110010010001000' sets A's stored integer from the binary string.
%   oct                    - A.oct = '062210' sets A's stored integer from the octal string.
%   dec                    - A.dec = '25736' sets A's stored integer from the decimal string.
%   hex                    - A.hex = '6488' sets A's stored integer from the hex string.
%
%
% Functions that work with fi objects.
%   all                    - True if all elements of a vector are nonzero.
%   and                    - Logical AND: called for A & B.
%   any                    - True if any element of a vector is nonzero.
%   bin                    - Binary representation.
%   bitand                 - Bit-wise AND.
%   bitcmp                 - Complement bits.
%   bitget                 - Get bit.
%   bitor                  - Bit-wise OR.
%   bitset                 - Set bit.
%   bitshift               - Bit-wise shift.
%   bitxor                 - Bit-wise XOR.
%   complex                - Construct complex result from real and imaginary parts.
%   conj                   - Complex conjugate.
%   ctranspose             - Complex conjugate transpose: called for A'
%   data                   - Closest real-world-value that can be represented as a double.
%   dec                    - Decimal integer string representation of stored integer.
%   disp                   - Display without printing the variable name.
%   display                - Display with printing the variable name.
%   double                 - Closest real-world-value that can be represented as a double.
%   eps                    - Scaling of the least-significant bit.
%   eq                     - Equal: called for A==B.
%   fi                     - Constructs a fi object.
%   fieldnames             - Get object's field names.
%   fimath                 - Get fimath object associated with this fi.
%   ge                     - Greater than or equal: called for A >= B.
%   gt                     - Greater than: called for A > B.
%   hex                    - Hex representation of the stored integer.
%   horzcat                - Horizontal concatenation: called for [A B].
%   imag                   - Complex imaginary part.
%   int                    - Stored integer value as MATLAB native integer.
%   int16                  - Stored integer value cast to int16.
%   int32                  - Stored integer value cast to int32.
%   int8                   - Stored integer value cast to int8.
%   intmax                 - Largest stored integer value.
%   intmin                 - Smallest stored integer value. 
%   iscolumn               - True if array is a column vector.
%   isempty                - True if empty.
%   isequal                - True arrays are numerically equal.
%   isfi                   - True if fi object.
%   isnumeric              - True for numeric arrays.  fi objects are considered numeric arrays.
%   ispropequal            - True if arrays are numerically equal and all properties are equal.
%   isreal                 - True if array does not have an imaginary part.
%   isrow                  - True if array is a row vector.
%   isscalar               - True if array is a scalar.
%   issigned               - True if the Signed property is true.
%   isvector               - True if array is a vector (either row or column).
%   le                     - Less than or equal: called for A <= B.
%   length                 - Length of vector, or max dimension.
%   logical                - Convert numeric values to logical.
%   loglog                 - Log-log scale plot.
%   lowerbound             - Least value representable.
%   lsb                    - Scale of the least-significant-bit.
%   lt                     - Less than: called for A < B.
%   max                    - Largest component.
%   min                    - Smallest component.
%   minus                  - Minus: called for A - B.
%   mtimes                 - Matrix multiply: called for A * B.
%   ndims                  - Number of dimensions.
%   ne                     - Not equal: called for A ~= B.
%   not                    - Logical NOT: called for ~A.
%   numberofelements       - Number of elements in array.
%   numerictype            - Get numerictype object associated with this fi.
%   oct                    - Octal representation of the stored integer.
%   or                     - Logical OR: called for A | B.
%   permute                - Permute array dimensions.
%   plot                   - Linear plot.
%   plus                   - Plus: called for A + B.
%   pow2                   - Multiply by an integral power of 2.
%   range                  - Numerical range.
%   real                   - Complex real part.
%   realmax                - Greatest representable value.
%   realmin                - Smallest positive value representable.
%   repmat                 - Replicate and tile array.
%   rescale                - Change the scaling of a fi, while keeping its stored integer value.
%   reshape                - Change shape of an array.
%   semilogx               - Semi-log scale plot.
%   semilogy               - Semi-log scale plot.
%   shiftdata              - Shift data to operate on a specified dimension.
%   size                   - Size of array.
%   squeeze                - Remove singleton dimensions.
%   stripscaling           - Strip scaling information from fi.
%   subsasgn               - Subscripted assignment: called for A(k) = B.
%   subsref                - Subscripted reference: called for A = B(k).
%   sum                    - Sum of elements.
%   times                  - Array multiply: called for A .* B
%   transpose              - Transpose: called for A.'
%   uint16                 - Stored integer value cast to int16.
%   uint32                 - Stored integer value cast to int32.
%   uint8                  - Stored integer value cast to int8. 
%   uminus                 - Unary minus: called for -A
%   unshiftdata            - The inverse of shiftdata.
%   uplus                  - Unary plus: called for +A.
%   upperbound             - Greatest representable value.
%   vertcat                - Vertical concatenation: called for [A;B]
%   xor                    - Logical EXCLUSIVE OR.

%   Copyright 2003-2010 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.3 $Date: 2005/12/19 07:26:48 $

