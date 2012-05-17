function out = labBroadcast( root, in_data )
%labBroadcast - send data to all labs
%   out_data = labBroadcast( root, in_data ) sends the specified
%   in_data to all executing labs. The data is broadcast from the lab
%   with labindex==root, and received by all other labs. If
%   labindex~=root, then the input data argument is ignored.  The
%   output data "out_data" is identical on all labs.
%
%   out_data = labBroadcast( root ) receives the broadcast data
%   from the lab with labindex==root. This syntax is only valid for
%   labs with labindex~=root.
%
%   This function blocks until the lab's involvement in the collective
%   broadcast operation is complete. Some labs may complete a call to
%   labBroadcast before others have started. Use labBarrier to guarantee 
%   that all labs are at the same point in a program.
%
%   Example:
%   % everyone agrees that the broadcaster is the lab with labindex==1
%   broadcast_id = 1;
%   if labindex == broadcast_id
%     data_in = randn( 10 );
%     data_out = labBroadcast( broadcast_id, data_in );
%   else
%     data_out = labBroadcast( broadcast_id );
%   end
%
%   See also labBarrier, labSend.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2009/09/23 13:59:23 $

% argcheck
if root == labindex
    error( nargchk( 2, 2, nargin, 'struct' ) );
    out = in_data;
else
    error( nargchk( 1, 2, nargin, 'struct' ) );
    out = [];
end

if root ~= round( root ) || ...
           root < 1 || ...
           root > numlabs
    error( 'distcomp:labBroadcast:invalidroot', ...
           'Broadcast root must be an integer between 1 and numlabs' );
end

% Calculate the modified index list for broadcast
idxs = 1:numlabs;
idxs(1) = root; idxs(root) = 1;

% Tree depth
d = 2.^( floor( log2( numlabs ) ) );

% Swap the broadcast root with lab 1 to make the tree calculation simpler.
mytreeidx = idxs( labindex );

while d >= 1
    if mod( mytreeidx-1, 2*d ) == 0 && mytreeidx+d <= numlabs
        labSend( out, idxs( mytreeidx + d ), 400003 );
    elseif mod( mytreeidx-1, 2*d ) == d
        out = labReceive( idxs( mytreeidx - d ), 400003 );
    end
    d = d/2;
end
