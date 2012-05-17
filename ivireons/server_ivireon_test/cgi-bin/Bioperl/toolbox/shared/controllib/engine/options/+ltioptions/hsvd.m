classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) hsvd < ltioptions.StableUnstableDecomposition
    % Options set for the HSVD command.
    
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:42 $
    
    methods
       function this = hsvd()
          % Constructor
          this = this@ltioptions.StableUnstableDecomposition();
          this.Offset = 1e-8;  % default for HSVD
       end 
    end
    
    methods (Access = protected)
       function cmd = getCommandName(~)
          cmd = 'hsvd';
       end       
    end
    
end