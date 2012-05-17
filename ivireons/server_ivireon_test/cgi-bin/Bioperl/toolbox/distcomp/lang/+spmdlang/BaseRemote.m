% Common behaviour between Remote subclasses to do with illegal
% methods. This class stores no properties, it simply deals with cat/horzcat
% etc. It also tracks saves/loads so that other pieces of the infrastructure
% can handle that (e.g. detecting illegal Composite transfers)

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/03/25 21:54:42 $

classdef BaseRemote < spmdlang.AbstractRemote

    methods ( Access = private, Hidden, Static )
        function iNotSupported( methodName )
            error( 'distcomp:spmd:MethodNotSupported', ....
                   '"%s" is not supported for Composite objects', ....
                   methodName );
        end
    end

    methods ( Access = public, Static, Sealed, Hidden )

        function varargout = empty( varargin ) %#ok<STOUT> - errors
        % We aim not to support remote arrays of remote objects
            spmdlang.BaseRemote.iNotSupported( 'empty' );
        end
        
        function obj = loadobj( obj )
        % Don't warn - the user was already warned at save time.
            spmdlang.BaseRemote.saveLoadCount( 'increment' );
        end
    end
    
    methods ( Access = public, Sealed, Hidden )
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Illegal methods, hidden so people don't think they can use them.
         function x = cat( obj, varargin )     %#ok<STOUT,MANU>
             spmdlang.BaseRemote.iNotSupported( 'cat' );
         end
         function x = horzcat( obj, varargin ) %#ok<STOUT,MANU>
             spmdlang.BaseRemote.iNotSupported( 'horzcat' );
         end
         function x = vertcat( obj, varargin ) %#ok<STOUT,MANU>
             spmdlang.BaseRemote.iNotSupported( 'vertcat' );
         end
         function obj = saveobj( obj, varargin )
             spmdlang.BaseRemote.saveLoadCount( 'increment' );
             warning( 'distcomp:spmd:CompositeSave', ...
                      'Saving Composites is not supported' );
         end
     end
    
    methods ( Access = public )
        function obj = BaseRemote()
            obj = obj@spmdlang.AbstractRemote();
        end

        % display simply defers to "disp" to do most of the work.
        function display( obj )
            if isequal(get(0,'FormatSpacing'),'compact')
                disp([inputname(1) ' =']);
                disp( obj )
            else
                disp(' ')
                disp([inputname(1) ' =']);
                disp(' ');
                disp( obj )
                disp(' ');
            end
        end

    end
end
