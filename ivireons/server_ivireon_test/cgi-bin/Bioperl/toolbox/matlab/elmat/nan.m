%NaN    Not-a-Number.
%   NaN is the IEEE arithmetic representation for Not-a-Number.
%   A NaN is obtained as a result of mathematically undefined
%   operations like 0.0/0.0  and inf-inf.
%
%   NaN('double') is the same as NaN with no inputs.
%
%   NaN('single') is the single precision representation of NaN.
%
%   NaN(N) is an N-by-N matrix of NaNs.
%
%   NaN(M,N) or NaN([M,N]) is an M-by-N matrix of NaNs.
%
%   NaN(M,N,P,...) or NaN([M,N,P,...]) is an M-by-N-by-P-by-... array of NaNs.
%
%   NaN(...,CLASSNAME) is an array of NaNs of class specified by CLASSNAME.
%   CLASSNAME must be either 'single' or 'double'.
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   See also INF, ISNAN, ISFINITE, ISFLOAT.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.7.4.5 $  $Date: 2005/04/28 19:54:04 $
%   Built-in function.

