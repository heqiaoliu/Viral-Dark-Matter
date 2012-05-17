function D = nan( varargin )
%DISTRIBUTED.NAN Build distributed array containing Not-a-Number
%   D = DISTRIBUTED.NAN(N) is an N-by-N distributed matrix of NANs.
%   
%   D = DISTRIBUTED.NAN(M,N) is an M-by-N distributed matrix of NANs.
%   
%   D = DISTRIBUTED.NAN(M,N,P,...) or DISTRIBUTED.NAN([M,N,P,...])
%   is an M-by-N-by-P-by-... distributed array of NANs.
%   
%   D = DISTRIBUTED.NAN(M,N,P,..., CLASSNAME) or 
%   DISTRIBUTED.NAN([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   distributed array of NANs of class specified by CLASSNAME.  CLASSNAME
%   must be either 'single' or 'double'.
%   
%   As shown in the example, all forms of the built-in function have been 
%   overloaded for distributed arrays.
%   
%   Example:
%       N = 1000;
%       % Create a 1000-by-1 distributed array of underlying class 'single'
%       % containing the value NaN.
%       D1 = distributed.nan(N, 1,'single')
%       D2 = distributed.NaN(1, N)
%   
%   See also NAN, DISTRIBUTED, DISTRIBUTED/ZEROS, DISTRIBUTED/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:51 $

% static method of distributed

D = distributed.sBuild( @codistributed.nan, 'nan', varargin{:} );
end
