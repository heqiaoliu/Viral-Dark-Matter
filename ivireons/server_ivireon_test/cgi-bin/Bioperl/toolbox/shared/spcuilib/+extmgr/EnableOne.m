classdef EnableOne < extmgr.AbstractEnableConstraint
    %ENABLEONE Define the EnableOne extension constraint.
    %   The EnableOne constraint forces one extension to be enabled and
    %   prevents more than one extension from being enabled.
    
    %   Author(s): J. Schickler
    %   Copyright 2007-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2009/10/07 14:23:22 $
    
    methods
        
        function this = EnableOne(type)
            % mlock keeps the instantiation of this class from throwing a warning when
            % the clear classes command is issued
            mlock
            
            this@extmgr.AbstractEnableConstraint(type);
        end
        
        function vdb = findViolations(this, hConfigDb)
            %FINDVIOLATIONS   Find type constraint violations
            
            vdb = extmgr.TypeConstraintViolationDb;
            
            % Only one extension of type can be on
            enableCnt = length(findChild(hConfigDb, 'Type', this.Type, 'Enable', true));
            
            if enableCnt ~= 1  % either 0, or 2 or more
                % Extension type-constraint "EnableOne" violated for extension
                % enableCnt indicates number
                details = sprintf('There are %d enabled extensions of type "%s".', ...
                    enableCnt, this.Type);
                vdb.add(this.Type, class(this), details);
            end
        end
        
        function impose(this, hConfigDb, hRegisterDb)
            %IMPOSE   Impose the type constraint on the configuration.
            
            hConfig = findChild(hConfigDb, 'Type', this.Type, 'Enable', true);
            
            if length(hConfig) > 1
                
                % If there are more than one extensions of this type
                % enabled, disable all after the first.
                set(hConfig(2:end), 'Enable', false);
            elseif isempty(hConfig)
                
                % If there are no enabled extensions for this type, enable
                % the first one in the configuration database.
                hConfig = findConfig(hConfigDb, this.Type);
                for indx = 1:numel(hConfig)
                    if hRegisterDb.findRegister(hConfig(indx)).Visible
                        set(hConfig(indx), 'Enable', true);
                        return;
                    end
                end
                
                if ~isempty(hConfig)
                    set(hConfig(1), 'Enable', true);
                end
            end
        end
        
        function b = isEnableAll(this, hConfigDb) 
            %ISENABLEALL True if the object is EnableAll
            
            % If we can only find 1 registered extension of this type, we
            % consider this constraint to be just like EnableAll.
            b = length(hConfigDb.findConfig(this.Type)) == 1;
        end
        
        function b = willViolateIfDisabled(this, hConfigDb, hConfig) %#ok API
            %WILLVIOLATEIFDISABLED Returns true if disabling this extension
            %   will violate the constraint.
            
            b = hConfig.Enable;
            
        end
        
        function tableValueChanged(this, hConfigDb, hRegisterDb, hDlg, row, newValue) %#ok API
            %TABLEVALUECHANGED React to table value changes.
            
            % Make sure that we only have 1 extension enabled
            type  = this.Type;
            nType = length(findConfig(hConfigDb, type));
            if newValue
                
                % If we are turning on the selected extension, disable all
                % the other ones.
                for indx = 0:nType-1
                    if indx ~= row && ...
                            strcmpi(hDlg.getTableItemValue([type '_table'],indx,0), '1')
                        hDlg.setTableItemValue([type '_table'], indx, 0, '0');
                    end
                end
            else
                
                % If we are turning off the selected extension, make sure
                % that there is still at least 1 (and only 1) extension
                % still enabled.
                nEnab = 0;
                for indx = 0:nType-1
                    nEnab = nEnab + str2double(hDlg.getTableItemValue([type '_table'], indx, 0));
                    if nEnab > 1
                        hDlg.setTableItemValue([type '_table'], indx, 0, '0');
                    end
                end
                if nEnab == 0
                    hDlg.setTableItemValue([type '_table'], row, 0, '1');
                end
            end
        end
        
        function varargout = validate(this, hConfigDb, hRegisterDb, hDlg)
            %VALIDATE Returns true if this object is valid
            
            % When there is a single extension of this type, we do not need
            % to bother checking for the checkboxes because they are not
            % rendered. g427202
            if numel(findConfig(hConfigDb, this.Type)) < 2
                if nargout > 0
                    varargout = {true, '', ''};
                end
                return;
            end
            
            % only one config of this type should be enabled
            enaCnt = getTableEnables(this, hConfigDb, hDlg) + ...
                getHiddenEnableCount(this, hConfigDb, hRegisterDb);
            success = (enaCnt == 1);
            exception = MException.empty;
            if ~success
                exception = MException('spcuilib:extmgr:EnableOne:validate:ConstraintViolation', ...
                    'Exactly one extension of type "%s" must be enabled.', this.Type);
            end
            
            if nargout > 0
                varargout = {success, exception};
            elseif ~success
                throw(exception);
            end
        end
    end
end

% [EOF]
