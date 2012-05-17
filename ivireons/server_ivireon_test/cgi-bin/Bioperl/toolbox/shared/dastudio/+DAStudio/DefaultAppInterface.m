classdef DefaultAppInterface < DAStudio.AbstractAppInterface    
    methods
        function self = DefaultAppInterface()
            self = self@DAStudio.AbstractAppInterface();
            
            self.addDomain( 'DAS.Domain', DAStudio.DomainInterface );
        end
    end
end
