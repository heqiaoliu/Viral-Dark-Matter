classdef (SupportClassFunctions=true) InputOutputModel
   % Input/Output Model objects.
   %
   %   Input/output models describe the static or dynamic behavior of a  
   %   system or system component. They are similar to the concept of "block"  
   %   or "block diagram" in Simulink. Examples of input/output models  
   %   include static gains, static nonlinearities (e.g., saturation), and  
   %   linear systems (e.g., transfer function).
   %
   %   All input/output model objects in Control System Toolbox derive from 
   %   the @InputOutputModel base class. This class is not user-facing and 
   %   cannot be instantiated. User-facing subclasses of @InputOutputModel 
   %   include:
   %     * LTI models (@tf, @ss, @pid, @frd, ...)
   %     * Control Design blocks (ltiblock.ss, ltiblock.pid,...).
   %
   %   See also LTI, CONTROLDESIGNBLOCK.
   
   %   Author(s): P. Gahinet
   %   Copyright 2009-2010 The MathWorks, Inc.
   %   $Revision: 1.1.8.3.2.1 $ $Date: 2010/06/24 19:43:26 $
   
   properties (Access = protected)
      % IOSize_ = [ny nu]
      IOSize_
      % Version
      Version_ = ltipack.ver();
   end
   
   %% ABSTRACT METHODS
   methods (Abstract, Access = protected)
      % Characteristics
      displaySize(M,sizes) % display for "size(M)"
   end
      
   %% DATA ABSTRACTION INTERFACE 
   % This interface is designed so that:
   % 1) User-facing methods have a single implementation in some
   %    easily recognizable class (@InputOutputModel, @StaticModel, 
   %    @DynamicSystem, @FRDModel, or @StateSpaceModel)
   % 2) The input parsing and error checking for user-facing methods
   %    is never duplicated.
   % Calls to a public method "foo" typically delegate all computations to
   % a protected method "foo_" that is implemented by appropriate subclasses. 
   % The method "foo_" acts as an adaptor between the user-facing, 
   % class-independent API and the low-level algorithms and data classes.
   methods (Access = protected)
      %% MODEL CHARACTERISTICS
      boo = isfinite_(M)
      function boo = isreal_(~)
         boo = true;
      end
      function boo = isstatic_(~)
         boo = true;
      end
      function boo = hasdelay_(~)
         boo = false;
      end
      function boo = hasInternalDelay_(~)
         boo = false;
      end
      
      %% CONVERSIONS
      % Note: metadata is not transferred
      M = double_(M)
      M = ss_(M,optflag)
      M = tf_(M)
      M = zpk_(M)
      M = frd_(M,freq,unit)
      M = pid_(M,Options)
      M = pidstd_(M,Options)
      M = genmat_(M)
      M = genss_(M)
      M = genfrd_(M,freq,unit)
      M = umat_(M)
      M = uss_(M)
      M = ufrd_(M,freq,unit)

      %% BINARY OPERATIONS, TO BE IMPLEMENTED BY "COMBINABLE" SUBCLASSES
      % Note: op_ is never called for class X if X.isCombinable(op) is false
      M = iocat_(dim,M,M2)
      M = append_(M,M2)
      M = stack_(arraydim,M,M2)
      [M1,SingularFlag] = lft_(M1,M2,indu1,indy1,indu2,indy2)
      [M1,SingularFlag] = feedback_(M1,M2,indu,indy,sign)
      M1 = plus_(M1,M2)
      M1 = mtimes_(M1,M2,ScalarFlags)
      M1 = times_(M1,M2,ScalarFlags)
      M1 = mldivide_(M1,M2)
      M1 = mrdivide_(M1,M2)
      function M = addNumeric(M,A)
         % Default implementation of M + NUMERIC ARRAY for non-combinable M
         M = feval(M.toCombinable(),M) + A;
      end
      function M = rightMultiplyByNumeric(M,A)
         % Default implementation of M * NUMERIC ARRAY for non-combinable M
         M = feval(M.toCombinable(),M) * A;
      end
      function M = leftMultiplyByNumeric(M,A)
         % Default implementation of NUMERIC ARRAY * M for non-combinable M
         M = A * feval(M.toCombinable(),M);
      end
      function boo = hasSimpleInverse_(~)
         % Default implementation
         boo = false;
      end
      function [M1,M2] = matchAttributes(M1,M2)
         % Default implementation: no-op
      end
      function varargout = matchAttributesN(varargin)
         % Default implementation: no-op
         varargout = varargin;
      end

      %% INDEXING AND ARRAY MANIPULATIONS
      % Indexing
      M = createLHS(rhs)
      M = indexref_(M,indrow,indcol,ArrayIndices)
      M = indexdel_(M,indices)
      M = indexasgn_(M,indices,rhs,ioSize,ArrayMask)
      [M1,M2] = matchArraySize(M1,M2)
      varargout = matchArraySizeN(varargin)
      function s = getArraySize(~)
         % Default model array size 
         s = [1 1];
      end
      function M = permute_(M,~)
         % Default = no-op
      end
      function M = reshape_(M,~)
         % Default = no-op
      end
      
      %% TRANSFORMATIONS
      M = uminus_(M)
      M = conj_(M)
      M = transpose_(M)
      M = ctranspose_(M)
      M = inv_(M)
      M = mpower_(M,k)
      M = replaceB2V_(M,BlockValues)

   end
   
   methods
      
      % Default implementations
      function boo = isParametric(~)
         boo = false;
      end
      function boo = isLinear(~)
         boo = true;
      end
      function boo = isUncertain(~)
         boo = false;
      end

      function n = nmodels(M)
         %NMODELS  Returns number of models in model array.
         %
         %   N = NMODELS(M) returns the number of models, N, in the array M
         %   of static or dynamic models.
         %
         %   See also SIZE, NDIMS, INPUTOUTPUTMODEL.
         n = prod(getArraySize(M));  % generic definition
      end
      
      function [ny,nu] = iosize(M)
         %IOSIZE  I/O size of input/output model.
         %
         %   [NY,NU] = IOSIZE(M) returns the number of inputs NU and the 
         %   number of outputs NY of the model M. For static models, NY
         %   and NU correspond to the number of rows and columns in M.
         %
         %   S = IOSIZE(M) returns S = [NY NU].
         %
         %   See also SIZE, INPUTOUTPUTMODEL.
         ios = M.IOSize_;
         if nargout<2
            ny = ios;
         else
            ny = ios(1);  nu = ios(2);
         end
      end
      
      function n = ndims(M)
         %NDIMS  Number of dimensions in model array.
         %
         %   N = NDIMS(M) returns the number of dimensions in the array M
         %   of input/output models. A single model has two dimensions 
         %   (outputs and inputs, rows and columns). An array of models has 
         %   N=2+p dimensions, where p>=2 is the number of array dimensions. 
         %   For example, a 2-by-3-by-4 array of systems has 2+3=5 dimensions.
         %
         %   See also SIZE, INPUTOUTPUTMODEL. 
         n = length(size(M));
      end
      
      function boo = issiso(M)
         %ISSISO  True for SISO input/output models.
         %
         %   ISSISO(M) returns true if M is a single-input, single-output 
         %   (SISO) model or model array, and false otherwise.
         %
         %   See also IOSIZE, SIZE, ISEMPTY, INPUTOUTPUTMODEL.
         boo = all(M.IOSize_==1);
      end
      
      function boo = isempty(M)
         %ISEMPTY  True for empty input/output model.
         %
         %   ISEMPTY(M) returns true if the model M has no inputs or no outputs 
         %   and false otherwise. For FRD models, ISEMPTY(M) also returns true 
         %   when the frequency vector is empty.
         %
         %   For model arrays, ISEMPTY(M) is true if the array is empty or if
         %   the models themselves are empty.
         %
         %   See also SIZE, IOSIZE, INPUTOUTPUTMODEL. 
         boo = any(size(M)==0) || (isa(M,'FRDModel') && isempty(M.Frequency));
      end
      
      function boo = isstatic(M)
         %ISSTATIC  Checks if input/output model is static or dynamic.
         %
         %   ISSTATIC(M) returns TRUE if the model M is static and FALSE if
         %   M has dynamics (states or delays).
         %
         %   For arrays of models, ISSTATIC(M) is true if all models in the
         %   array are static.
         %
         %   See also POLE, ZERO, HASDELAY, INPUTOUTPUTMODEL.
         boo = isstatic_(M);
      end
         
      function boo = hasdelay(M)
         %HASDELAY  True for dynamic systems with time delays.
         %
         %   HASDELAY(M) returns TRUE if the input/output model M has input,
         %   output, or internal delays, and FALSE otherwise.
         %
         %   See also SS/GETDELAYMODEL, DELAY2Z, INPUTOUTPUTMODEL.
         boo = hasdelay_(M);
      end
      
      function boo = hasInternalDelay(M)
         % True for dynamic systems with internal delays.
         %
         %   See also SS/GETDELAYMODEL, HASDELAY, DYNAMICSYSTEM.
         boo = hasInternalDelay_(M);
      end
      
      function boo = isreal(M)
         %ISREAL  True for models with real-valued coefficients.
         %
         %   ISREAL(M) returns TRUE if the input/output model M has real-valued 
         %   coefficients and FALSE otherwise.
         %
         %   See also ISFINITE, INPUTOUTPUTMODEL.
         boo = isreal_(M);
      end
            
      function boo = isfinite(M)
         %ISFINITE  Checks if input/output model has finite coefficients.
         %
         %   ISFINITE(M) returns true if the model M has finite coefficients.
         %
         %   For model arrays, ISFINITE returns a logical array B of the same
         %   size as M indicating which models have finite coefficients.
         %
         %   See also ISREAL, INPUTOUTPUTMODEL. 
         boo = isfinite_(M);
      end
      
      function M = permute(M,order)
         %PERMUTE  Permutes dimensions in array of input/output models.
         %
         %   M = PERMUTE(M,ORDER) rearranges the array dimensions of the model array
         %   M so that they are in the order specified by the vector ORDER. Note that
         %   the I/O dimensions are not counted as array dimensions.
         %
         %   Example:
         %      sys = rss(2,2,2,1,2,3);    % 1-by-2-by-3 array of state-space models
         %      size(permute(sys,[3 2 1])) % now it's 3-by-2-by-1.
         %
         %   See also NDIMS, SIZE, RESHAPE, INPUTOUTPUTMODEL.
         if nargin~=2
            ctrlMsgUtils.error('Control:ltiobject:permute1')
         elseif length(order)<ndims(M)-2
            ctrlMsgUtils.error('Control:ltiobject:permute2')
         end
         try
            M = permute_(M,order);
         catch ME
            throw(ME)
         end
      end
      
      function M = uplus(M)
         %UPLUS  Unary plus for input/output models.
         %
         %   See also UMINUS, INPUTOUTPUTMODEL.
      end
      
      function M = uminus(M)
         %UMINUS  Unary minus for input/output models.
         %
         %   MM = UMINUS(M) is invoked by MM = -M.
         %
         %   See also MINUS, INPUTOUTPUTMODEL.
         try
            M = uminus_(M);
         catch E
            ltipack.throw(E,'expression','-M','M',class(M))
         end
      end
      
      function M = minus(M1,M2)
         %MINUS  Subtraction for input/output models.
         %
         %   M = MINUS(M1,M2) is invoked by M = M1-M2.
         %
         %   See also PLUS, UMINUS, INPUTOUTPUTMODEL.
         M = M1 + (-M2);
      end
      
      function M = transpose(M)
         %TRANSPOSE  Transposition of input/output models.
         %
         %   TM = TRANSPOSE(M) is invoked by TM = M.' where M is any 
         %   input/output model. For static models, this is equivalent to 
         %   matrix transposition. For dynamic systems with transfer 
         %   function H(s), this returns the system with transfer function 
         %   H(s).' .
         %
         %   See also CTRANSPOSE, INPUTOUTPUTMODEL.
         try
            M = transpose_(M);
         catch E
            ltipack.throw(E,'expression','M.''','M',class(M))
         end
         M.IOSize_ = M.IOSize_([2 1]);
         M = resetMetaData(M);
      end
      
      function M = conj(M)
         %CONJ  Forms model with complex conjugate coefficients.
         %
         %   MC = CONJ(M) constructs a complex conjugate model MC
         %   by applying complex conjugation to all coefficients of the
         %   input/output model M.  For example, if M is the transfer 
         %   function (2+i)/(s+5i), then CONJ(M) produces the transfer 
         %   function (2-i)/(s-5i).
         %
         %   This operation is useful for manipulating partial fraction
         %   expansions.
         %
         %   See also TF, ZPK, SS, RESIDUE, INPUTOUTPUTMODEL.
         try
            M = conj_(M);
         catch E
            ltipack.throw(E,'command','conj',class(M))
         end
      end

   end
   
   
   %% INDEXING SUPPORT
   methods (Access = protected)
      
      M = indexasgn(M,indices,rhs)

      function M = subparen(M,indices)
         % Implements M(indices)
         sizes = size(M);
         % Format subscripts
         indices = ltipack.formatSubs(indices,sizes);
         % Turn name references into regular indices (first 2 dimensions only)
         for j=1:2,
            indices{j} = name2index(M,indices{j},j);
         end
         % Check indices
         indices = ltipack.checkRefIndices(indices,sizes);
         indrow = indices{1};
         indcol = indices{2};
         
         % Data and metadata
         M = indexref_(M,indrow,indcol,indices(3:end));
         M = subsysMetaData(M,indrow,indcol);
         if isnumeric(indrow)
            M.IOSize_(1) = length(indrow);
         end
         if isnumeric(indcol)
            M.IOSize_(2) = length(indcol);
         end
      end
      
      function indices = name2index(M,indstr,~)
         % Default implementation: name-based reference not supported
         if isnumeric(indstr) || islogical(indstr) || (ischar(indstr) && strcmp(indstr,':'))
            indices = indstr;
         else
            ctrlMsgUtils.error('Control:ltiobject:NoStringIndexing',class(M)) 
         end
      end
      
      function M = subsysMetaData(M,varargin)
         % Metadata management (default = no-op)
      end
      
   end
   
   
   %% BINARY OPERATION SUPPORT
   methods (Access = protected)
      % Metadata management in binary operations (default = no-op)
      function M = copyMetaData(~,M)
      end
      function M = resetMetaData(M)
      end
      function M1 = iocatMetaData(~,M1,~)
      end
      function M1 = plusMetaData(M1,~)
      end
      function M1 = feedbackMetaData(M1,~)
      end
      function M1 = lftMetaData(M1,varargin)
      end
      function M1 = mtimesMetaData(M1,varargin)
      end
   end
   
   
   %% UTILITIES
   methods (Access = protected)
      
      function s = getPropStruct(obj)
         % Build structure of property values for GET(M)
         PublicProps = properties(obj);
         Np = length(PublicProps);
         s = cell2struct(cell(Np,1),PublicProps,1);
         for ct=1:Np
            p = PublicProps{ct};
            try
               s.(p) = obj.(p);
            catch ME
               s.(p) = ME.message;
            end
         end
      end
      
      function BlockValues = checkBlockValues(~,~)
         % Default implementation for non-structured models
         BlockValues = cell(0,2);
      end
      
   end

   
   %% STATIC METHODS
   methods(Static, Access=protected)
      
      function [indy1,indu2] = matchChannelNames(Names1,Names2)
         % Matches channels names.
         %   [IND1,IND2] = matchChannelNames(NAMES1,NAMES2) returns
         %   index vectors such that NAMES2(IND2) = NAMES1(IND1)
         % This function is used for named-based interconnections.
         if isempty(Names1) || isempty(Names2) || any(strcmp(Names1,'')) || any(strcmp(Names2,''))
            ctrlMsgUtils.error('Control:combination:UndefinedIONames')
         end
         [~,indy1,indu2] = intersect(Names1,Names2);
      end
      
   end
   
end
