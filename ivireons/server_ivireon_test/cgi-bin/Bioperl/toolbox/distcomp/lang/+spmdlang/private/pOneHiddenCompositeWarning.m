function pOneHiddenCompositeWarning
%pOneHiddenCompositeWarning - warn once about "hidden" Composites

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/07/14 03:53:26 $

persistent DONE

mlock;

if isempty( DONE )
    DONE = true;
    turnOffWarning = true;
    warnAppend = sprintf( ['\nThis warning will now be disabled, but can be re-enabled by executing \n', ...
                        'warning on distcomp:spmd:RemoteTransfer'] );
else
    turnOffWarning = false;
    warnAppend = '';
end

warning( 'distcomp:spmd:RemoteTransfer', ...
         ['A distributed array or Composite was used in the body of an SPMD block without ', ...
          'appearing directly in the body of the block. This can happen ', ...
          'if a distributed array or Composite is stored inside a container such as a cell array ', ...
          'or structure. Distributed arrays or Composites stored like this will be unusable inside ', ...
          'the body of the SPMD block.%s'], warnAppend );

if turnOffWarning
    warning( 'off', 'distcomp:spmd:RemoteTransfer' );
end

end
