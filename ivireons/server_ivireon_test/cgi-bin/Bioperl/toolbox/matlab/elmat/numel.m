%NUMEL   Number of elements in an array or subscripted array expression.
%   N = NUMEL(A) returns the number of elements, N, in array A.
%
%   N = NUMEL(A, INDEX1, INDEX2, ...) returns in N the number of 
%   subscripted elements in array A(index1, index2, ...).
%
%   MATLAB implicitly calls the NUMEL builtin function whenever an
%   expression such as A{index1, index2, ...} or A.fieldname generates 
%   a comma-separated list.
%
%   It is important to note the significance of NUMEL with regards
%   to the overloaded SUBSREF and SUBSASGN functions. In the case of
%   the overloaded SUBSREF function, NUMEL is used to compute the 
%   number of expected outputs (NARGOUT) returned from SUBSREF. For
%   the overloaded SUBSASGN function, NUMEL is used to compute the 
%   number of expected inputs (NARGIN) to be assigned using SUBSASGN.
%   The NARGIN value for the overloaded SUBSASGN function consists of
%   the variable being assigned to, the structure array of subscripts,
%   and the value returned by NUMEL.  
%
%   It is vital that class designers ensure that the value of N
%   returned by the builtin NUMEL function is consistent with the 
%   class design for that object. If the value of N returned by the 
%   builtin NUMEL function is different from either the NARGOUT for
%   the overloaded SUBSREF function or the NARGIN for the overloaded
%   SUBSASGN function, then NUMEL needs to be overloaded to return a
%   value of N that is consistent with the class's SUBSREF and SUBSASGN
%   functions. Otherwise, MATLAB will produce errors when calling the 
%   overloaded SUBSREF and SUBSASGN functions.  
%
%   See also SIZE, PROD, SUBSREF, SUBSASGN, NARGIN, NARGOUT.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $ $Date: 2009/09/03 05:19:04 $
%   Built-in function.

