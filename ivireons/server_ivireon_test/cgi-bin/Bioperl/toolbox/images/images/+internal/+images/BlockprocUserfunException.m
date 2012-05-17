% This undocumented class may be removed in a future release.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:16:41 $

classdef BlockprocUserfunException < MException
    
    methods
        
        function obj = BlockprocUserfunException()
            
            % A reference to an instance of the class will remain in
            % "lasterror" until the next exception is thrown.  This will
            % prevent a clear classes unless we lock this file.
            mlock;
            errid = 'Images:blockproc:userfunError';
            errstr = sprintf('%s%s%s','Function BLOCKPROC encountered ',...
                'an error while evaluating the user supplied function ',...
                'handle, FUN.');
            obj = obj@MException(errid,errstr);
            
        end % constructor
        
        function str = getReport(obj)
            
            str = sprintf('%s\n\nThe cause of the error was:\n\n%s',...
                obj.message,obj.cause{1}.getReport());
            
        end % getReport
        
    end % public methods
    
end % BlockprocUserfunException

