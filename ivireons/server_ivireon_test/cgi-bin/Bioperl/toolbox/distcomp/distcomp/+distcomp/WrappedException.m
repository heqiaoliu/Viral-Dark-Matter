classdef WrappedException < MException

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:41:07 $
    
    properties ( SetAccess = protected )
        CauseException;
    end

    methods ( Access = public )
        function obj = WrappedException(e, id, msg, varargin)
            if nargin < 2
                id = 'distcomp:WrappedException';
            end
            if nargin < 3
                msg = '';
            end            
            obj = obj@MException(id, msg, varargin{:});
            obj.CauseException = e;
        end
    end
end
