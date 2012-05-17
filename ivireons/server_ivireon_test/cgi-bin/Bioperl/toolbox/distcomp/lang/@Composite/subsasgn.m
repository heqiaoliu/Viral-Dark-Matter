function obj = subsasgn( obj, S, value )
%SUBSASGN Composite subsasgn method assigns remote values
%   C(I) = {B} sets the entry of C on lab I to the value B 
%   C(1:end) = {B} sets all entries of C to the value B
%   C([I1, I2]) = {B1, B2} assigns different values on labs I1 and I2
%   
%   C{I} = B sets the entry of C on lab I to the value B
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2008/08/26 18:13:55 $

    if isempty( obj )
        % First check - ensure we're not doing something like x(3) = C where x
        % doesn't currently exist
        error( 'distcomp:spmd:CompositeSubsasgn', ...
               'You cannot create an array by indexed assignment from a Composite object' );
    end
    
    if strcmp( S(1).type, '.' )
        error( 'distcomp:spmd:CompositeSubsasgn', ...
               'Dot reference not allowed for Composites' );
    end
    
    % Composites do not support multiple levels of subscripting.
    if length( S ) ~= 1
        error( 'distcomp:spmd:CompositeSubsasgn', ...
               'Composite objects only support simple subscripting' );
    end

    % Error early in the case where the pool is closed
    if ~obj.isResourceSetOpen()
        error( 'distcomp:spmd:CompositeSubsasgn', ...
               ['Either the Composite has been saved and then loaded, or \n', ...
                'the matlabpool for that Composite has been closed'] );
    end

    switch S.type
      case '()'
        % In this case, RHS must be either 1-element cell, or cell of the right
        % length to match the indices
        
        if ~iscell( value )
            error( 'distcomp:spmd:CompositeSubsasgn', ...
                   'In Composite () assignments, the right-hand side value must be a cell' );
        end
        
        % Handle the [obj(:)] = {1} case - in this case, S.subs is {':'}
        labidxs = S.subs{1};
        if ischar( labidxs ) 
            if length( labidxs ) == 1 && isequal( labidxs, ':' )
                labidxs = 1:length( obj.KeyVector );
            else
                error( 'distcomp:spmd:CompositeSubsasgn', ...
                       'Unhandled index expresion: %s', labidxs );
            end
        end
        
        % Convert logicals to indices
        if islogical( labidxs )
            allIdxs = 1:length( obj );
            labidxs = allIdxs( labidxs );
        end

        % Check that we know the type of what we're dealing with
        if ~isnumeric( labidxs )
            error( 'distcomp:spmd:CompositeSubsasgn', ...
                   'Unhandled indexing datatype: %s', class( labidxs ) );
        end
        
        gotCorrectNumValues = ( length( value ) == length( labidxs ) || ...
                                length( value ) == 1 );
        
        if gotCorrectNumValues
            try
                if length( value ) == length( labidxs )
                    for ii=1:length( labidxs )
                        obj = setValOrError( obj, labidxs(ii), value{ii} );
                    end
                elseif length( value ) == 1
                    for ii=1:length( labidxs )
                        obj = setValOrError( obj, labidxs(ii), value{1} );
                    end
                else
                    error( 'distcomp:spmd:CompositeSubsasgn', ...
                           'An unexpected indexing request was made' );
                end
            catch E
                EE = MException( 'distcomp:spmd:CompositeSubsasgn', ...
                                 'An invalid indexing request was made' );
                EE = addCause( EE, E );
                throw( EE );
            end
        else
            % mismatch
            error( 'distcomp:spmd:CompositeSubsasgn', ...
                   ['The number of values provided (%d) does not match the number of\n', ...
                    'assignments to be made (%d)'], length( value ), length( labidxs ) );
        end
        
      case '{}'
        % Apply the change
        % Note - because we cannot support [x{:}] = deal( ... ), we know that labidx is scalar.
        try
            labidx = S.subs{1};
            obj = setValOrError( obj, labidx, value );
        catch E
            EE = MException( 'distcomp:spmd:CompositeSubsasgn', ...
                             'An invalid indexing request was made' );
            EE = addCause( EE, E );
            throw( EE );
        end
      otherwise
        % Never get here - '.' indexing already handled.
        error( 'distcomp:spmd:CompositeSubasgn', ...
               'An unexpected indexing request was made' );
    end
end
