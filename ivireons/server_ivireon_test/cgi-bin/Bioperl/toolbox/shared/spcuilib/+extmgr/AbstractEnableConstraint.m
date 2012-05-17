classdef AbstractEnableConstraint < dynamicprops
    %ABSTRACTENABLECONSTRAINT Defines the AbstractConstraint
    %   interface which is used by the extension manager to customize
    %   behavior of extension types.

    %   Author(s): J. Schickler
    %   Copyright 2007-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/10/07 14:23:19 $

    properties (SetAccess = 'protected')
        Type = '';
    end

    methods
        function this = AbstractEnableConstraint(type)
            this.Type = type;
        end

        function vdb = findViolations(this, hConfigDb) %#ok
            %FINDVIOLATIONS Find constraint violations in a configuration.
            
            vdb = extmgr.TypeConstraintViolationDb;
        end
        
        function impose(this, hConfigDb, hRegisterDb) %#ok
            %IMPOSE   Impose this constraint on the configuration.
            
            % NO OP
        end
        
        function b = isEnableAll(this, hConfigDb) %#ok
            %ISENABLEALL True if the object is EnableAll

            b = false;
        end

        function tableValueChanged(this, hConfigDb, hRegisterDb, hDlg, row, newValue) %#ok
            %TABLEVALUECHANGED React to value changes in a table.

            % NO OP
        end
        
        function varargout = validate(this, varargin) %#ok
            %VALIDATE Returns true if valid to apply dialog.

            b         = true;
            exception = MException.empty;

            if nargout
                varargout = {b, exception};
            end
        end
        
        function b = willViolateIfDisabled(this, hConfigDb, hConfig) %#ok
            %WILLVIOLATEIFDISABLED  Returns true if disabling this
            %extension would violate the constraint.
            
            b = this.isEnableAll(hConfigDb);
        end
    end
    
    methods (Access = 'protected')
        function [enaCnt,extCnt] = getTableEnables(this, hConfigDb, hDlg)
            %GETTABLEENABLES Get the number of checked entries in the
            %   dialog's table for this constraints Type.

            % Enables are all in first column (0) of table
            % Copy enable status from all rows of table in dialog
            %
            % How many rows in table?  -> how many extensions of this type?
            extCnt = numel(findConfig(hConfigDb,this.Type));

            ena = false(extCnt,1);
            for iRow = 1:extCnt
                % Checkbox is enabled if value is '1', disabled otherwise
                ena(iRow) = strcmpi( hDlg.getTableItemValue([this.Type '_table'],iRow-1,0), '1');
            end

            enaCnt = sum(ena); % count enabled checkboxes
        end
        
        function enaCnt = getHiddenEnableCount(this, hConfigDb, hRegisterDb)
            
            hHidden = find(hRegisterDb, 'Type', this.Type, 'Visible', false);
            enaCnt = 0;
            for indx = 1:length(hHidden)
                hConfig = findConfig(hConfigDb, hHidden(indx));
                if hConfig.Enable
                    enaCnt = enaCnt + 1;
                end
            end
        end
    end

    methods
        function set.Type(this, type)
            if isempty(type) || ~ischar(type)
                error('spcuilib:extmgr:AbstractEnableConstraint:Type:emptyType', ...
                    'The "Type" property must be a non-empty string.');
            end
            this.Type = type;
        end
    end
end

% [EOF]
