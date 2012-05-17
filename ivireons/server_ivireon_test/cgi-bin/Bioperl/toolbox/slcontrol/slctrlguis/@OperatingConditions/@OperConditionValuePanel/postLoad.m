function postLoad(this, manager) %#ok<INUSD>
% POSTLOAD
 
% Author(s): John W. Glass 26-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:29 $

% Handle conversion of SimMechanics to use Simulink State Names
if this.Version < GenericLinearizationNodes.getVersion;
    if this.Version < 2.0;
        this.StateTableData = [];
    end
    if this.Version < 4.0
        % Convert to cell arrays
        if ~isempty(this.StateTableData)
            this.StateTableData = cell(this.StateTableData);
        end
        if ~isempty(this.InputTableData)
            this.InputTableData = cell(this.InputTableData);
        end
    end
    this.Version = GenericLinearizationNodes.getVersion;
end