classdef (Hidden = true) BullseyeCoverage < handle
%BULLSEYECOVERAGE supports integration of BullseyeCoverage

%   Copyright 2010 The MathWorks, Inc.
    
    methods (Access=public, Static=true)
        
        function setPath(bullseyePath)
            bullseyeObj = rtw.pil.Bullseye;
            bullseyeObj.setToolPath(bullseyePath);
        end
        
        function bullseyePath = getPath
            bullseyeObj = rtw.pil.Bullseye;
            bullseyePath = bullseyeObj.getToolPath;
        end
        
    end
end
