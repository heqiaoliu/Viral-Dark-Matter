function [comm, labidxOfFirst] = commForWorld( action, comm, labidxOfFirst )
% commForWorld - SPMD helper function
% Stash the vector of communicators to be used by a world ResourceSet.  In
% the case of a matlabpool job, this differs from the 'world' communicator
% as understood by mpiCommManip because it only involves 'world' labs
% 2:numlabs. Also, we store the 'world' labindex offset here. This
% information is used to build remote parallel resource sets.
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:15 $
    
    persistent WORLDCOMM LABIDXFIRST
    if isempty( WORLDCOMM )
        WORLDCOMM = 'world';
        LABIDXFIRST = 1;
        mlock;
    end
    
    switch action
      case 'get'
        comm = WORLDCOMM;
        labidxOfFirst = LABIDXFIRST;
      case 'set'
        WORLDCOMM = comm;
        LABIDXFIRST = labidxOfFirst;
    end
end
