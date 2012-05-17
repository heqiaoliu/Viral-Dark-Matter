% This undocumented class may be removed in a future release.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:16:42 $

classdef ImageAdapterException < MException
    
    methods
        
        function obj = ImageAdapterException(method_name,class_name,diagnostic_string)
            
            % A reference to an instance of the class will remain in
            % "lasterror" until the next exception is thrown.  This will
            % prevent a clear classes unless we lock this file.
            mlock;
            errid = sprintf('Images:AdapterDispatcher:%sError',method_name);
            errstr = sprintf('%s %s method of the %s class.',...
                'Error encountered while executing the',method_name,...
                class_name);
            
            if nargin == 3
                errstr = sprintf('%s  %s',errstr,diagnostic_string);
            end
            
            obj = obj@MException(errid,errstr);
            
        end % constructor
        
        function str = getReport(obj)
            
            str = sprintf('%s\n\nThe cause of the error was:\n\n%s',...
                obj.message,obj.cause{1}.getReport());
            
        end % getReport
        
    end % public methods
    
end % ImageAdapterException

