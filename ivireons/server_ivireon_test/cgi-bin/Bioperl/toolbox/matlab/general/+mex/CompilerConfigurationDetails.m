classdef CompilerConfigurationDetails
% CompilerConfigurationDetails class encapsulates detailed information used
% by MEX.
%
% See also MEX MEX.getCompilerConfigurations 

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:12:20 $

    properties( SetAccess=private )
        CompilerExecutable
        CompilerFlags
        OptimizationFlags
        DebugFlags
        LinkerExecutable
        LinkerFlags
        LinkerOptimizationFlags
        LinkerDebugFlags
    end %Properties

    methods
        function CCD = CompilerConfigurationDetails(detailsStruct)
        %
        
        % CompilerConfigurationDetails constructor
        %   CompilerConfigurationDetails(detailsStruct) creates
        %   CompilerConfigurationDetails from detailsStruct that contains
        %   the values of its properties.
        %
        %   See help for MEX.getCompilerConfigurations for more information.
        %
        % See also MEX MEX.getCompilerConfigurations
        % MEX.CompilerConfiguration MEX.CompilerConfigurationDetails
        
        CCD.CompilerExecutable = detailsStruct.CompilerExecutable;
        CCD.CompilerFlags = detailsStruct.CompilerFlags;
        CCD.OptimizationFlags = detailsStruct.OptimizationFlags;
        CCD.DebugFlags = detailsStruct.DebugFlags;
        CCD.LinkerExecutable = detailsStruct.LinkerExecutable;
        CCD.LinkerFlags = detailsStruct.LinkerFlags;
        CCD.LinkerOptimizationFlags = detailsStruct.LinkerOptimizationFlags;
        CCD.LinkerDebugFlags = detailsStruct.LinkerDebugFlags;
        end
    end %Methods

end %Classdef