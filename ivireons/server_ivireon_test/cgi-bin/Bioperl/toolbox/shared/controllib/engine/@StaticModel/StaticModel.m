classdef StaticModel < InputOutputModel
% Static Model (Numeric Array abstraction).
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:12 $
   
   %%%%%%%%%%%%%%% DATA ABSTRACTION INTERFACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   methods (Hidden)
      % MISC GENERAL
      A = double_(M)
      
      function sys = frd(M,varargin) %#ok<*STOUT>
         ctrlMsgUtils.error('Control:ltiobject:frd3',class(M))
      end
      
      % Needed to correctly redirect OP(StaticModel,DynamicModel)
      [sys1,varargout] = feedback(sys1,sys2,varargin)
      [sys,SingularFlag] = connect(varargin)
      sys = series(sys1,sys2,varargin)
      sys = parallel(sys1,sys2,varargin)
   end
   %%%%%%%%%%%%%%% END DATA ABSTRACTION INTERFACE %%%%%%%%%%%%%%%%%%%%%%%%%
   
   
   % PUBLIC METHODS
   methods
                  
      function boo = isstatic(~)
         %ISSTATIC  Checks if model is static or dynamic.
         %
         %   ISSTATIC(M) returns TRUE if the model M is static and FALSE if
         %   M has dynamics (states or delays).
         %
         %   For arrays of models, ISSTATIC(M) is true if all models in the
         %   array are static.
         %
         %   See also POLE, ZERO, HASDELAY, DYNAMICSYSTEM, STATICMODEL.
         boo = true;
      end
         
      function M = uminus(M)
         %UMINUS  Unary minus for static models.
         %
         %   MM = UMINUS(M) is invoked by MM = -M.
         %
         %   See also MINUS.
         try
            M = uminus_(M);
         catch E
            ltipack.throw(E,'expression','-SYS','SYS',class(M))
         end
      end
      
      function M = uplus(M)
         %UPLUS  Unary plus for static models.
         %
         %   See also UMINUS.
      end
      
      function M = minus(M1,M2)
         %MINUS  Subtraction for static models.
         %
         %   M = MINUS(M1,M2) is invoked by M=M1-M2.
         %
         %   See also PLUS, UMINUS.
         M = M1 + (-M2);
      end
      
      function M = genmat(M)
         %GENMAT  Converts static model to generalized matrix type.
         %
         %   M = GENMAT(M) converts the static model M to a generalized matrix.
         %
         %   See also GENMAT, STATICMODEL.
         try
            M = genmat_(M);
         catch E
            throw(E)
         end
      end
      
      function M = umat(M)
         %UMAT  Converts static model to uncertain matrix.
         %
         %   UM = UMAT(M) converts the static model M to an uncertain matrix.
         %   All blocks in M that do not represent uncertainty are replaced 
         %   by their current value and UM contains only uncertain blocks.
         %
         %   See also UMAT, UNCERTAINBLOCK, STATICMODEL, GENMAT.
         try
            M = umat_(M);
         catch E
            throw(E)
         end
      end
      
      function sys = genss(M)
         %GENSS  Converts static model to generalized state-space.
         %
         %   SYS = GENSS(M) converts the static model M to a generalized state-space
         %   model SYS with no states.
         %
         %   See also GENSS, GENMAT, STATICMODEL.
         try
            sys = genss_(M);
         catch E
            throw(E)
         end
      end
      
      function sys = uss(M)
         %USS  Converts static model to uncertain state-space.
         %
         %   SYS = USS(M) converts the static model M to an uncertain state-space
         %   model SYS with no states. All blocks in M that do not represent 
         %   uncertainty are replaced by their current value and SYS contains 
         %   only uncertain blocks.
         %
         %   See also USS, UMAT, UNCERTAINBLOCK, STATICMODEL, GENSS.
         try
            sys = uss_(M);
         catch E
            throw(E)
         end
      end
      
      function sys = genfrd(varargin)
         %GENFRD  Converts static model to generalized FRD model.
         %
         %   SYS = GENFRD(M,FREQS,UNIT) converts the static model M to a generalized
         %   FRD (GENFRD) model. The frequency points FREQS are expressed in the unit 
         %   specified by the string UNIT ('rad/s' or 'Hz'). The default is 'rad/s' 
         %   if UNIT is omitted.
         %
         %   See also GENFRD, CHGUNITS, STATICMODEL.
         try
            [M,w,unit] = FRDModel.parseFRDInputs('genfrd',varargin);
            sys = genfrd_(M,w,unit);
         catch E
            throw(E)
         end
      end
      
      function sys = ufrd(varargin)
         %UFRD  Converts static model to uncertain FRD model.
         %
         %   SYS = GENFRD(M,FREQS,UNIT) converts the static model M to an uncertain
         %   FRD (UFRD) model. The frequency points FREQS are expressed in the unit
         %   specified by the string UNIT ('rad/s' or 'Hz'). The default is 'rad/s'
         %   if UNIT is omitted. All blocks in M that do not represent uncertainty 
         %   are replaced by their current value and SYS contains only uncertain 
         %   blocks.
         %
         %   See also UFRD, CHGUNITS, STATICMODEL.
         try
            [M,w,unit] = FRDModel.parseFRDInputs('ufrd',varargin);
            sys = ufrd_(M,w,unit);
         catch E
            throw(E)
         end
      end
      
   end
   
   % PROTECTED METHODS
   methods (Access = protected)
      
      M = subparen(M,indices)
      M = indexasgn(M,indices,rhs)

   end
   
end
   
