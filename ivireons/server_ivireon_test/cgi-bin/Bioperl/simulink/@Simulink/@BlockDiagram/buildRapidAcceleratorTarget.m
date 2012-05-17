function rtp = buildRapidAcceleratorTarget(mdl, varargin)
% Simulink.BlockDiagram.buildRapidAcceleratorTarget builds the 
% rapid accelerator target for the model and return the runtime parameter set.
%
% Usage: 
%   rtp = Simulink.BlockDiagram.buildRapidAcceleratorTarget(mdl)
%
% Inputs:
%    mdl: Full name or handle of a Simulink model
%     
% Outputs:
%    rtp:
%       modelChecksum:  1x4 vector that encodes the structure of the model
%       parameters:     A structure of the tunable parameters in the model.
%       
%       The parameters structure contains the following fields:
%         dataTypeName: The data type name, e.g., 'double'
%         dataTypeId  : Internal data type identifier for use by Real-Time
%                       Workshop
%         complex     : 0 if real, 1 if complex
%         dtTransIdx  : Internal data type identifier for use by Real-Time
%                       Workshop
%         values      : All values associated with this entry in the
%                       parameters substructure.
%         map         : Mapping structure information that correlates the 
%                       values to the models' tunable parameters.
%         The map structure contains the following fields:
%           Identifier   : Tunable parameter name
%           ValueIndices : [startIdx, endIdx] start and end indices into
%                          the values field.
%           Dimensions   : Dimension of this tunable parameter (matrices
%                          are generally stored in column-major).

%   $Revision: 1.1.6.6 $    
%   Copyright 2007-2010 The MathWorks, Inc.

    load_system(mdl);
    set_param(mdl, 'RapidAcceleratorSimStatus', 'starting');
    set_param(mdl, 'RapidAcceleratorCallType', 'buildonly');
    theError = '';
    try
        [setupAborted, rtp] = ....
            sl('build_rapid_accel_target', mdl, varargin{1:end});
        
        if setupAborted
            identifier = 'Simulink:tools:rapidAccelSecondSim';
            DAStudio.error(identifier, mdl);
        end
    catch e
        theError = e;        
    end

    buildData = get_param(mdl,'RapidAcceleratorBuildData');
    set_param(mdl, 'RapidAcceleratorSimStatus', 'terminating');
    sl('rapid_accel_target_utils', 'cleanup', buildData);
    set_param(mdl, 'RapidAcceleratorBuildData', []);
    if ~isempty(theError)
        rethrow(theError);
    end
end
