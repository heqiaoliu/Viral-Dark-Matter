classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) stabsep < ltioptions.StableUnstableDecomposition
    % Options set for the STABSEP command.
    
    % Author: P. Gahinet
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:45 $
    
    properties
        % Focus of stable/unstable decomposition [{'stable'} | 'unstable']
        %
        % The option specifies whether the first output of STABSEP should contain only 
        % stable dynamics (default) or only unstable dynamics. When "Focus" is set to 
        % 'unstable', the unstable region consists of the complex numbers such that
        %    Continuous time:   Re(s) >  Offset * max(1,|Im(s)|)
        %    Discrete time:      |z|  > 1 + Offset
        Focus = 'stable';
    end
    
    
    properties (Dependent, Hidden)
       % Obsolete STABSEP option
       Mode  % Mode=1,2 <=> Focus = 'stable','unstable'
    end
    
    methods
        
       function this = stabsep()
          % Constructor
          this = this@ltioptions.StableUnstableDecomposition();
          this.Offset = 0;  % default for STABSEP
       end
       
       function this = set.Focus(this,value)
          % SET method for Focus option
          F = ltipack.matchKey(value,{'stable','unstable'});
          if isempty(F)
             ctrlMsgUtils.error('Control:transformation:stabsep6',getCommandName(this))
          else
             this.Focus = F;
          end
       end
       
       function this = set.Mode(this,value)
          % SET method for obsolete MODE option
          if ~(isnumeric(value) && isscalar(value) && any(value==[1 2]))
             ctrlMsgUtils.error('Control:transformation:stabsep4')
          end
          EnumList = {'stable','unstable'};
          this.Focus = EnumList{value};
       end
       
       function boo = wantStable(this)
          boo = (this.Focus(1)=='s');  % for STABSEP support
       end
    end
    
    methods (Access = protected)
       function cmd = getCommandName(~)
          cmd = 'stabsep';
       end       
    end
    
end