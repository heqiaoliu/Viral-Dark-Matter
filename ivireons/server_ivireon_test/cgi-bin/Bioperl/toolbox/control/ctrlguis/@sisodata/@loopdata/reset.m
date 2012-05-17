function reset(this,Scope,C)
% Cleans up dependent data when core data changes.
%
%   RESET(this,'all')
%   RESET(this,'root',C)
%   RESET(this,'gain',C)
%   RESET(this,'ol',C)

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2008/10/02 18:38:07 $

switch Scope
   case 'all'
       % Clear all dependent data
       this.ClosedLoop = [];
       % Set gain to [] as dirty indicator
       for ct = 1:length(this.C)
           this.C(ct).reset('all');
       end
       for ct=1:length(this.L)
           % Clear open-loop data
           this.L(ct).reset(Scope);
       end
      
   case 'root'
      % Modified poles or zeros of C-th tuned model
      this.ClosedLoop = [];
      C.reset('all')
      % Clear open-loop data that depends on C
      for ct=1:length(this.L)
         % Clear open-loop data
         this.L(ct).reset(Scope,C); 
      end
      
   case 'gain'
      % Modified gain of C-th tuned model
      C.reset('gain')
      this.ClosedLoop = [];
      % Clear other open-loop models whose "plant" depends on C
      for ct=1:length(this.L)
         this.L(ct).reset(Scope,C);
      end
      
    case 'compensator'
        % Modified C-th tuned model
        C.reset('all')
        this.ClosedLoop = [];
        % Clear other open-loop models whose "plant" depends on C
        for ct=1:length(this.L)
            this.L(ct).reset(Scope,C);
        end
      
      
   case 'cl'
      % Clear closed-loop model (e.g., when changing LoopStatus)
      this.ClosedLoop = [];

end