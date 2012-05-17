% The ValueStore is a simple key-value container for worker-side storage of
% Remote object contents.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/09/13 06:51:48 $

classdef ValueStore
    methods ( Static, Access = public, Hidden )

        % Store a value, get back a key
        function key = store( value )
            map = iMap();
            key = iNextKey();
            map( key ) = value; %#ok<NASGU> incorrect analysis - "map" is a handle
        end
        
        % Retrieve a value by the key
        function value = retrieve( key )
            iAssertKeyClass( key );
            map = iMap();
            value = map( key );
        end
        
        % Remove values corresponding to a vector of keys
        function remove( kys )
            iAssertKeyClass( kys );
            map = iMap();
            kys = kys(:);
            % NB - quicker to do this than converting to a cell of keys
            for ii=1:length( kys )
                remove( map, kys(ii) );
            end
        end
        
        % Remove all values
        function clear()
            map = iMap();
            remove( map, keys( map ) );
        end
        
        % Debug - return all keys as a vector of int64.
        function kys = allKeys()
            map = iMap();
            kys = keys( map );
            kys = [kys{:}];
        end
    end
end

function iAssertKeyClass( k )
    if ~isa( k, 'int64' )
        error( 'distcomp:spmdlang:ValueStoreKeyClass', ...
               'Invalid key class - expected int64, got: "%s"', class( k ) );
    end
end

function k = iNextKey()
% Return a new key for use in the map.
    persistent KEY
    if isempty( KEY )
        % Start at a large offset, as per pctValueStore.
        KEY = int64(2^24);
    end
    
    k = int64( double( KEY ) + 1 );
    if k == KEY
        % Get here at around 2^53 due to limitations of using doubles for 64-bit
        % arithmetic.
        k = 0;
    end
    KEY = k;
end

function map = iMap()
% Return the singleton map object
    persistent THE_MAP
    mlock

    if isempty( THE_MAP )
        % Construct the map, force the datatypes to be correct
        dummyKey = iNextKey();
        THE_MAP = containers.Map( dummyKey, 1, 'uniformValues', false );
        THE_MAP.remove( dummyKey );
    end
    map = THE_MAP;
end
