classdef ParametricBlock < ControlDesignBlock
   % Parametric Control Design Blocks.
   %
   %   Parametric Control Design Blocks provide parameterizations of basic
   %   control system components such as gains, transfer functions, PIDs, 
   %   and state-space models. Use these blocks to model the tunable portion
   %   of your control system. You can then automatically tune the block 
   %   parameters with commands like HINFSTRUCT in the Robust Control Toolbox.
   %
   %   All parametric Control Design Blocks derive from the @ParametricBlock
   %   superclass. This class is not user-facing and cannot be instantiated. 
   %   User-facing subclasses of @ParametricBlock include ltiblock.gain, 
   %   ltiblock.tf, ltiblock.pid, and ltiblock.ss.
   %
   %   See also LTIBLOCK.GAIN, LTIBLOCK.PID, LTIBLOCK.SS, LTIBLOCK.TF, 
   %   CONTROLDESIGNBLOCK, LTI/HINFSTRUCT.
   
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/05/10 16:58:06 $
   
   %% PARAMETRICBLOCK INTERFACE
   methods (Abstract, Access = protected)
      % Serializes param.Continuous objects
      np = nparams_(blk,varargin)
      p = getp_(blk,varargin)
      blk = setp_(blk,p,varargin)
      isf = isfree_(blk)
      p = randp_(blk,varargin)
   end
   
   %% PUBLIC METHODS
   methods
      
      function boo = isParametric(~)
         boo = true;
      end
            
      function np = nparams(blk,varargin)
         %NPARAMS  Number of block parameters.
         %
         %   NP = NPARAMS(BLK) returns the total number NP of parameters used 
         %   in the parametric block BLK. This number includes both free and 
         %   fixed parameters.
         %
         %   NPF = NPARAMS(BLK,'free') returns the number of free parameters.
         %
         %   See also GETP, SETP, RANDP, ISFREE, PARAMETRICBLOCK.
         np = nparams_(blk,varargin{:});
      end
      
      
      function isf = isfree(blk)
         %ISFREE  True for free block parameters.
         %
         %   ISF = ISFREE(BLK) returns a logical vector ISF with as many
         %   entries as parameters in the parametric block BLK. The j-th
         %   entry of ISF is true if the j-th parameter is free and 
         %   is false if the j-th parameter is fixed.
         %
         %   See also GETP, SETP, PARAMETRICBLOCK.
         isf = isfree_(blk);
      end
      
      
      function p = getp(blk,varargin)
         %GETP  Gets block parameter values.
         %
         %   P = GETP(BLK) returns the vector of current parameter values for the
         %   parametric block BLK. Both fixed and free parameters are included.
         %
         %   X = GETP(BLK,'free') returns the values of free parameters only.
         %   The vector X is the same as P(ISFREE(BLK)).
         %
         %   See also SETP, NPARAMS, ISFREE, PARAMETRICBLOCK.
         p = getp_(blk,varargin{:});
      end
      
      function blk = setp(blk,p,varargin)
         %SETP  Sets block parameter values.
         %
         %   BLK = SETP(BLK,P) sets the parameters of the parametric block BLK to
         %   the values specified in the vector P. The length of P must match the
         %   total number of parameters NPARAMS(BLK). 
         %
         %   BLK = SETP(BLK,X,'free') only sets the free parameters. The remaining
         %   parameters are held at their current value. The length of X must match 
         %   the number of free parameters.
         %
         %   See also GETP, NPARAMS, ISFREE, PARAMETRICBLOCK.
         try
            blk = setp_(blk,p,varargin{:});
         catch ME
            throw(ME)
         end
      end 
      
      function P = randp(blk,varargin)
         %RANDP  Generates random samples of block parameters.
         %
         %   P = RANDP(BLK,N) generates N random samples of the parametric
         %   Control Design block BLK. The output P is a matrix where P(:,j) 
         %   is the j-th sample value of the parameter vector. Both fixed 
         %   and free parameters are sampled.
         %
         %   X = RANDP(BLK,N,'free') samples only the free parameters in BLK.
         %   The resulting matrix X has N columns and as many rows as free
         %   parameters.
         %
         %   Use SETP to set the current value of BLK to any of these random
         %   parameter samples.
         %
         %   See also GETP, SETP, NPARAMS, PARAMETRICBLOCK.
         try
            P = randp_(blk,varargin{:});
         catch ME
            throw(ME)
         end
      end
      
   end 
      
   
end
