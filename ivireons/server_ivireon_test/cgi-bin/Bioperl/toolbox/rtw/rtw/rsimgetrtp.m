function [rtp] = rsimgetrtp(modelname,varargin)
% RSIMGETRTP   Get the parameter structure from your model.
% rtP = RSIMGETRTP('MODELNAME')
%
% RSIMGETRTP returns a parameter structure for the current model settings. This
%   structure is designed to be used with the Real-Time Workshop Rapid
%   Simulation Target (RSim). The process of obtaining the "rtP" structure
%   forces an 'update diagram' action. In addition to the current model tunable
%   block parameter settings, the rtP structure contains a structural
%   checksum. This checksum is used to ensure that the model structure is
%   consistent with that of the model when the RSim executable was generated.
%
%   The rtP structure returned has the following fields:
%     modelChecksum : 1x4 vector that encodes the structure of the model
%     parameters    : A structure of the tunable parameters in the model.
%
%   The parameters structure contains the following fields:
%
%     dataTypeName : The data type name, e.g., 'double'
%     dataTypeId   : Internal data type identifier for use by Real-Time Workshop
%     complex      : 0 if real, 1 if complex
%     dtTransIdx   : Internal data index for use by Real-Time Workshop
%     values       : Values of parameters associated with this entry
%     map          : If InlineParameters option is on, then this field has the
%                    mapping information that correlates the values to the
%                    models' tunable parameters. This mapping information is
%                    useful for creating subsequent rtP structures using
%                    RSIMSETRTPPARAM, with out compiling the block diagram.
%                    If InlineParameters option is off this field is empty.
%
%   The map structure contains the following fields:
%
%     Identifier   : Tunable parameter name
%     ValueIndices : [startIdx,endIdx] start and end indices in the values field
%     Dimensions   : Dimension of this tunable parameter
%
% Notes:
% 1] Tunable Fixed-Point parameters will show up as their stored value.
%    For example, an sfix(16) parameter value of 1.4 with a scaling of 2^-8 will
%    have a value of 358 as an int16.
%
% Example: Create an RSim executable and run it with a different parameter set.
%
% 1] Set Real-Time Workshop target configuration to Rapid Simulation Target
% 2] Create the RSim executable for the model by clicking the build button or
%
%       >> rtwbuild('model')
%
% 3] Modify the block parameters used in your model, get the new parameter as
%    rtP structure and save it to a mat-file:
%
%       >> rtP = rsimgetrtp('model')
%       >> save myrtp.mat rtP
%
% 4] Run the RSim executable with the new parameter set:
%
%        >> !model -p myrtp.mat
%
% 5] Load the results in to Matlab
%        >> load model.mat
%
% see also: RSIMSETRTPPARAM

%   Copyright 1994-2010 The MathWorks, Inc.
%   $Revision: 1.12.2.12 $

    addTunableParamInfo = false; % assume

    % Check input arguments: the syntax is either rsimgetrtp(mdl) or
    % rsimgetrtp(mdl,'AddTunableParamInfo','on'). The input arguments in the
    % latter case are ignore as we now have a simple way of getting at the
    % tunable parameters and hence it is always added to rtp if available
    if nargin > 1
        if nargin ~= 3
            DAStudio.error('RTW:rsim:getRTPInvalidNumParams');
        end
        prm = varargin{1};
        if ~ischar(prm)
            DAStudio.error('RTW:rsim:getRTPInputNotString');
        elseif ~isequal(prm,'AddTunableParamInfo')
            DAStudio.error('RTW:rsim:getRTPUnknownOption', prm);
        end
        val = varargin{2};
        if ~ischar(val) || ~(isequal(val,'on') || isequal(val,'off'))
            DAStudio.error('RTW:rsim:getRTPInvalidOptionValue');
        end
        addTunableParamInfo = isequal(val,'on');
    end

    rtp = [];
    % Load the block diagram if it is not already loaded.
    openModels = find_system('type','block_diagram');
    modelOpen = 0;
    for i=1:length(openModels)
        mdl = openModels{i};
        if strcmp(mdl,modelname)
            modelOpen = 1;
            break;
        end
    end
    if ~modelOpen
        load_system(modelname);
    end

    if ( addTunableParamInfo && ...
         isequal(get_param(modelname,'RTWInlineParameters'),'off') )
        DAStudio.error('RTW:rsim:getRTPModelNotInlined');
    end

    % Load the rtPStruct return argument:
    dirty = get_param(modelname,'dirty');
    set_param(modelname,'ExtModeParamVectName','rtp');
    try
        set_param(modelname,'SimulationCommand','WriteExtModeParamVect');
    catch err
    end
    set_param(modelname, 'dirty', dirty);

    if isempty(rtp)
        if(exist('err','var'))
            rethrow(err);
        else
            DAStudio.error('RTW:rsim:getRTPParamVectNotCreated', modelname);
        end
    end

end % rsimgetrtp
