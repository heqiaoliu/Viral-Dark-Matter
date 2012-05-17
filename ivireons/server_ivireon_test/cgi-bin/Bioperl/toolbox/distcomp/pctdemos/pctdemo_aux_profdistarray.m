function pctdemo_aux_profdistarray
%PCTDEMO_AUX_PROFDISTARRAY Use codistributed arrays to perform parallel computations.
%   This function creates imbalanced codistributed arrays and performs
%   computations on them.  This is done only for instructional purposes, so
%   that the resulting profiling information can be viewed in the parallel
%   profiler.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/25 21:57:17 $

n = floor(sqrt(512*512*numlabs)); % Make a suitably large codistributed array
part = codistributor1d.defaultPartition(n);
% Intentionally change the partition to be uneven.
if numlabs > 1
    part(end) = part(end) + part(1) - 1;
    part(1) = 1;
end
% Prepare for creating an n-by-n codistributed array distributed across the 
% 2nd dimension, and using the uneven partition.
codistr = codistributor1d(2, part, [n, n]);
D = codistributed.rand(n, n, codistr);
fprintf(['This lab has %d rows and %d columns ' ...
         'of a codistributed array\n'], n, part(labindex));
% Perform an operation which requires communication - mtimes
fprintf( 'Calling mtimes on codistributed arrays\n' );
D1 = D * D * D; 
% Barrier to synchronize start of elementwise embarrassingly parallel functions
labBarrier;
% Perform some operations on the load-imbalanced matrix
fprintf( ['Calling embarrassingly parallel math functions '...
    '(i.e. no communication is required)\non a codistributed array.\n'] );

for ii=1:50
    D2 = sqrt( sin( D .* D ) );
end
fprintf( 'Done\n' );
