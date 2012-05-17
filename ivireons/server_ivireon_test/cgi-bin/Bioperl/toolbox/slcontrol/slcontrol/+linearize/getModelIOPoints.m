function ios = getModelIOPoints(models)
% getModelIOPoints Utility function to query a model for its set linearization IOs.
% The input MODELS is a cell array of Simulink models to query.
%

% Author(s): John W. Glass 28-Jan-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:35:07 $

in = []; out = []; inout = [];outin = [];openloop = [];
for ct = 1:numel(models)
    % Find systems with linear analysis inputs
    in = [in;find_system(models{ct},'findall','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','on',...
        'LinearAnalysisOutput','off')];

    % Find systems with linear analysis outputs
    out = [out;find_system(models{ct},'findall','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','off',...
        'LinearAnalysisOutput','on')];

    % Find systems with linear analysis inputs then outputs
    inout = [inout;find_system(models{ct},'findall','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','on',...
        'LinearAnalysisOutput','on',...
        'LinearAnalysisLinearizeOrder','off')];

    % Find systems with linear analysis outputs then inputs
    outin = [outin;find_system(models{ct},'findall','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','on',...
        'LinearAnalysisOutput','on',...
        'LinearAnalysisLinearizeOrder','on')];

    % Find systems with linear analysis open loop properties
    openloop = [openloop;find_system(models{ct},'findall','on',....
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisOpenLoop','on',...
        'LinearAnalysisInput','off',...
        'LinearAnalysisOutput','off')];
end

% Construct the linearization object
h = linearize.IOPoint;
ios = [];

for ct = 1:size(in,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(ct),...
        'Block',regexprep(get_param(in(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(in(ct),'PortNumber'),...
        'Type','in',...
        'OpenLoop',get_param(in(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(out,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(out(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(out(ct),'PortNumber'),...
        'Type','out',...
        'OpenLoop',get_param(out(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(inout,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(inout(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(inout(ct),'PortNumber'),...
        'Type','inout',...
        'OpenLoop',get_param(inout(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(outin,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(outin(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(outin(ct),'PortNumber'),...
        'Type','outin',...
        'OpenLoop',get_param(outin(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(openloop,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(openloop(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(openloop(ct),'PortNumber'),...
        'Type','none',...
        'OpenLoop','on');
end