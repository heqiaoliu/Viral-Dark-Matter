%Composite Construct a Composite object
%   C = Composite() creates a Composite object on the client using labs from
%   the matlabpool. The actual number of labs referred to by this Composite
%   object depends on the size of the matlabpool, and any pre-existing
%   Composite objects. Generally, Composite objects should be constructed
%   outside any SPMD block.
%
%   C = Composite(NLABS) creates a Composite on the parallel resource set
%   that matches the specified constraint.  NLABS must be a vector of length
%   1 or 2, containing integers or Inf.  If NLABS is of length 1, it
%   specifies the exact number of labs to use. If NLABS is of size 2, it
%   specifies the minimum and maximum number of labs to use. The actual
%   number of labs used is the maximum number of labs compatible with the
%   size of the matlabpool, and other existing Composite objects.  An error
%   is thrown if the constraints on the number of labs cannot be met.
%
%   A Composite object has one entry for each lab, initially each entry will
%   contain no data. Use either indexing or SPMD to define values for the
%   entries.
%
%   Example: 
%   % Create a Composite object with no defined entries
%   c = Composite();
%   for ii = 1:length( c )
%       % Set the entry for each lab to zero
%       c{ii} = 0;
%   end
%   
%   Composite methods:
%      EXIST    - Determine if the Composite entry on a given lab contains data
%      LENGTH   - Return how many entries a Composite has
%      SUBSREF  - Retrieve entries from labs
%      SUBSASGN - Set entries on labs
%
%   See also SPMD, MATLABPOOL

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $   $Date: 2009/07/18 15:50:33 $

classdef Composite < spmdlang.BaseRemote

    properties ( Access = private, Hidden, Transient )
        % Store the client-side value
        ClientValue = [];
        % Is the client-side value valid?
        ClientValueValid = false;
    end

    methods ( Access = public, Hidden )
        % NB - called from AbstractSpmdExecutor
        function obj = setClientValue( obj, clientVal )
            obj.ClientValue = clientVal;
            obj.ClientValueValid = true;
        end
    end

    methods ( Access = protected, Hidden )
        function obj = pPostKeySet( obj )
        % Use this to clear the client value if the keyvector is "full".
            gotKey = cellfun( @isempty, obj.KeyVector );
            if all( gotKey )
                obj.ClientValue = [];
                obj.ClientValueValid = false;
            end
        end
    end
    
    methods ( Access = public )

        % Public construction of a Composite is of the form:
        % Composite() or Composite( [numeric vector] )
        % Private construction is of the form
        % Composite( '<action>', args )
        % Currently, only valid action is 'empty' with no args.
        function obj = Composite( varargin )

        % Deal with args
            if nargin == 0
                action = 'public';
                labsC  = {};
            elseif nargin == 1 && isnumeric( varargin{1} )
                action = 'public';
                nlabsV = varargin{1};
                switch length( nlabsV )
                  case 1
                    labsC = {nlabsV};
                  case 2
                    labsC = {nlabsV(1), nlabsV(2)};
                  otherwise
                    error( 'distcomp:spmd:Composite', ...
                           ['The numlabs argument for Composite construction must be either\n', ...
                            'a scalar or a vector of length 2'] );
                end
            elseif ischar( varargin{1} )
                action = varargin{1};
            else
                error( 'distcomp:spmd:Composite', ...
                       'Unexpected arguments to Composite constructor' );
            end

            % Build via superclass constructor
            obj = obj@spmdlang.BaseRemote();

            % Perform any post-superclass-construction actions
            switch action
              case 'public'
                try
                    rs = spmdlang.ResourceSetMgr.chooseResourceSet( {}, labsC{:} );
                catch E
                    EE = MException( 'distcomp:spmd:Composite', ...
                                     'Failed to satisfy constraints for Composite construction' );
                    EE = addCause( EE, E );
                    throw( EE );
                end
                % Initialize with an empty cell array of keys - i.e. no lab-side information
                % at all.
                obj = obj.init( cell( 1, rs.numlabs ), ...
                                spmdlang.ResourceSetHolder( rs ), ...
                                @spmdlang.plainCompositeBuilder );
              case 'empty'
                % This is the case used by plainCompositeBuilder -
                % init will be called later.
              otherwise
                error( 'distcomp:spmd:Composite', ...
                       'Unexpected Composite construction action: %s', action );
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % disp and display

        function disp( obj )
            if isempty( obj.ResSetHolder )
                fprintf( 1, '    Invalid Composite\n' );
            elseif ~obj.isResourceSetOpen()
                fprintf( 1, '    Invalid Composite (the matlabpool in use has been closed)\n' );
            else
                keyCellOrEmpty = getRawKeyCell( obj );
                
                if obj.ClientValueValid
                    % Send a string for the workers to use if they don't have a value of their
                    % own.
                    clientStr = iGetOneDisplayStr( obj.ClientValue );
                else
                    clientStr = '';
                end
                
                dispStr = spmd_feval_fcn( @iGetDisplayStrs, {keyCellOrEmpty, clientStr}, ...
                                          obj.ResSetHolder.getResourceSet() );
                fprintf( 1, '%s', getValOrError( dispStr, dispStr.KeyVector{1} ) );
            end
        end

    end
    
    methods ( Access = public, Hidden )

        function packed = packForTransmission( obj )
        % Send the client value to SPMD - this method decorates the AbstractRemote
        % version by adding the client value if one is present.
            packed = packForTransmission@spmdlang.AbstractRemote( obj );
            if obj.ClientValueValid
                packed = packed.setClientValue( obj.ClientValue );
            end
        end
        
    end

    methods ( Access = private, Hidden, Sealed )
        
        % Ensure we don't use any remote operations inside a parfor() loop
        function errorIfRemoteOperationInProgress( obj )
            if obj.isResourceSetOpen()
                resSet = obj.ResSetHolder.getResourceSet();
                if ~resSet.canAccessLabs()
                    error( 'distcomp:spmd:InvalidCompositeAccess', ...
                           ['The Composite value cannot be accessed because \n', ...
                            'a remote operation is in progress.'] );
                end
            end
        end
        
        % Send data to the labs, update key vector.
        function obj = setValOrError( obj, labidx, value )
            % Always check that we're not in a parfor
            obj.errorIfRemoteOperationInProgress();
            if labidx >= 1 && labidx <= length( obj )
                
                % Actually send the data to the lab, and store the returned key.
                newKey = obj.ResSetHolder.getResourceSet().setOnLab( labidx, value );
                obj.KeyVector{labidx} = spmdlang.KeyHolder( newKey, labidx, obj.ResSetHolder );
            else
                error( 'distcomp:spmd:CompositeSetValue', ...
                       ['An invalid index (%d) was supplied when trying to set \n', ...
                        'a value of an Composite'], labidx );
            end
        end

        % Get data from a lab
        function val = getValOrError( obj, keyHolder, lab )
            gotClient = obj.ClientValueValid;
            
            % Always check that we're not in a parfor loop
            obj.errorIfRemoteOperationInProgress();

            if ~isempty( keyHolder )
                val = keyHolder.getFromLab();
            elseif gotClient
                val = obj.ClientValue;
            else
                error( 'distcomp:spmd:CompositeGetValue', ...
                       'The Composite has no value on the requested lab (lab %d)', lab );
            end
        end
    end

    
    methods ( Access = public )

        % No need to doc "end", so keep it in here.
        function idx = end( obj, k, n )
            idx = builtin( 'end', obj.KeyVector, k, n );
        end
    end        

end

function oneStr = iGetOneDisplayStr( value )
    oneStr = sprintf( 'class = %s, size = [%s]', ...
                      class( value ), num2str( size( value ) ) );
end

% Internal function used by disp
function labStr = iGetDisplayStrs( keyCell, clientStr )
    
% Mimic the SPMD output format - to do this effectively, we need the
% labindex formatted to the correct width
    requiredDigits = 1 + floor( log10( numlabs ) );
    formatStr = sprintf( 'Lab %%%dd: ', requiredDigits );
    labIdxStr = sprintf( formatStr, labindex );
    
    if ~isempty( keyCell{ labindex } )
        data = spmdlang.ValueStore.retrieve( keyCell{labindex} );
        labStr = sprintf( '   %s%s', labIdxStr, iGetOneDisplayStr( data ) );
    else
        if ~isempty( clientStr )
            labStr = sprintf( '   %s%s', labIdxStr, clientStr );
        else
            labStr = sprintf( '   %sNo data', labIdxStr );
        end
    end
    labStrCell = gcat( {labStr}, 1 );
    if labindex == 1
        labStr = sprintf( '%s\n', labStrCell{:} );
    end
end
