function pushOutputSpecToModel(this) 
% PUSHOUTPUTSPECTOMODEL  Push the current set of operating point
% specifications to the Simulink model.
%
 
% Author(s): John W. Glass 26-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:28:22 $

% Find trimmed signals in the model
TrimOut = find_system(this.Model,'findall','on',...
    'type','port',...
    'LinearAnalysisTrim','on');

for ct = 1:numel(TrimOut)
    set_param(TrimOut(ct),'LinearAnalysisTrim','off')
end

outputs = this.OpSpecData.Outputs;

for ct = 1:numel(outputs)
    try
        PortNumber = outputs(ct).PortNumber;
        if ~isnan(PortNumber)
            ph = get_param(outputs(ct).Block,'PortHandles');
            set_param(ph.Outport(PortNumber),'LinearAnalysisTrim','on');
        end
    catch
        msg = ctrlMsgUtils.message('Slcontrol:operpointtask:PortForOperatingPointSpecificationNotFound',outputs(ct).PortNumber,outputs(ct).Block,this.Model);
        errordlg(msg,xlate('Simulink Control Design'));
    end
end