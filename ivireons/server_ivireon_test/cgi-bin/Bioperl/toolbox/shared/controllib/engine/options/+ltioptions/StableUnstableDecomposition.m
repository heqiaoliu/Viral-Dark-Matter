classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) StableUnstableDecomposition < ltioptions.Generic
    % Options set for stable/unstable decomposition.
    
    % Author: P. Gahinet
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:36 $
    
    properties
        % Maximum absolute error in stable/unstable decomposition (default = 0).
        %
        % The "AbsTol" and "RelTol" tolerances control the accuracy of the stable/unstable 
        % decomposition G -> GS + GU. Specifically, the frequency responses of G and 
        % GS+GU differ by no more than AbsTol + RelTol * abs(G). Increasing these 
        % tolerances helps separate nearby stable and unstable modes at the expense 
        % of accuracy.
        AbsTol = 0;
        
        % Maximum relative error in stable/unstable decomposition (default = 1e-8).
        %
        % The "AbsTol" and "RelTol" tolerances control the accuracy of the stable/unstable 
        % decomposition G -> GS + GU. Specifically, the frequency responses of G and 
        % GS+GU differ by no more than AbsTol + RelTol * abs(G). Increasing these 
        % tolerances helps separate nearby stable and unstable modes at the expense 
        % of accuracy.
        RelTol = 1e-8;
        
        % Offset for the stable/unstable boundary.
        %
        % In the stable/unstable decomposition, the stable term includes only poles 
        % satisfying
        %    Continuous time:   Re(s) < -Offset * max(1,|Im(s)|)
        %    Discrete time:      |z|  < 1 - Offset
        % Increase the value of "Offset" to treat poles close to the stability boundary
        % as unstable.
        Offset;
    end

    methods
        
        function this = set.AbsTol(this,value)
           % SET method for AbsTol option
           if ~(isnumeric(value) && isscalar(value) && isreal(value) && value>=0)
              ctrlMsgUtils.error('Control:transformation:stabsep3',getCommandName(this))
           end
           this.AbsTol = double(value);
        end
        
        function this = set.RelTol(this,value)
           % SET method for RelTol option
           if ~(isnumeric(value) && isscalar(value) && isreal(value) && value>=0 && value<=1)
              ctrlMsgUtils.error('Control:transformation:stabsep2',getCommandName(this))
           end
           this.RelTol = double(value);
        end
        
        function this = set.Offset(this,value)
           % SET method for Offset option
           if ~(isnumeric(value) && isscalar(value) && isreal(value))
              ctrlMsgUtils.error('Control:transformation:stabsep5',getCommandName(this))
           end
           this.Offset = double(value);
        end
        
        function boo = wantStable(~)
           boo = true;  % for STABSEP support
        end
    end
    
end