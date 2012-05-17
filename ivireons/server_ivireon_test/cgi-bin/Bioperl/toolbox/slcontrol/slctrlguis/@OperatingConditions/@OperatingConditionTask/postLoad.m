function postLoad(this, manager)
% POSTLOAD
 
% Author(s): John W. Glass 26-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/12/04 23:27:40 $

% Handle conversion of SimMechanics to use Simulink State Names
if this.Version < GenericLinearizationNodes.getVersion;
    if this.Version < 2.0;
        try
            this.StateOrderList = OperatingConditions.updateStateOrder(this.OpSpecData,this.StateOrderList);
        catch Ex
            this.StateOrderList = {};
        end
        this.StateSpecTableData = [];
    end
    if this.Version < 3.0;
        options = this.Options;
        optimoptions = options.OptimizationOptions;
        optimoptions.DiffMaxChange = this.OptimChars.DiffMaxChange;
        optimoptions.DiffMinChange = this.OptimChars.DiffMinChange;
        optimoptions.MaxFunEvals = this.OptimChars.MaxFunEvals;
        optimoptions.MaxIter = this.OptimChars.MaxIter;
        optimoptions.TolFun = this.OptimChars.TolFun;
        optimoptions.TolX = this.OptimChars.TolX;
        options.OptimizationOptions = optimoptions;
        this.StoreDiagnosticsInspectorInfo = scdgetpref('StoreDiagnosticsInspectorInfo');
    end
    if this.Version < 4.0
        if ~isempty(this.StateSpecTableData)
            % Convert to cell arrays
            this.InputSpecTableData = cell(this.InputSpecTableData);
            this.StateSpecTableData = cell(this.StateSpecTableData);
            this.OutputSpecTableData = cell(this.OutputSpecTableData);
        end
    end
    this.Version = GenericLinearizationNodes.getVersion;
end

if isempty(this.StoreDiagnosticsInspectorInfo)
    this.StoreDiagnosticsInspectorInfo = scdgetpref('StoreDiagnosticsInspectorInfo');
end

% Call the postLoad methods of child nodes
opnodes = this.getChildren;
for ct = 1:length(opnodes)
    opnodes(ct).postLoad(manager);
end