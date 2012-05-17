function [transports, mexfiles, interfaces] = extmode_transports(cs)
% EXTMODE_TRANSPORTS External Mode callback function for configuration sets.
%                    Input argument is a system target file name and the
%                    output arguments are the supported transports, mexfile
%                    names, and interface levels for the system target file.
%
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $

    %
    % Transport layers for External Mode supported targets.
    %
    % To add Configuration Set External Mode support to a built-in target:
    %
    %  1) Modify the schema of the target to include the External Mode panel
    %     (toolbox/simulink/simulink/@Simulink/@ConfigSetDialogController/getTargetExtModeDialogGroup.m).
    %
    %  2) Add the name(s) of the new transport layer to the transports variable
    %     for the specific target using the following template:
    %
    %     transports = {'transport1', 'transport2', ..., 'transportN'}; 
    %
    %  3) Add the name(s) of the MEX-File associated with the new transport
    %     layer to the mexfiles variable for the specific target using the
    %     following template:
    %
    %     mexfiles = {'mexfile1', 'mexfile2', ..., 'mexfileN'}; 
    %
    %  4) Add the interface level associated with the new transport layer
    %     to the interfaces variable for the specific target using the
    %     following template:
    %
    %     interfaces = {'Level1', 'Level1', ..., 'Level2 - Open'}; 
    %
    %     Valid interface levels are:
    %
    %       a) "Level1"        - Classic extmode using the extmode server.
    %       b) "Level2 - Open" - External Mode Open Protocol.
    %
    %  5) Modify the template makefiles for the targets supporting the new
    %     transport layer.  For example, the template makefiles for GRT are
    %     located in <matlabroot>/rtw/c/grt/*.tmf
    %
    %  The variables transports, mexfiles, and interfaces must be 1xN arrays.
    %
    % To add Configuration Set External Mode support to a custom target:
    %
    %  1) Create an sl_customization.m file on the Matlab path similar to the
    %     following:
    %
    %     function sl_customization(cm)
    %       cm.ExtModeTransports.add('SystemTargetFile1.tlc', 'transport1', 'mexfile1', 'interface1');
    %       cm.ExtModeTransports.add('SystemTargetFile2.tlc', 'transport2', 'mexfile2', 'interface2');
    %        ...
    %       cm.ExtModeTransports.add('SystemTargetFileN.tlc', 'transportN', 'mexfileN', 'interfaceN');
    %     %end function
    %
    %     The same SystemTargetFile may be listed multiple times and may also
    %     be one of the built-in system target files (e.g. grt.tlc)
    %
    %  2) Modify the template makefiles for the targets supporting the new
    %     transport layer.  For example, the template makefiles for GRT are
    %     located in <matlabroot>/rtw/c/grt/*.tmf
    %
  
    transports = {};
    mexfiles   = {};
    interfaces = {};

    sysTargFile = '';
    if ~isempty(cs)
        hRTW = get(getComponent(cs, 'Real-Time Workshop'));
        if ~isempty(hRTW)
            sysTargFile = hRTW.SystemTargetFile;
        end
    end
    
    %
    % GRT/GRT Malloc Targets
    %
    if strcmp(sysTargFile, 'grt.tlc');
        transports = {
            'tcpip'                 % Index 0 in the template makefiles
            'serial_win32'          % Index 1
                     };
        mexfiles = {
            'ext_comm'              % MEX-File for 'tcpip'
            'ext_serial_win32_comm' % MEX-File for 'serial_win32'
                   };
        interfaces = {
            'Level1'
            'Level1'
                     };
    %
    % ERT Target
    %
    elseif strcmp(sysTargFile, 'ert.tlc');
        transports = {
            'tcpip'                 % Index 0 in the template makefiles
            'serial_win32'          % Index 1
                     };
        mexfiles = {
            'ext_comm'              % MEX-File for 'tcpip'
            'ext_serial_win32_comm' % MEX-File for 'serial_win32'
                   };
        interfaces = {
            'Level1'
            'Level1'
                     };
    %
    % RSim/RAccel Targets
    %
    elseif (strcmp(sysTargFile, 'rsim.tlc')|| strcmp(sysTargFile, 'raccel.tlc'))
        transports = {
            'tcpip'                 % Index 0 in the template makefiles
            'serial_win32'          % Index 1
                     };
        mexfiles = {
            'ext_comm'              % MEX-File for 'tcpip'
            'ext_serial_win32_comm' % MEX-File for 'serial_win32'
                   };
        interfaces = {
            'Level1'
            'Level1'
                     };
    %
    % Tornado Target
    %
    elseif strcmp(sysTargFile, 'tornado.tlc')
        transports = {
            'tcpip'                 % Index 0 in the template makefiles
                     };
        mexfiles = {
            'ext_comm'              % MEX-File for 'tcpip'
                   };
        interfaces = {
            'Level1'
                     };
    %
    % Real-Time Windows Target
    %
    elseif any(strcmp(sysTargFile, {'rtwin.tlc', 'rtwinert.tlc'}))
        transports = {
            'sharedmem'             % Index 0 in the template makefiles
                     };
        mexfiles = {
            'rtwinext'              % MEX-File for 'sharedmem'
                   };
        interfaces = {
            'Level1'
                     };
    %
    % xPC Target (ERT)
    %
    elseif strcmp(sysTargFile, 'xpctargetert.tlc')
        transports = {
            'tcpip'                 % Index 0 in the template makefiles
                     };
        mexfiles = {
            'ext_xpc'               % MEX-File for 'tcpip'
                   };
        interfaces = {
            'Level2 - Open'
                     };
    %
    % Target for Freescale MPC5xx
    %
    elseif any(strcmp(sysTargFile, {'mpc555rt.tlc' 'mpc555rt_grt.tlc'}))
        % Name and location of the external mode registration file
        mpc5xx_registration_file = 'mpc5xx_extmode_registration.m';
        mpc5xx_registration_file_location = fullfile(matlabroot, 'toolbox', 'rtw', 'targets', 'mpc555dk', 'mpc555dk', mpc5xx_registration_file);
        % Is the mpc5xx_extmode_registration.m on the path and in the correct location
        if (exist(mpc5xx_registration_file) == 2) && ...
                (strcmp(which(mpc5xx_registration_file), mpc5xx_registration_file_location))
            % External mode is enabled
            % Get the transports and mexfile information
            [transports mexfiles interfaces] = mpc5xx_extmode_registration();
        else
            % External mode is not enabled
            transports = {};
            mexfiles = {};
            interfaces = {};
        end

    %
    % Target for Infineon C166
    %
    elseif any(strcmp(sysTargFile, {'c166.tlc' 'c166_grt.tlc'}))
        % Name and location of the external mode registration file
        c166_registration_file = 'c166_extmode_registration.m';
        c166_registration_file_location = fullfile(matlabroot, 'toolbox', 'rtw', 'targets', 'c166', 'c166', c166_registration_file);
        % Is the c166_extmode_registration.m on the path and in the correct location
        if (exist(c166_registration_file) == 2) && ...
                (strcmp(which(c166_registration_file), c166_registration_file_location))
            % External mode is enabled
            % Get the transports and mexfile information
            [transports mexfiles interfaces] = c166_extmode_registration();
        else
            % External mode is not enabled
            transports = {};
            mexfiles = {};
            interfaces = {};
        end
    %
    % CCSLINK targets
    %
    elseif any(strcmp(sysTargFile, {'ccslink_ert.tlc' 'ccslink_grt.tlc' 'idelink_ert.tlc' 'idelink_grt.tlc'}))
        % Name and location of the external mode registration file
        ccslink_registration_file = 'ccslink_extmode_registration.m';
        ccslink_registration_file_location = which(ccslink_registration_file);
        % Is the ccslink_extmode_registration.m on the path and in the correct location
        if (exist(ccslink_registration_file,'file')) && ...
                (strcmp(which(ccslink_registration_file), ccslink_registration_file_location))
            % External mode is enabled
            % Get the transports and mexfile information
            [transports mexfiles interfaces] = ccslink_extmode_registration(cs);
        else
            % External mode is not enabled
            transports = {};
            mexfiles = {};
            interfaces = {};
        end
    end
    
    %
    % Handle any custom transports
    %
    cm = DAStudio.CustomizationManager;
    [custom_targets custom_transports custom_mexfiles custom_interfaces] = ...
        cm.ExtModeTransports.get();
  
    if (~isempty(custom_transports))
        cntr = 1;
        idx  = length(transports);
        len  = length(custom_transports);
      
        for i=1:len
            if strcmp(sysTargFile, custom_targets{i})
                transports{idx+cntr} = custom_transports{i};
                mexfiles  {idx+cntr} = custom_mexfiles  {i};
                interfaces{idx+cntr} = custom_interfaces{i};
                cntr = cntr + 1;
            end
        end
    end

    %
    % Unsupported Targets
    %
    if isempty(transports)
        transports = {'none'};
        mexfiles   = {'noextcomm'};
        interfaces = {'Level1'};
    end;
  
    % Variables should be 1xN arrays
    transports = transports';
    mexfiles   = mexfiles';
    interfaces = interfaces';
  
% end extmode_transports
