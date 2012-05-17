function [OK, serVal] = remoteRetrieval( key, arrayHolderToClear )
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:22 $
    
    pClearIfNecessary( arrayHolderToClear );

    try
        serVal = distcompMakeByteBufferHandle( distcompserialize( ...
            spmdlang.ValueStore.retrieve( distcompdeserialize( key ) ) ) );
        OK     = true;
    catch E
        serVal = distcompMakeByteBufferHandle( distcompserialize( E ) );
        OK     = false;
    end
end
