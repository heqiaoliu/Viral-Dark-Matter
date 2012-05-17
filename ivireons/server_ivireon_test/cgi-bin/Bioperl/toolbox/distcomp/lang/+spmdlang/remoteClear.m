function [OK, serError] = remoteClear( arrayHolder )
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:21 $

    try
        spmdlang.ValueStore.remove( arrayHolder.array() );
        OK       = true;
        serError = [];
    catch E
        OK       = false;
        serError = distcompserialize( E );
    end
end
