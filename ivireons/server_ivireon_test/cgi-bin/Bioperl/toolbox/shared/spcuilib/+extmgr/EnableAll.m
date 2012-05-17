classdef EnableAll < extmgr.AbstractEnableConstraint
    %ENABLEALL Define the EnableAll extension constraint.
    %   The EnableAll constraint forces all extensions of its type to be
    %   enabled at all times.
    
    %   Author(s): J. Schickler
    %   Copyright 2007-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/10/07 14:23:20 $
    
    methods
        function this = EnableAll(type)
            %ENABLEALL Construct an EnableAll constraint.
            
            % mlock keeps the instantiation of this class from throwing a warning when
            % the clear classes command is issued
            mlock
            
            this@extmgr.AbstractEnableConstraint(type);
        end
        
        function vdb = findViolations(this, hConfigDb)
            %FINDVIOLATIONS Find type constraint violation.
            
            vdb = extmgr.TypeConstraintViolationDb;
            
            % All extensions of this type should be enabled
            type = this.Type;
            hDisabled = findChild(hConfigDb, 'Type', type, 'Enable', false);
            if ~isempty(hDisabled)
                
                % Format the details.
                for indx = 1:length(hDisabled)
                    details = sprintf('Extension "%s:%s" is not enabled.', ...
                        type, hDisabled(indx).Name);
                    vdb.add(type, class(this), details);
                end
            end
        end
        
        function impose(this, hConfigDb, ~)
            %IMPOSE   Impose the type constraint on the configuration.
            
            % Enable all extensions of this type
            set(findConfig(hConfigDb, this.Type), 'Enable', true);
        end
        
        function b = isEnableAll(this, hConfigDb) %#ok
            %ISENABLEALL True if the object is EnableAll
            
            b = true;
        end
    end
end

% [EOF]
