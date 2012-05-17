% Parallel Algorithms
%
% Distributed Array Functions
%   distributed/cell     - CELL function for creating distributed arrays
%   distributed/colon    - COLON function for creating distributed arrays
%   distributed/eye      - EYE function for creating distributed arrays
%   distributed/false    - FALSE function for creating distributed arrays
%   distributed/inf      - INF function for creating distributed arrays
%   distributed/nan      - NAN function for creating distributed arrays
%   distributed/ones     - ONES function for creating distributed arrays
%   distributed/rand     - RAND function for creating distributed arrays
%   distributed/randn    - RANDN function for creating distributed arrays
%   distributed/spalloc  - SPALLOC function for creating distributed arrays
%   distributed/sparse   - SPARSE function for creating distributed arrays
%   distributed/speye    - SPEYE function for creating distributed arrays
%   distributed/sprand   - SPRAND function for creating distributed arrays
%   distributed/sprandn  - SPRANDN function for creating distributed arrays
%   distributed/true     - TRUE function for creating distributed arrays
%   distributed/zeros    - ZEROS function for creating distributed arrays
%
%   dload                - Load distributed arrays and composite objects
%                          from disk
%   dsave                - Save workspace distributed arrays and composite 
%                          objects to disk
%
% Codistributed Array Functions
%   codistributed               - Create a codistributed array from replicated 
%                                 data
%   codistributed/build         - Create a codistributed array from local parts
%                                 that can be different on each lab
%   codistributed/gather        - Convert a codistributed array into a 
%                                 replicated or variant array
%   codistributed/getLocalPart  - Local portion of a codistributed array
%   codistributed/globalIndices - Global indices of local part of a 
%                                 codistributed array
%   codistributed/redistribute  - Redistribute a codistributed array with 
%                                 another codistributor
%
%   codistributor1d                  - Distribution scheme that partitions 
%                                      array in a single specified dimension
%   codistributor1d/Dimension        - Distributed dimension of codistributor
%   codistributor1d/Partition        - Partition of a 1d codistributor
%   codistributor1d/defaultPartition - Default partition in 1d for a 
%                                      codistributed array
%
% General Parallel Functions
%   gop                         - Apply a global operation across all labs
%   gcat                        - Apply global concatenation across all labs
%   gplus                       - Apply global addition across all labs
%
%   spmd                        - Single Program Multiple Data block allows 
%                                 more control over distributed arrays by 
%                                 providing access to them as codistributed 
%                                 arrays within the block  
%   labindex                    - Return the ID for this lab
%   numlabs                     - Return the number of labs operating in 
%                                 parallel
%
% Parallel Communication Functions
%   labSend                  - Send data to another lab
%   labReceive               - Receive data from another lab
%   labSendReceive           - Simultaneously send to and receive from other 
%                              labs
%   labBroadcast             - Send data to all labs
%   labBarrier               - Block until all labs have entered the barrier
%   labProbe                 - Test to see if messages are ready to labReceive
%   mpiLibConf               - Location of MPI implementation
%   mpiSettings              - Set various options for MPI communication
%
% See also DISTCOMP, DISTRIBUTED, SPMD, CODISTRIBUTED, CODISTRIBUTOR1D.

% Copyright 2004-2010 The MathWorks, Inc. 
% Generated from Contents.m_template revision 1.1.6.6  $Date: 2009/12/03 19:00:21 $
