function [OK, serKey] = remoteStore( serVal, arrayHolderToClear )

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:23 $

    pClearIfNecessary( arrayHolderToClear );

    try
        deserVal = distcompdeserialize( distcompByteBuffer2MxArray( serVal.get ) );
        serVal.free;
        serKey   = distcompMakeByteBufferHandle( distcompserialize( spmdlang.ValueStore.store( deserVal ) ) );
        OK       = true;
    catch E
        OK       = false;
        serKey   = distcompMakeByteBufferHandle( distcompserialize( E ) );
    end
end
