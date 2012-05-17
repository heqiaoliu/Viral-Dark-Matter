classdef ( Sealed = true ) ReportableException < distcomp.WrappedException
    
%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:41:06 $

    methods ( Access = public )
        function obj = ReportableException(e)
            obj = obj@distcomp.WrappedException(e, 'distcomp:ReportableException');
        end
    end
end