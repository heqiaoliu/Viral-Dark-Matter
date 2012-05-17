classdef EnableZeroOrOne < extmgr.AbstractEnableConstraint
    %ENABLEZEROORONE Define the EnableZeroOrOne extension constraint.
    %   The EnableZeroOrOne constraint prevents more than one extension of
    %   its type from being enabled at a time.

    %   Author(s): J. Schickler
    %   Copyright 2007-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:49:02 $

    methods
        function this = EnableZeroOrOne(type)
            
            % MLOCK the file to hide it from clear classes
            mlock;
            
            this@extmgr.AbstractEnableConstraint(type);
        end

        function vdb = findViolations(this, hConfigDb)
            %FINDVIOLATIONS   Find type constraint violations.

            vdb = extmgr.TypeConstraintViolationDb;

            nEnabled = length(findChild(hConfigDb, 'Type', this.Type, 'Enable', true));
            if nEnabled > 1
                details = sprintf('There are %d enabled extensions of type "%s".', ...
                    nEnabled, this.Type);
                vdb.add(this.Type, class(this), details);
            end
        end

        function impose(this, hConfigDb, ~)
            %IMPOSE Impose the constraint on the configurations.

            hConfig = findChild(hConfigDb, 'Type', this.Type, 'Enable', true);
            
            if length(hConfig) > 1
                set(hConfig(2:end), 'Enable', false);
            end
        end

        function tableValueChanged(this, hConfigDb, hRegisterDb, hDlg, row, newValue) %#ok
            %TABLEVALUECHANGED React to table value changes.

            % If we are unchecking a box, we do not need to do anything.
            if newValue

                % Make sure that have no more than 1 extension enabled
                nType = length(findConfig(hConfigDb, this.Type));

                % Loop over all extensions in the type and uncheck them unless
                % they are the extension that was just checked.  This will
                % allow the user to enable an extension without having to
                % disable the currently enabled extension.  If there is no
                % current extension, this is basically a no op because all of
                % the extensions are already disabled.
                for indx = 0:nType-1
                    if indx ~= row
                        hDlg.setTableItemValue([this.Type '_table'], indx, 0, '0');
                    end
                end
            end
        end
        
        function varargout = validate(this, hConfigDb, hRegisterDb, hDlg)
            %VALIDATE Returns true if this object is valid

            success = getTableEnables(this, hConfigDb, hDlg) + ...
                getHiddenEnableCount(this, hConfigDb, hRegisterDb) < 2;
            exception = MException.empty;
            if ~success
                exception = MException('spcuilib:extmgr:EnableZeroOrOne:validate:ConstraintViolation', ...
                    'No more than one extension of type "%s" can be enabled.', this.Type);
            end

            if nargout
                varargout = {success, exception};
            elseif ~success
                throw(exception);
            end
        end
    end
end

% [EOF]
