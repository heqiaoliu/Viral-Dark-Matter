classdef CompilerConfiguration
% CompilerConfiguration class encapsulates information used by MEX.
%
% See also MEX MEX.getCompilerConfigurations

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:12:19 $

    properties( SetAccess=private )
        Name
        Manufacturer
        Language
        Version
        Location
        Details
    end

    methods
        function CC = CompilerConfiguration(basicStruct,ccDetails)
        %
        
        % CompilerConfiguration constructor
        %   CompilerConfiguration(basicStruct,ccDetails) creates
        %   CompilerConfiguration from basicStruct that contains the values
        %   of its properties and a MEX.CompilerConfigurationDetails object
        %   ccDetails.
        %
        %   See help for MEX.getCompilerConfigurations for more information.
        %
        % See also MEX MEX.getCompilerConfigurations
        % MEX.CompilerConfiguration MEX.CompilerConfigurationDetails
            CC.Name = basicStruct.Name;
            CC.Manufacturer = basicStruct.Manufacturer;
            CC.Language = basicStruct.Language;
            CC.Version = basicStruct.Version;
            CC.Location = basicStruct.Location;
            CC.Details = ccDetails;
        end
    end

end