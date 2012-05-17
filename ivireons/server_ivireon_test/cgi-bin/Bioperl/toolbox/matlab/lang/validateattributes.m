%VALIDATEATTRIBUTES Check validity of array.
%   VALIDATEATTRIBUTES(A,CLASSES,ATTRIBUTES,FUNC_NAME,VAR_NAME, ARG_POS)
%   checks the validity of the array A and issues a formatted error message
%   if it is invalid. A can be an array of any class.
%
%   CLASSES is a cell array of strings containing the set of classes that A
%   is expected to belong to.  For example, if you specify CLASSES as
%   {'logical','cell'}, A is required to be either a logical array or a
%   cell array. The string 'numeric' is interpreted as an abbreviation for
%   the classes uint8, uint16, uint32, uint64, int8, int16, int32, int64,
%   single, double.
%
%   ATTRIBUTES is a cell array of strings specifying the set of attributes
%   that A must satisfy.  For example, if you specify ATTRIBUTES as
%   {'real', 'nonempty','finite'}, A must be real and nonempty, and it must
%   contain only finite values.  The supported list of attributes includes:
%   
%            2d        binary      nonempty           odd          size
%             <        column        nonnan      positive        vector
%            <=          even   nonnegative          real              
%             >        finite     nonsparse           row              
%            >=       integer       nonzero        scalar              
%
%   The <, <=, >, and >= attributes check if A is within a given range.
%   {'<', v} checks if A < v, {'<=', v} checks if A <= v, {'>', v} checks
%   if A > v, and {'>=', v} checks if A >= v.  The size attribute validates
%   the size of A.  {'size', [M N P ...]} validates the size(A) is equal to
%   [M N P ...].
%
%   FUNC_NAME is a string that specifies the name used in the formatted
%   error message to identify the function checking the input.  FUNC_NAME
%   is an optional argument.
%
%   VAR_NAME is a string that specifies the name used in the formatted
%   error message to identify the argument being checked.  VAR_NAME is an
%   optional argument.
%
%   ARG_POS is a positive integer that indicates the position of the
%   argument being checked in the function argument list. 
%   VALIDATEATTRIBUTES includes this information in the formatted error
%   message.  ARG_POS is an optional argument.
%
%   Example
%   -------
%       % To trigger this error message, create a three dimensional array
%       % and then check for the attribute '2d'.
%       A = [ 1 2 3; 4 5 6 ];
%       B = [ 7 8 9; 10 11 12];
%       C = cat(3,A,B);
%       validateattributes(C,{'numeric'},{'2d'},'my_func','my_var',2)
%
%   See also validatestring, inputParser.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/04 21:21:02 $
