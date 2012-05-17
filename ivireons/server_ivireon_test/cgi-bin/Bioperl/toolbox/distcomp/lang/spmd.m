%SPMD Single Program Multiple Data 
%   The general form of an SPMD statement is:
%
%   SPMD
%       <statements>
%   END
%
%   MATLAB executes the code within the SPMD body denoted by STATEMENTS on
%   several MATLAB workers simultaneously.  In order to execute the
%   STATEMENTS in parallel, you must first open a pool of MATLAB workers
%   using MATLABPOOL. SPMD can only be used if you have Parallel Computing
%   Toolbox.
%
%   Variables assigned in the body of SPMD will be available for use as
%   Composite objects outside the SPMD block on the MATLAB client. A
%   Composite object can be used to retrieve the values stored on the remote
%   MATLAB workers.  The actual data remains available on the workers for
%   subsequent SPMD statements, so long as the Composite exists on the
%   MATLAB client and the MATLABPOOL remains open.
%
%   SPMD( N ), <statements>, END uses N to specify the exact number of
%   MATLAB workers that will evaluate STATEMENTS in the body, provided that
%   the requested number of workers are available from the MATLABPOOL.  By
%   default, MATLAB uses as many workers as it finds available.  When there
%   are no MATLAB workers available, or N is zero, MATLAB will execute the
%   body locally.  When SPMD executes locally, assigned variables within
%   SPMD are still converted to Composites for use outside SPMD.
%
%   SPMD( M, N ), <statements>, END uses a minimum of M and maximum of N
%   workers to evaluate STATEMENTS.
%
%   EXAMPLE
%
%   Perform a simple calculation in parallel, and plot the results
%
%   matlabpool(3)
%   spmd
%     % build magic squares in parallel
%     q = magic( labindex + 2 );
%   end
%   for ii=1:length( q )
%     % plot each magic square
%     figure, imagesc( q{ii} );
%   end
%   spmd
%     % modify variable on workers
%     q = q*2;
%   end
%   % Access data on a specific worker
%   figure, imagesc(q{2});
% 
%   See also matlabpool, Composite

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.10.1 $   $Date: 2008/08/26 18:13:52 $
% Built-in function.
