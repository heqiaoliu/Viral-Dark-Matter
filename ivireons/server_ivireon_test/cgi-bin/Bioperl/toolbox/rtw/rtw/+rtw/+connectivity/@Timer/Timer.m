classdef Timer
%   The class Timer specifies the timer infrastructure that can 
%   be used by any application on a target or host to extract timing information.
%
%   TIMER(DATATYPE,SOURCEFILE,SECONDSPERTICK,TIMERFUNCTION,HEADERFILE,TARGETAPPLICATIONFRAMEWORK)
%   Instantiates a TIMER object that gets timing information 
%   from the application running on a target or a host.
%
%   You must make a subclass of TIMER and pass the required arguments 
%   to the TIMER super class
%
%   See also RTW.CONNECTIVITY.CONFIG

%   Copyright 2009 The MathWorks, Inc.

    %protected properties
    properties(SetAccess = 'private' , GetAccess = 'private')
        TimerDataType; % data type returned by the timer function.
        SecondsPerTick; % number of nano seconds per clock tick
        HeaderFile; % header file to be included
        TimerFunction; % timer function to be called.
    end
    
    properties (Constant = true)
        ValidDataTypes = {'int8_T', 'uint8_T', 'int16_T', 'uint16_T',...
                          'int32_T', 'uint32_T', 'int64_T', 'uint64_T', 'double'};
    end
    
    methods
        % constructor
        function this = Timer(timerDataType, timerSourceFile,...
                              secondsPerTick, timerFunction,...
                              headerFile, targetApplicationFramework)
                          
            rtw.connectivity.Utils.validateTimerDataType(timerDataType,...
                                           rtw.connectivity.Timer.ValidDataTypes);
            this.TimerDataType = timerDataType;                                       
            this.SecondsPerTick = secondsPerTick;
            this.HeaderFile = headerFile;
            this.TimerFunction = timerFunction;
            this.updateBuildInfo(timerSourceFile, targetApplicationFramework);
        end
    end
    
    methods (Sealed = true)
        % get the data type 
        function timerDataType = getDataType(this)
            error(nargchk(1, 1, nargin, 'struct'));
            timerDataType = this.TimerDataType;
        end
        
        % get number of nano seconds per clock tick
        function secondsPerTick = getSecondsPerTick(this)
            error(nargchk(1, 1, nargin, 'struct'));
            secondsPerTick = this.SecondsPerTick;
        end
        
        % get header file
        function headerFile = getHeaderFile(this)
            error(nargchk(1, 1, nargin, 'struct'));
            headerFile = this.HeaderFile;
        end
        
        % get timer function
        function timerFunc = getTimerFunction(this)
            error(nargchk(1, 1, nargin, 'struct'));
            timerFunc = this.TimerFunction;
        end
    end
    
    methods (Access = 'private')
        % update buildInfo
        function updateBuildInfo(this, timerSourceFile,...
                                 targetApplicationFramework)
            buildInfo = targetApplicationFramework.getBuildInfo;
            % add source file to buildInfo
            [sp sf se] = fileparts(timerSourceFile);
            buildInfo.addSourceFiles([sf se], sp);
            % add include file to buildInfo
            [p f e] = fileparts(this.HeaderFile);
            buildInfo.addIncludeFiles([f e], p);
            % add include file path to buildInfo
            buildInfo.addIncludePaths(p);
        end
    end
end

