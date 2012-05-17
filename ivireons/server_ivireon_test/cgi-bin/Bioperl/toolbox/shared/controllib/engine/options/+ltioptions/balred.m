classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) balred < ltioptions.hsvd
    % Options set for the BALRED command.
    
    % Author: P. Gahinet
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:37 $    
    properties
        % State elimination method [{'MatchDC'} | 'Truncate']
        %
        % This option specifies how to eliminate the weakly coupled states 
        % (states with smallest Hankel singular values). The "MatchDC" method 
        % alters the remaining states to preserve the DC gain while the 
        % "Truncate" method just discards the weakly coupled states.
        % The "Truncate" method tends to produce a better approximation in  
        % the frequency domain, but the DC gains are not guaranteed to match.
        StateElimMethod = 'MatchDC';
    end
        
    properties (Dependent, Hidden)
       % Pre-R2010a: 'Elimination' option
       Elimination
    end
       
    methods
               
       function this = set.StateElimMethod(this,value)
          % SET method for ElimMethod option
          SEM = ltipack.matchKey(value,{'MatchDC','Truncate'});
          if isempty(SEM)
             ctrlMsgUtils.error('Control:transformation:balred4',getCommandName(this))
          else
             this.StateElimMethod = SEM;
          end
       end
       
       function value = get.Elimination(this)
          value = this.StateElimMethod;
       end
       
       function this = set.Elimination(this,value)
          this.StateElimMethod = value;
       end
              
       function boo = wantStable(~)
          boo = true;  % for STABSEP support
       end
    end
    
    
    methods (Access = protected)
       function cmd = getCommandName(~)
          cmd = 'balred';
       end       
    end
    
end