function [extMode xpcAnimation] = get_machine_extmode_setting(machineName)

extMode = false;
xpcAnimation = false;

cs = getActiveConfigSet(machineName);

if ~isempty(cs) && cs.isValidParam('ExtMode')
    extMode = strcmp(cs.get_param('ExtMode'), 'on');
end

if extMode
    if cs.isValidParam('xPCEnableSFAnimation')
        xpcAnimation = strcmp(cs.get_param('xPCEnableSFAnimation'), 'on');
    else
        xpcAnimation = true;
    end
end
