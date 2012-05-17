function parser = commonCornerInputParser(clientName)
%commonCornerInputParser Create input parser for corner detection functions.
%   PARSER = commonCornerInputParser(CLIENTNAME) takes a string CLIENTNAME
%   that specifies the name of the client function who will use the
%   returned inputParser object PARSER.
%
%   PARSER is an inputParser object that is set up to parse the input
%   arguments and property/value pairs that are common to CORNERMETRIC and
%   CORNER.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 03:49:12 $

% setup parser
parser = inputParser;
parser.addRequired('Image',@checkImage);
parser.addOptional('Method','Harris',@checkMethod);
parser.addParamValue('SensitivityFactor','0.04',@checkSensFactor);
parser.addParamValue('FilterCoefficients',...
    fspecial('gaussian',[1 5],1.5),@checkFiltCoef);

%--------------------------
    function tf = checkImage(I)
        validateattributes(I,{'numeric','logical'},{'2d','nonempty',...
            'nonsparse','real'},clientName,'I',1);
        tf = true;
    end

%---------------------------
    function tf = checkMethod(m)
        validatestring(m,{'Harris','MinimumEigenvalue'},clientName,...
            'Method',2);
        tf = true;
    end


%-------------------------------
    function tf = checkSensFactor(x)
        validateattributes(x,{'numeric'},{'nonempty','nonnan','real',...
            'scalar'},clientName,'SensitivityFactor');
        
        if (x <= 0 || x >=0.25)
            eid = sprintf('Images:%s:invalidSensitivityFactor',clientName);
            error(eid,' ''SensitivityFactor'' must be in the range (0,0.25). ');
        end
        
        tf = true;
    end

%-----------------------------
    function tf = checkFiltCoef(x)
        validateattributes(x,{'numeric'},{'nonempty','nonnan','real',...
            'vector'},clientName,'FilterCoefficients');
        
        % verify odd number of values
        if mod(numel(x),2) == 0
            eid = sprintf('Images:%s:invalidFilterCoefficients',clientName);
            error(eid,'%s',['''FilterCoefficients'' must contain an odd number '...
                'of elements.']);
        end
        tf = true;
    end

end