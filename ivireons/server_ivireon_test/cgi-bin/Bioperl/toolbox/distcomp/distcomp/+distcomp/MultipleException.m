classdef ( Sealed = true ) MultipleException < distcomp.WrappedException
    
%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/04/15 22:59:08 $

    methods ( Access = public )
        function obj = MultipleException(multipleErrors, msg, varargin)
            obj = obj@distcomp.WrappedException(multipleErrors, 'distcomp:MultipleException', msg, varargin{:});
        end
    end
end