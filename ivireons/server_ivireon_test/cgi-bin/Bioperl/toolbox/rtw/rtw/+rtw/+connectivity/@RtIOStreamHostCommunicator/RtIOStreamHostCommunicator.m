classdef RtIOStreamHostCommunicator < rtw.connectivity.Communicator
%RTIOSTREAMHOSTCOMMUNICATOR implements a host-side communicator
%
%   RTIOSTREAMHOSTCOMMUNICATOR(COMPONENTARGS, LAUNCHER, RTIOSTREAMLIB) creates
%   an instance of this class using the shared library
%   RTIOSTREAMLIB. RTIOSTREAMLIB must be an implementation of the rtiostream API
%   and provides the host-side of a communications channel. For more details on
%   rtiostream, see rtwdemo_rtiostream.
% 
%   To create your own target connectivity configuration, you will only need to
%   used the methods of this class that are listed and hotlinked below. All
%   other properties and methods of this class are undocumented and likely to
%   change from release to release.
%
%   RtIOStreamHostCommunicator methods:
%
%       SETOPENRTIOSTREAMARGLIST - set an argument list for opening the channel
%       ADDOPENRTIOSTREAMARGS    - appends to the argument list
%       GETOPENRTIOSTREAMARGLIST - returns the argument list
%       SETINITCOMMSTIMEOUT      - sets an initCommunication timeout (in secs)
%
%   See also RTW.CONNECTIVITY.COMPONENTARGS, RTW.MYPIL.CONNECTIVITYCONFIG,
%   RTWDEMO_RTIOSTREAM

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/10/24 19:21:36 $


    properties (SetAccess=private, GetAccess=private)
        stationID;
        rtiostreamLib;
        openRtIOStreamArgList = {};
        timeoutRecvSecs = 60;
        timeout;
    end       
        
    methods
        % constructor
        function this = RtIOStreamHostCommunicator(componentArgs, ...
                launcher, rtiostreamLib)
            error(nargchk(3, 3, nargin, 'struct'));

            % call super class constructor
            this@rtw.connectivity.Communicator(componentArgs, launcher);

            this.rtiostreamLib = rtiostreamLib;
            
            this.timeout = 20;
        end

        function startCommands(this) %#ok
            error(nargchk(1, 1, nargin, 'struct'));
            % Nothing to do in this case
        end

        function endCommands(this) %#ok
            error(nargchk(1, 1, nargin, 'struct'));
            % Nothing to do in this case
        end
        
        function setOpenRtIOStreamArgList(this, argList)
        %SETOPENRTIOSTREAMARGLIST sets an argument list for opening the channel
        %
        %   SETOPENRTIOSTREAMARGLIST(THIS,ARGLIST) sets the string ARGLIST as the
        %   argument list to be used when the rtIOStreamOpen function of the
        %   rtiostream shared library is called.
            
            this.openRtIOStreamArgList = argList;
        end

        function setOpenRtIOStreamArgPair(this, argPair)
        %SETOPENRTIOSTREAMARGPAIR sets an argument pair within the argument list
        %
        %   SETOPENRTIOSTREAMARGPAIR(THIS,ARGPAIR) sets the ARGPAIR within the
        %   argument list to be used when the rtIOStreamOpen function of the
        %   rtiostream shared library is called. ARGPAIR must be a cell array
        %   with length equal to two containing a name/value pair; if the name
        %   already exists in the argument list the corresponding value is
        %   replaced.

            argName = argPair{1};
            argValue = argPair{2};
            found = 0;
            lenArgList = length(this.openRtIOStreamArgList);
            for i=1:lenArgList
                arg=this.openRtIOStreamArgList{i};
                if ischar(arg)
                    if strcmp(argName,arg)
                        found = 1;
                        break;
                    end
                end
            end
            if found == 1;
                idx = i; % replace existing value
            else
                idx = lenArgList + 1; % append
            end
            
            this.openRtIOStreamArgList{idx} = argName;
            this.openRtIOStreamArgList{idx+1} = argValue;
            
        end
        
        
        function addOpenRtIOStreamArgs(this, argList)
        %ADDOPENRTIOSTREAMARGS appends to the argument list
        %
        %   ADDOPENRTIOSTREAMARGS(THIS,ARGLIST) appends the string ARGLIST to
        %   the argument list to be used when the rtIOStreamOpen function of the
        %   rtiostream shared library is called.

            rtw.connectivity.ProductInfo.warning('target', ...
                                                 'AddOpenRtIOStreamArgsDeprecated',...
                                                 mfilename);
            
            for i=1:length(argList)
                this.openRtIOStreamArgList{end+1} = argList{i};
            end
        end
        

        function setTimeoutRecvSecs(this,timeout)
        %SETTIMEOUTRECVSECS sets the timeout value for reading data
        %
        %   SETTIMEOUTRECVSECS(THIS,TIMEOUT) configures the method 
        %   readData to time our if no new data is received for a period
        %   of greater than TIMEOUT seconds.
        
            this.timeoutRecvSecs = timeout;
        end                
        
        function argList = getOpenRtIOStreamArgList(this)
        %GETOPENRTIOSTREAMARGLIST returns the argument list
        %
        %   ARGLIST = ADDOPENRTIOSTREAMARGLIST(THIS) returns the string ARGLIST
        %   to be used when the rtIOStreamOpen function of the rtiostream shared
        %   library is called.

            argList = this.openRtIOStreamArgList;
        end
        
        function setInitCommsTimeout( this, timeout )
        %SETINITCOMMSTIMEOUT sets an initCommunication timeout (in secs)
            this.timeout = timeout;
        end
        
        function dataIn = processCommand(this, ...
                                         dataOut, ...
                                         dataInAmount, ...
                                         ~)                                       
            dataIn = rtiostream_wrapper(this.rtiostreamLib, ...
                                        'pilsendrecv', ...
                                        this.stationID, ...
                                        dataOut, ...
                                        dataInAmount, ...
                                        this.getTimeoutRecvSecs);          
        end              
        
        function initCommunications(this)
            
            delay = 0;
            deltaT = 0.5;
            initialized = false;
            while ~initialized && (delay <= this.timeout)
                this.stationID = rtiostream_wrapper(this.rtiostreamLib,'open',...
                                                    this.openRtIOStreamArgList{:});
                if ( this.stationID <0 )
                    pause(deltaT);
                    delay = delay + deltaT;
                else
                    initialized = true;
                end
            end 
            if ( this.stationID <0 )
                rtw.connectivity.ProductInfo.error('target', 'ErrorOpeningChannel');
            end
        end        
        
        function closeCommunications(this)
            retVal = rtiostream_wrapper(this.rtiostreamLib,'close',this.stationID);

            if (retVal  ~= 0)
                rtw.connectivity.ProductInfo.error('target', 'ErrorClosingChannel');
            end

        end
        
        function stationID = getStationID(this)
            stationID = this.stationID;
        end
        
        function rtIOStreamLib = getRtIOStreamLib(this)
            rtIOStreamLib = this.rtiostreamLib;
        end
        
        function timeoutRecvSecs = getTimeoutRecvSecs(this)
            timeoutRecvSecs = this.timeoutRecvSecs;
        end
    end
end
