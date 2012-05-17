classdef Generic
   % Base class for parametric models objects.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:36:43 $
   
   properties (Access = protected)
      % Version
      Version_ = pmodel.ver();
   end
   
   % PMODEL INTERFACE
   methods (Abstract, Access = protected)
      % Serializes param.Continuous objects
      ps = getParamSet(M)
      M = setParamSet(M,ps)
   end
   
   % PUBLIC METHODS
   methods
      
      function np = nparams(M,varargin)
         %NPARAMS  Number of parameters in parametric model.
         %
         %   NP = NPARAMS(M) returns the total number NP of parameters
         %   involved in the parametric model M. This number includes both
         %   free and fixed parameters.
         %
         %   NPF = NPARAMS(M,'free') returns the number of free parameters.
         %
         %   See also GETP, SETP, RANDP, ISFREE.
         np = 0;
         if nargin>1
            % Number of free parameters
            for i = 1:numel(M)
               ps = getParamSet(M(i));
               for ct = 1:numel(ps)
                  np = np + numel(find(ps(ct).Free));
               end
            end
         else
            % Total number of parameters
            for i = 1:numel(M)
               ps = getParamSet(M(i));
               for ct = 1:numel(ps)
                  np = np + numel(ps(ct).Value);
               end
            end
         end
      end
      
      
      function isf = isfree(M)
         %ISFREE  True for free parameters.
         %
         %   ISF = ISFREE(M) returns a logical vector ISF with as many
         %   entries as parameters in the parametric model M. The j-th
         %   entry of ISF is true if the j-th parameter is free and 
         %   is false if the j-th parameter is fixed.
         %
         %   See also GETP, SETP.
         isf = true(0,1);
         for i = 1:numel(M)
            ps = getParamSet(M(i));
            np = numel(ps);
            c = cell(np,1);
            for ct=1:np
               c{ct} = ps(ct).Free(:);
            end
            isf = cat(1,isf,c{:});
         end
      end
      
      
      function p = getp(M,varargin)
         %GETP  Gets vector of parameter values.
         %
         %   P = GETP(M) takes a parametric model M and returns the current
         %   values of its parameters. Both fixed and free parameters are 
         %   included.
         %
         %   X = GETP(M,'free') returns the values of free parameters only.
         %   The vector X is the same as P(ISFREE(M)).
         %
         %   See also SETP, NPARAMS, ISFREE.
         
         % Note: Supports arrays of pmodel.* objects
         p = zeros(0,1);
         if nargin>1
            % Free parameters only
            for i = 1:numel(M)
               ps = getParamSet(M(i));
               np = numel(ps);
               c = cell(np,1);
               for ct = 1:np
                  x = ps(ct).Value(ps(ct).Free);
                  c{ct} = x(:);
               end
               p = cat(1,p,c{:});
            end
         else
            % All parameters
            for i = 1:numel(M)
               ps = getParamSet(M(i));
               np = numel(ps);
               c = cell(np,1);
               for ct = 1:np
                  c{ct} = ps(ct).Value(:);
               end
               p = cat(1,p,c{:});
            end
         end
      end
      
      function M = setp(M,p,varargin)
         %SETP  Sets vector of parameter values.
         %
         %   M = SETP(M,P) sets the parameters of the parametric model M to 
         %   the values specified in the vector P. The length of P must match
         %   the total number of parameters NPARAMS(M). 
         %
         %   M = SETP(M,X,'free') only sets the free parameters. The remaining
         %   parameters are held at their current value. The length of X must
         %   match the number of free parameters.
         %
         %   See also GETP, NPARAMS, ISFREE.
         np = length(p);
         ip = 0;
         if nargin>2
            % P is the vector of free parameters
            for i = 1:numel(M)
               Mi = M(i);
               ps = getParamSet(Mi);
               for j = 1:numel(ps)
                  ifj = find(ps(j).Free);
                  ipNext = ip + length(ifj);
                  if ipNext <= np
                     ps(j).Value(ifj) = p(ip+1:ipNext);
                     ip = ipNext;
                  end
               end
               M(i) = setParamSet(Mi,ps);
            end
         else
            % P is the vector of all parameters
            for i = 1:numel(M)
               Mi = M(i);
               ps = getParamSet(Mi);
               for j = 1:numel(ps)
                  ipNext = ip + numel(ps(j).Value);
                  if ipNext <= np
                     ps(j).Value(:) = p(ip+1:ipNext);
                     ip = ipNext;
                  end
               end
               M(i) = setParamSet(Mi,ps);
            end
         end
         
         if np~=ip
            ctrlMsgUtils.error('Control:pmodel:setp')
         end         
      end 
      
   end 
   
end
