classdef (Hidden = true) AutosarSfunction < rtw.pil.PILBlockSfunction
%AUTOSARSFUNCTION creates PIL host-side s-function for AUTOSAR Target
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.       
    
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
    
    methods
        % constructor        
        function this = AutosarSfunction(codeInfo, ...
                sfunSourcePath, ...
                sfunOutDir, ...
                pilInterface, ...
                infoStruct)
            error(nargchk(5, 5, nargin, 'struct'));
            % call super class constructor
            this@rtw.pil.PILBlockSfunction(codeInfo, ...
                sfunSourcePath, ...
                sfunOutDir, ...
                pilInterface, ...
                infoStruct);            
        end                
    end
    
    methods (Access = 'protected')
        function initCodeInfoUtils(this, codeInfo)
            % create the codeInfoUtils object            
            this.codeInfoUtils = rtw.connectivity.AutosarCodeInfoUtils(codeInfo);
        end
    end
end