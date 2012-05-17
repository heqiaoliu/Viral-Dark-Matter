%TARGETSCOMMS_VECTORAPPLICATIONCHANNEL class representing information about vector application chanels
%   TARGETSCOMMS_VECTORAPPLICATIONCHANNEL class representing information about
%   vector application chanels

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/23 19:11:15 $

classdef TargetsComms_VectorApplicationChannel < handle
    
    properties(Constant = true, GetAccess = 'private')
        applicationChannelList = {'MATLAB 1', 'MATLAB 2', 'MATLAB 3', 'MATLAB 4', 'MATLAB 5', 'MATLAB 6', 'MATLAB 7', 'MATLAB 8', 'MATLAB 9', 'MATLAB 10'};
    end % properties
    
    methods(Static = true)
        % This method returns the numeric representation of a application channel
        function applicationChannel = getApplicationChannelNumeric(applicationChannelString)
            [found, location] = ismember(applicationChannelString, TargetsComms_VectorApplicationChannel.applicationChannelList);
            if found
                applicationChannel = location - 1;
            else
                applicationChannel = 0;
                warning('TargetsComms_VectorApplicationChannel:getApplicationChannelNumeric', ['Application channel: ' applicationChannelString ' is not valid']);
            end
        end
        
        % This method launches the application channel configuration GUI.
        %
        % This method is explicitly referenced by the External Mode
        % documentation.
        function configureApplicationChannels()
            configUtility = 'vcanconf';            
            % test to see if vcanconf exists on the
            % system path, using Win32 API MEX file
            found = vector_find_conf_util;
            if (found)
                % launch vcanconf in the background
                dos([configUtility '&']);
            else
                % utility not found
                error('TargetsComms_VectorApplicationChannel:configureApplicationChannels', ...
                    ['Unable to launch the application channel configuration utility. ' ...
                    'The "%s" utility was not found on the Windows System Path. ' ...
                    'To fix this error, make sure the required CAN drivers are ' ...
                    'installed on this computer; refer to the product documentation for details. '], ...
                    configUtility);
            end
        end
    end
end