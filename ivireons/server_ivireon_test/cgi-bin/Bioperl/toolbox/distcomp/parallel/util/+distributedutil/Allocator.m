%Allocator Collection of utility functions that allocate and initialize arrays.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/10/12 17:28:18 $

classdef Allocator

    methods ( Access = public, Static )
        function arr = create(sz, template)
        %arr = create(sz, template) Returns an array of size sz that has the same
        %attributes as template.
        %
        %See also: supportsCreation.
            
            arr = iCreateShared( sz, template, 'data' );
        end % End of firstNonSingletonDimension.
        
        function d = createCodistributed(sz, template)
        %d = createCodistributed( globalSize, template ) returns a codistributed
        %array of global size globalSize that has the same attributes as template.
        %
        %See also: supportsCreation.
            d = iCreateShared( sz, template, 'codistributed' );
        end
        
        function tmpl = extractTemplate( dOrCoDOrX )
        % Return a template from an array, codistributed, or distributed.
            switch class( dOrCoDOrX )
              case {'distributed', 'codistributed'}
                tmplCls = classUnderlying( dOrCoDOrX );
              otherwise
                tmplCls = class( dOrCoDOrX );
            end
            switch tmplCls
              case { 'double', 'single', ...
                     'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', ...
                     'int64', 'uint64' }
                tmpl = zeros( 1, 1, tmplCls );
              case 'logical'
                tmpl = false;
              case 'char'
                tmpl = '0';
              case 'cell'
                tmpl = cell( 1, 1 );
              case 'struct'
                fn = fieldnames( dOrCoDOrX );
                % Ensure fn is a row:
                fn = transpose( fn(:) );
                fieldsAndValsForCtor = [ fn; cell( size( fn ) ) ];
                tmpl = struct( fieldsAndValsForCtor{:} );
              otherwise
                error( 'distcomp:codistributed:Allocator:unsupportedClass', ...
                      ['Distributed arrays are only supported for LOGICAL, ',...
                       'CHAR, NUMERIC, CELL and STRUCT.'])
            end
            % Ensure tmpl is complex if necessary. We know if numeric, it is guaranteed
            % real and full at this point (because we just made it); but we
            % must call "complex" before "sparse" as "complex" only accepts
            % "full" inputs. Note that "isreal" returns false for
            % non-numeric, so we must also defend against that.
            if isnumeric( tmpl ) && ~isreal( dOrCoDOrX )
                tmpl = complex( tmpl, tmpl );
            end
            % Fix sparsity after complexity
            if issparse( dOrCoDOrX )
                tmpl = sparse( tmpl );
            end
        end
        
        function tf = supportsCreation(template)
        % tf = supportsCreation(template) Returns true if and only if we support the
        % creation of an array based on this template in the create method.
        %
        %See also: create.
            
        % Short-circuit for some known-bad types. 
            if isa(template, 'function_handle') || ...
                    isa(template, 'distributed') || ...
                    isa(template, 'codistributed')
                tf = false;
                return;
            end
            tf = issparse(template) ...
                 || islogical(template) ...
                 || ischar(template) ...
                 || isnumeric(template) ...
                 || iscell(template) ...
                 || isstruct(template);
        end
    end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create normal data or a codistributed array. template must be
% non-distributed data. type must be 'data' or 'codistributed'.
function xOrCod = iCreateShared( sz, template, type )
    sz = distributedutil.Sizes.removeTrailingOnes(sz);
    
    if isa(template,'function_handle')
        error('distcomp:codistributed:Allocator:noFunctionHandle',...
              'Arrays of function handles are not supported.');
    end

    % Currently, only handle two types - data and codistributed.
    if strcmp( type, 'data' )
        sparseCtor  = @sparse;
        logicalCtor = @false;
        zerosCtor   = @zeros;
        cellCtor    = @cell;
        structCtor  = @struct;
    elseif strcmp( type, 'codistributed' )
        sparseCtor  = @(m, n) codistributed.spalloc( m, n, 0 );
        logicalCtor = @codistributed.false;
        zerosCtor   = @codistributed.zeros;
        cellCtor    = @codistributed.cell;
        structCtor  = @(varargin) codistributed( struct( varargin{:} ) );
    else
        error( 'distcomp:codistributed:Allocator:badType', ...
               'Unhandle creation type: %s in Allocator', type );
    end
        
    if issparse(template)
        if length(sz) > 2
            error('distcomp:codistributed:Allocator:unsupportedSparseNdims', ...
                  ['Cannot create sparse %d-D array.  Only sparse ' ...
                   'vectors and matrices are supported.'], length(sz));
        end
        xOrCod = sparseCtor( sz(1), sz(2) );
        if islogical(template)
            % Complete the creation of a sparse, logical array.
            xOrCod = logical( xOrCod ); 
        end
    elseif islogical(template)
        xOrCod = logicalCtor( sz );
    elseif ischar(template)
        xOrCod = char(zerosCtor(sz, 'uint16'));
    elseif isnumeric(template)
        xOrCod = zerosCtor(sz, class(template));
    elseif iscell(template)
        xOrCod = cellCtor(sz);
    elseif isstruct(template)
        % NB this is slightly inefficient - replicated construction of the cell
        % array. Assumption is that for codistributed structs, it's the
        % contents of the fields that ought to be large.
        % When codistributed/struct exists, this could be efficient.
        fldnms         = fieldnames(template)';
        fldAndVal      = [fldnms; cell( size( fldnms ) )];
        fldAndVal{2,1} = cell( sz );
        xOrCod         = structCtor(fldAndVal{:});
    else
        error('distcomp:codistributed:Allocator:unsupportedClass', ...
              ['Distributed arrays are only supported for LOGICAL, ',...
               'CHAR, NUMERIC, CELL and STRUCT.'])
    end

end
