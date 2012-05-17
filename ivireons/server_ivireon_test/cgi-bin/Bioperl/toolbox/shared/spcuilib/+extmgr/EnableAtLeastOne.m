classdef EnableAtLeastOne < extmgr.AbstractEnableConstraint
    %ENABLEATLEASTONE Define the EnableAtLeastOne extension constraint.
    %   The EnableAtLeastOne constraint forces at least one extension to be
    %   enabled at all times.
    
    %   Author(s): J. Schickler
    %   Copyright 2007-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2009/10/07 14:23:21 $
    
    methods
        function this = EnableAtLeastOne(type)
            % mlock keeps the instantiation of this class from throwing a warning when
            % the clear classes command is issued
            mlock
            
            this@extmgr.AbstractEnableConstraint(type);
        end
        
        function vdb = findViolations(this, hConfigDb)
            %FINDVIOLATIONS   Find type constraint violations
            
            vdb = extmgr.TypeConstraintViolationDb;
            
            nEnabled = length(findChild(hConfigDb, 'Type', this.Type, 'Enable', true));
            
            % Make sure that there is at least 1 extension enabled.
            if nEnabled < 1
                details = sprintf('There are %d enabled extensions of type "%s".', ...
                    nEnabled, this.Type);
                vdb.add(this.Type, class(this), details);
            end
        end
        
        function impose(this, hConfigDb, hRegisterDb)
            %IMPOSE   Impose the constraint on the configuration.
            
            % If there are no enabled configurations of the type, enable
            % the first one.
            if isempty(findChild(hConfigDb, 'Type', this.Type, 'Enable', true))
                hType = findConfig(hConfigDb, this.Type);
                for indx = 1:numel(hType)
                    if hRegisterDb.findRegister(hType(indx)).Visible
                        set(hType(indx), 'Enable', true);
                        return;
                    end
                end
                if ~isempty(hType)
                    set(hType(1), 'Enable', true);
                end
            end
        end
        
        function b = isEnableAll(this, hConfigDb)
            %ISENABLEALL True if the object is EnableAll
            
            % If there is only 1 extension of this type, then it must
            % always be enabled.
            b = length(hConfigDb.findConfig(this.Type)) == 1;
        end
        
        function b = willViolateIfDisabled(this, hConfigDb, hConfig)
            %WILLVIOLATEIFDISABLED Returns true if disabling the extension
            %   will cause a violation.
            
            % If the passed configuration is enabled
            if hConfig.Enable
                hEnab = hConfigDb.findChild('Type', this.Type, 'Enable', true);
                b = length(hEnab) < 2;
            else
                b = false;
            end
        end
        
        function tableValueChanged(this, hConfigDb, hRegisterDb, hDlg, row, newValue)
            %TABLEVALUECHANGED React to table value changes.
            
            % If we are enabling, then we do not need to check anything, return early.
            if newValue == 1
                return
            end
            
            % If there are now no entries enabled, do not allow the current action.
            if this.getTableEnables(hConfigDb, hDlg) + ...
                    this.getHiddenEnableCount(hConfigDb, hRegisterDb) == 0
                hDlg.setTableItemValue([this.Type '_table'], row, 0, '1');
            end
        end
        
        function varargout = validate(this, hConfigDb, hRegisterDb, hDlg)
            %VALIDATE Returns true if this object is valid
            
            enaCnt = this.getTableEnables(hConfigDb, hDlg) + ...
                getHiddenEnableCount(this, hConfigDb, hRegisterDb);
            success = (enaCnt > 0);
            exception = MException.empty;
            if ~success
                exception = MException('spcuilib:extmgr:EnableAtLeastOne:validate:ConstraintViolation', ...
                    'At least one extension of type "%s" must be enabled.', this.Type);
            end
            
            if nargout
                varargout = {success, exception};
            elseif ~success
                throw(exception)
            end
        end
    end
end

% [EOF]
