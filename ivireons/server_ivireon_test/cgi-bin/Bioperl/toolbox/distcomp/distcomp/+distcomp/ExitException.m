classdef ( Sealed = true ) ExitException < distcomp.WrappedException
    
%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:41:05 $

    methods ( Access = public )
        function obj = ExitException(e, msg)
            obj = obj@distcomp.WrappedException(e, 'distcomp:ExitException', msg);
        end
    end
end