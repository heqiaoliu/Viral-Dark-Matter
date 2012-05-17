function varargout = subsref( obj, S )
%SUBSREF Composite subsref method retrieves remote values
%   B = C(I) returns the entry of Composite C from lab I as a cell array
%   B = C([I1, I2, ...]) returns multiple entries as a cell array
%
%   B = C{I} returns a single entry
%   [B1, B2, ...] = C{[I1, I2, ...]} returns multiple entries
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:24 $

    if strcmp( S(1).type, '.' )
        error( 'distcomp:spmd:CompositeSubsref', ...
               'Dot reference not allowed for Composites' );
    end
    
    % composites do not support multiple levels of subscripting.
    if length( S ) ~= 1
        error( 'distcomp:spmd:CompositeSubsref', ...
               'Composite objects only support simple subscripting' );
    end
    
    % Error early in the case where the pool is closed
    if ~obj.isResourceSetOpen()
        error( 'distcomp:spmd:CompositeSubsref', ...
               ['Either the Composite has been saved and then loaded, or \n', ...
                'the matlabpool for that Composite has been closed'] );
    end

    switch S.type
      case '()'
        if nargout > 1
            error( 'distcomp:spmd:CompositeSubsref', ...
                   'Too many outputs (%d) requested for ''()'' indexing', nargout );
        end

        try
            % Defer to builtin indexing of the key vector
            keyHolderCell = obj.KeyVector( S.subs{:} );
            ret           = cell( size( keyHolderCell ) );
            
            % Check before actually making the remote call
            labs = iCheckValuesExist( obj, S.subs{:} );
            
            for ii=1:length( keyHolderCell )
                ret{ii} = obj.getValOrError( keyHolderCell{ii}, labs(ii) );
            end
            varargout{1}  = ret;
        catch E
            EE = MException( 'distcomp:spmd:CompositeSubsref', ...
                             'An invalid indexing request was made' );
            EE = addCause( EE, E );
            throw( EE );
        end
      case '{}'
        try
            % Defer to builtin indexing of the key vector
            keyHolderCell = cell( 1, nargout );
            varargout     = cell( 1, nargout );
            [keyHolderCell{1:nargout}] = obj.KeyVector{ S.subs{:} };

            % Check before actually making the remote call
            labs = iCheckValuesExist( obj, S.subs{:} );

            for ii=1:length( keyHolderCell )
                varargout{ii} = obj.getValOrError( keyHolderCell{ii}, labs(ii) );
            end
        catch E
            EE = MException( 'distcomp:spmd:CompositeSubsref', ...
                             'An invalid indexing request was made' );
            EE = addCause( EE, E );
            throw( EE );
        end

      otherwise
        % Never get here - '.' indexing already handled.
        error( 'distcomp:spmd:CompositeSubsref', ...
               'An unexpected Composite indexing request was made' );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCheckValuesExist - use Composite.exist to check before we attempt to
% retrieve things whether the values exist
function labsRequested = iCheckValuesExist( obj, varargin )
    allLabs       = 1:length( obj );
    labsRequested = allLabs( varargin{:} );

    % See if any labs don't have a value
    labsNoValue   = labsRequested( ~exist( obj, labsRequested ) );
    if ~isempty( labsNoValue )
        error( 'distcomp:spmd:CompositeSubsref', ...
               'The Composite has no value on the following lab(s): %s', ...
               sprintf( '%d ', labsNoValue ) );
    end
end
