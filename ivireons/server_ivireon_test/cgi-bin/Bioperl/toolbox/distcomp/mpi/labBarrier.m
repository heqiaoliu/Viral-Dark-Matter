%labBarrier - block until all labs have entered the barrier
%   labBarrier blocks execution of a parallel algorithm until all labs have
%   reached the call to labBarrier. This is useful for co-ordinating access to
%   shared resources such as file I/O.
%
%   Example:
%   % All labs know the shared data file name
%   fname = 'c:\data\datafile.mat';
%   % Lab 1 writes some data to a file, which all other labs will read
%   if labindex == 1
%       data = randn( 100, 1 );
%       save( fname, 'data' );
%   end
%   % Labs wait until all have reached the barrier - this ensures that
%   % no lab attempts to load the file until it has been written
%   labBarrier;
%   load( fname );
%
%   See also labBroadcast, labSend, labReceive.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2009/09/23 13:59:22 $
