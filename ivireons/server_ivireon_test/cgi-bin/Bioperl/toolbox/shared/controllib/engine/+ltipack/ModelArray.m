classdef (Hidden) ModelArray < InputOutputModel
% Generic model array.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/03/31 18:35:55 $

properties (Access = protected)
      % Model data (one entry per model)
      Data_
   end
   
   % REVISIT: DELETE %%%%%%%%%%%%%
   methods (Hidden)
      function D = getPrivateData(M)
         D = M.Data_;
      end
      function M = setPrivateData(M,D)
         M.Data_ = D;
      end
   end
   % END REVISIT
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access = protected)
   
      %% MODEL CHARACTERISTICS      
      function boo = isreal_(M)
         % Checks realness
         D = M.Data_;
         nD = numel(D);
         if nD==1
            boo = isreal(D);
         else
            boo = true;
            for ct=1:nD
               boo = boo && isreal(D(ct));
               if ~boo, break, end
            end
         end
      end
      
      function boo = isfinite_(M)
         % Check for finite data
         D = M.Data_;
         boo = false(size(D));
         for ct=1:numel(D)
            boo(ct) = isfinite(D(ct));
         end
      end            

      %% BINARY OPERATIONS
      function M1 = iocat_(dim,M1,M2)
         % Generic implementation of [M1,M2] or [M1;M2] for two
         % systems of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify M1.IOSize_
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data = M1.Data_;  Data2 = M2.Data_;
         for ct=1:numel(Data)
            Data(ct) = iocat(dim,Data(ct),Data2(ct));
         end
         M1.Data_ = Data;
      end
      
      function M1 = append_(M1,M2)
         % Generic implementation of APPEND(M1,M2) for two systems
         % of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify M1.IOSize_
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data = M1.Data_;  Data2 = M2.Data_;
         for ct=1:numel(Data)
            Data(ct) = append(Data(ct),Data2(ct));
         end
         M1.Data_ = Data;
      end
      
      function M1 = stack_(arraydim,M1,M2)
         % Generic implementation of STACK(arraydim,M1,M2) for two
         % systems of the same type. Can be overloaded by subclasses.
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         try
            M1.Data_ = cat(arraydim,M1.Data_,M2.Data_);
         catch %#ok<*CTCH>
            ctrlMsgUtils.error('Control:combination:stack3',arraydim)
         end
      end
      
      function [M1,SingularFlag] = feedback_(M1,M2,indu,indy,sign)
         % Generic implementation of FEEDBACK(M1,M2,...) for two
         % systems of the same type. Can be overloaded by subclasses.
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data1 = M1.Data_;  Data2 = M2.Data_;
         SingularFlag = false;
         for ct=1:numel(Data1)
            [Data1(ct),warnflag] = feedback(Data1(ct),Data2(ct),indu,indy,sign);
            SingularFlag = SingularFlag || warnflag;
         end
         M1.Data_ = Data1;
      end
      
      function [M1,SingularFlag] = lft_(M1,M2,indu1,indy1,indu2,indy2)
         % Generic implementation of FEEDBACK(M1,M2,...) for two
         % systems of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify M1.IOSize_
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data1 = M1.Data_;  Data2 = M2.Data_;  SingularFlag = false;
         for ct=1:numel(Data1)
            [Data1(ct),warnflag] = lft(Data1(ct),Data2(ct),indu1,indy1,indu2,indy2);
            SingularFlag = SingularFlag || warnflag;
         end
         M1.Data_ = Data1;
      end
      
      function M1 = plus_(M1,M2)
         % Generic implementation of M1+M2 for two systems
         % of the same type. Can be overloaded by subclasses.
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data1 = M1.Data_;  Data2 = M2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = plus(Data1(ct),Data2(ct));
         end
         M1.Data_ = Data1;
      end
      
      function M1 = mtimes_(M1,M2,ScalarFlags)
         % Generic implementation of M1*M2 for two systems
         % of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify M1.IOSize_
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data1 = M1.Data_;  Data2 = M2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = mtimes(Data1(ct),Data2(ct),ScalarFlags);
         end
         M1.Data_ = Data1;
      end
      
      function M1 = mldivide_(M1,M2)
         % Generic implementation of M1\M2 for two systems
         % of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify M1.IOSize_
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data1 = M1.Data_;  Data2 = M2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = mtimes(inv(Data1(ct)),Data2(ct),false(1,2));
         end
         M1.Data_ = Data1;
      end
      
      function M1 = mrdivide_(M1,M2)
         % Generic implementation of M1/M2 for two systems
         % of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify M1.IOSize_
         [M1,M2] = matchArraySize(M1,M2);   % must come first
         [M1,M2] = matchAttributes(M1,M2);  % overloadable
         % Combine data
         Data1 = M1.Data_;  Data2 = M2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = mtimes(Data1(ct),inv(Data2(ct)),false(1,2));
         end
         M1.Data_ = Data1;
      end
      
      %% INDEXING AND ARRAY MANIPULATIONS
      function s = getArraySize(M)
         % Model array size
         s = size(M.Data_);
      end
      
      function M = indexref_(M,indrow,indcol,ArrayIndices)
         % Data management in M(INDICES)
         Data = M.Data_;
         nind = length(ArrayIndices);
         % Select desired models
         if nind>0 && (nind<ndims(Data) || ~all(strcmp(ArrayIndices,':'))),
            Data = Data(ArrayIndices{:});
         end
         % Select desired I/Os
         if ~(strcmp(indrow,':') && strcmp(indcol,':'))
            for ct=1:numel(Data)
               Data(ct) = getsubsys(Data(ct),indrow,indcol);
            end
         end
         M.Data_ = Data;
      end
      
      function M = indexdel_(M,indices)
         % Data management in M(INDICES) = []
         iscolon = strcmp(indices,':');
         Data = M.Data_;
         if all(iscolon) || ~all(iscolon(1:2))
            % Deleting input or output
            % RE: M(:,:) = [] produces a 0-by-m system as for matrices
            for ct=1:numel(Data)
               Data(ct) = setsubsys(Data(ct),indices{1:2},[]);
            end
         else
            % Deleting array dimensions
            Data(indices{3:end}) = [];
         end
         M.Data_ = Data;
      end
      
      function [M1,M2] = matchArraySize(M1,M2)
         % Expands singleton array dimensions to try and equalize the
         % array sizes of M1 and M2. On output, both models have matching 
         % array sizes or an error is thrown.
         % NOTE: This should be done before attribute matching to properly
         % handle Variable matching in the presence of empty system arrays.
         % e.g., in tf(eye(2),'ts',.1,'var','q') + tf(zeros(2,2,0,1)).
         % Both operands must be made empty first, otherwise the attributes
         % Ts=0.1 and Variable='q' win and the result ends up with Ts=0 and
         % Variable='q'.
         s1 = size(M1.Data_);
         s2 = size(M2.Data_);
         if ~isequal(s1,s2)
            % PERF: Skip when sizes are equal
            nd1 = length(s1);
            nd2 = length(s2);
            s1 = [s1 ones(1,nd2-nd1)];
            s2 = [s2 ones(1,nd1-nd2)];
            s = max(s1,s2);
            s(s1==0 | s2==0) = 0;
            % Check array size compatibility
            % and expand scalar dimensions
            if any(s1(s1~=s)~=1) || any(s2(s2~=s)~=1)
               ctrlMsgUtils.error('Control:combination:IncompatibleModelArrayDims')
            else
               rep = ones(size(s));
               rep(s1==1) = s(s1==1);
               M1.Data_ = repmat(M1.Data_,rep);
               rep = ones(size(s));
               rep(s2==1) = s(s2==1);
               M2.Data_ = repmat(M2.Data_,rep);
            end
         end
      end
      
      function varargout = matchArraySizeN(varargin)
         % Expands singleton array dimensions to try and equalize the
         % array sizes of M1,M2,... On output, all models have matching
         % array sizes or an error is thrown. Use this version to match
         % array sizes across N>2 models.
         nsys = nargin;
         varargout = varargin;
         % Calculate vector AS of max array sizes
         as = size(varargin{1}.Data_);
         for j=2:nsys
            sj = size(varargin{j}.Data_);
            lgap = length(sj)-length(as);
            as = [as ones(1,lgap)]; %#ok<AGROW>
            asj = [sj ones(1,-lgap)];
            isZero = (as==0 | asj==0);
            as = max(as,asj);
            as(isZero) = 0;
         end
         % Check array size compatibility and expand scalar dimensions
         nd = length(as);
         for j=1:nsys
            sj = size(varargin{j}.Data_);
            if ~isequal(sj,as)
               % PERF: Skip REPMAT when sizes are equal
               asj = [sj ones(1,nd-length(sj))];
               if any(asj(asj~=as)~=1)
                  ctrlMsgUtils.error('Control:combination:IncompatibleModelArrayDims')
               else
                  rep = ones(size(as));
                  rep(asj==1) = as(asj==1);
                  varargout{j}.Data_ = repmat(varargin{j}.Data_,rep);
               end
            end
         end
      end

      function M = permute_(M,order)
         M.Data_ = permute(M.Data_,order);
      end
                        
      function M = reshape_(M,varargin)
         M.Data_ = reshape(M.Data_,varargin{:});
      end
            
      %% TRANSFORMATIONS
      function M = conj_(M)
         Data = M.Data_;
         for ct=1:numel(Data)
            Data(ct) = conj(Data(ct));
         end
         M.Data_ = Data;
      end
      
      function M = uminus_(M)
         Data = M.Data_;
         for ct=1:numel(Data)
            Data(ct) = uminus(Data(ct));
         end
         M.Data_ = Data;
      end
      
      function M = inv_(M)
         Data = M.Data_;
         for ct=1:numel(Data)
            Data(ct) = inv(Data(ct));
         end
         M.Data_ = Data;
      end
      
      function M = mpower_(M,k)
         Data = M.Data_;
         for ct=1:numel(Data)
            Data(ct) = mpower(Data(ct),k);
         end
         M.Data_ = Data;
      end
      
      function M = transpose_(M)
         Data = M.Data_;
         for ct=1:numel(Data)
            Data(ct) = transpose(Data(ct));
         end
         M.Data_ = Data;
      end
      
      function M = ctranspose_(M)
         Data = M.Data_;
         for ct=1:numel(Data)
            if hasdelay(Data(ct))
               ctrlMsgUtils.error('Control:transformation:ctranspose1')
            end
            Data(ct) = ctranspose(Data(ct));
         end
         M.Data_ = Data;
      end
            
   end
   
end
