function initclient()
; %#ok Undocumented
% Copyright 2004-2010 The MathWorks, Inc.

% initclient may be called multiple times because clear classes will clear
% the schema.

% Don't call this on a worker
if feature('isdmlworker')
    return
end

% Call the common initialization
initcommon();

% Set the values of the export port and hostname.
config = pctconfig;
% The conditions are necessary because initclient may be called multiple times.
import com.mathworks.toolbox.distcomp.service.ExportConfigInfo;
if ~ExportConfigInfo.checkIfPortSet()
    portrange = config.portrange;
    % portrange will be either [minPort, maxPort] or 0    
    if isscalar(portrange)
        ExportConfigInfo.useEphemeralPort();
    else
        ExportConfigInfo.setPortRange(portrange(1), ...
                                      portrange(2));
    end
end
export_hostname = config.hostname;
java.lang.System.setProperty('java.rmi.server.hostname',export_hostname);

% Turn down the JINI logging levels to SEVERE, unless they have already
% been set to some other level. This would ensure that the second time this
% function is called we don't change the level.
import java.util.logging.Logger;
import java.util.logging.Level;
logger = Logger.getLogger('net.jini');
if isempty(logger.getLevel)
    logger.setLevel(Level.SEVERE);
end

% Tell pctconfig that we have used values from it
pctconfig('initclienthasrun', true);

end
