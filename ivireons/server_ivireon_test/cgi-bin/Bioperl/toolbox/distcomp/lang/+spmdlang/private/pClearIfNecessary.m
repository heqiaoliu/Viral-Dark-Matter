function pClearIfNecessary( arrayHolderToClear )
%pClearIfNecessary - if we've been given some keys to clear, deal with them

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:24 $
    
    if ~isempty( arrayHolderToClear )
        % Clear any remote keys first before we attempt anything else.
        try
            spmdlang.ValueStore.remove( arrayHolderToClear.array() );
        catch E
            % Simply warn.
            warning( 'distcomp:spmd:RemoteClear', ...
                     'An error occurred during remote clearing: %s', ...
                     getReport( E ) );
        end
    end
end

