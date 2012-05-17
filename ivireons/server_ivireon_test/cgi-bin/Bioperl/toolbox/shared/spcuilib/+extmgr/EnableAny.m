classdef EnableAny < extmgr.AbstractEnableConstraint
    %ENABLEANY Define the EnableAny extension constraint.
    %   The EnableAny constraint does not restrict the enable state of the
    %   extensions of its type.  This is the default constraint applied to
    %   extension types.
    
    %   Author(s): J. Schickler
    %   Copyright 2007-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/03/09 19:32:26 $
    
    methods
        function this = EnableAny(type)
            % mlock keeps the instantiation of this class from throwing a warning when
            % the clear classes command is issued
            mlock
            
            this@extmgr.AbstractEnableConstraint(type);
        end
    end
end

% [EOF]
