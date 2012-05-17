function varargout = spmd_feval_fcn( fcnH, argsInCell, varargin )
%SPMD_FEVAL_FCN - functional equivalent to an SPMD block
% [argsout] = SPMD_FEVAL_FCN( @fcn, {args, args, ...}, spmd_args, ... )
% Incomplete Compositess are not acceptable here.
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:00 $

    % Arg checking
    error( nargchk( 1, Inf, nargin, 'struct' ) );
    if nargin == 1
        argsInCell = {};
    end
    
    if ~isa( fcnH, 'function_handle' )
        error( 'distcomp:spmd:NeedFcnHandle', ...
               'The first argument to %s must be a function handle', mfilename );
    end

    if ~( iscell( argsInCell ) || isempty( argsInCell ) )
        error( 'distcomp:spmd:NeedCell', ...
               'The second argument to %s must be a cell array of input arguments', ...
               mfilename );
    end
    
    % Check for fullness of Composites
    for qq=1:length( argsInCell )
        if isa( argsInCell{qq}, 'Composite' )
            if ~all( exist( argsInCell{qq} ) ) %#ok<EXIST> - this is a different "exist"
                error( 'distcomp:spmd:IncompleteComposite', ...
                       '%s requires that all input Composites exist everywhere', ...
                       mfilename );
            end
        end
    end
    
    % Set up the assign_outputs closure that will be called to populate the
    % return arguments from this function.
    nout      = nargout;
    varargout = cell( 1, nout );
    function assign_outputs( varargin )
        for ii=1:nout
            if ~isempty( varargin{ii} )
                varargout{ii} = varargin{ii}{1};
            end
        end
    end

    % In this case, we don't need an spmd_body closure; simply call things
    % directly.

    % Pack the inputs for transmission
    for qq=1:length( argsInCell )
        argsInCell{qq} = {spmdlang.packBlockInput( argsInCell{qq} )};
    end
    
    % Set up the initial values of the outputs - in this case, we have no
    % initial output values.
    initial_outputs = cell( 1, nout );
    
    % Build the related lab-side closures for execution
    [f, get_out, unpack_in] = get_f( fcnH, argsInCell, nout );
    
    % Execute the block remotely
    spmdlang.spmd_feval_impl( f, @assign_outputs, get_out, unpack_in, initial_outputs, argsInCell, varargin{:} );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bodyF, getOutF, unpackInF] = get_f( fcnH, argsInCell, nout )
    
    outCell = cell( 1, nout );
    inCell  = cell( 1, length( argsInCell ) );
    
    function unpack_inputs( resolveF )
        for ii=1:length( argsInCell )
            inCell{ii} = resolveF( argsInCell{ii}{1} );
        end
    end
    
    function body()
        if nout == 0
            fcnH( inCell{:} );
        else
            [outCell{:}] = fcnH( inCell{:} );
        end
    end
    
    function o = get_outputs()
        o = cell( 1, length( outCell ) );
        for ii=1:length( outCell )
            o{ii} = {outCell{ii}};
        end
    end
    
    bodyF     = @body;
    getOutF   = @get_outputs;
    unpackInF = @unpack_inputs;
end
    
