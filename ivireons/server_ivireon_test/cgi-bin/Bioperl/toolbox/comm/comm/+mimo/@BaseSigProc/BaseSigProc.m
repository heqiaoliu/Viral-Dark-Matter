classdef BaseSigProc < mimo.BaseClass
    %BaseSigProc definition for MIMO package
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:10:56 $
    
    
    %===========================================================================
    % Protected properties
    properties (SetAccess = protected, GetAccess = protected)
        % Private data in structure (for fast porting to C-MEX).
        % No special data types allowed here (so it can be read by C).
        % See basesigproc_initprivatedata.
        PrivateData = struct('NumSampOutput',0, 'UseStats', 0);
    end
    
    %===========================================================================
    % Protected Transient properties
    properties (SetAccess = protected, GetAccess = protected, Dependent)
        % Number of samples output
        NumSampOutput
        % Flag to indicate whether to store statistics
        UseStats = 0;
    end
    
    %===========================================================================
    % Public methods
    methods
        function h = BaseSigProc
            %BASESIGPROC  Construct a base signal processing object.
            
            h.basesigproc_initprivatedata;
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = protected)
        function basesigproc_initprivatedata(h)
            pd = h.PrivateData;
            
            pd.NumSampOutput = 0;
            pd.UseStats = 0;
            
            h.PrivateData = pd;
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.NumSampOutput(s, u)
            s.PrivateData.NumSampOutput = u;
        end
        %-----------------------------------------------------------------------
        function u = get.NumSampOutput(s)
            if isfield(s.PrivateData,'NumSampOutput')
                u = s.PrivateData.NumSampOutput;
            end
        end
        %-----------------------------------------------------------------------
        function set.UseStats(s, u)
            s.PrivateData.UseStats = u;
        end
        %-----------------------------------------------------------------------
        function u = get.UseStats(s)
            if isfield(s.PrivateData,'UseStats')
                u = s.PrivateData.UseStats;
            end
        end
    end
end
% EOF