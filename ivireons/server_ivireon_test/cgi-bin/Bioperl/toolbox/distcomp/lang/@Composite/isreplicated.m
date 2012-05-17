function tf = isreplicated( C )
%ISREPLICATED Check whether Composite data is replicated on labs
%   TF = ISREPLICATED( C ) returns true if the entries in Composite C have
%   defined values on all labs, and those values are identical.
%
%   Example:
%   spmd
%     c1 = labindex + 1;
%     c2 = ones( 1, numlabs );
%     if labindex > 1
%       c3 = 1;
%     end
%   end
%   % providing the available MATLABPOOL size is > 1
%   isreplicated( c1 ) % false - different values
%   isreplicated( c2 ) % true  - same value everywhere
%   isreplicated( c3 ) % false - not defined on all labs
%
%   See also COMPOSITE, ISREPLICATED

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/03/25 21:54:51 $

if all( exist( C ) ) %#ok<EXIST> Composite.exist()
    tf = spmd_feval_fcn( @iIsReplicated, {C} );
    tf = tf.Value;
else
    tf = false;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tfAuto = iIsReplicated( C )
tfAuto = distributedutil.AutoTransfer( isreplicated( C ) );
end
