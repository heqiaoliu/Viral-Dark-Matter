classdef (Hidden) NumericArray < ltipack.ModelArray & StaticModel
   % Numeric Array Interface (abstract class).
   %
   % @NumericArray implements the notion of numeric arrays as arrays of
   % LTIPACK data containers and translates standard matrix operations 
   % as operations on the underlying LTIPACK arrays.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:35:56 $
      
   %% DATA ABSTRACTION INTERFACE
   methods (Access = protected)
      
      %% CONVERSIONS
      function A = double_(M)
         % Converts to double array
         Data = M.Data_;
         A = zeros([iosize(M) size(Data)]);
         for ct=1:numel(Data)
            A(:,:,ct) = double(Data(ct));
         end
      end
         
      %% TRANSFORMATIONS
      function M = repmat_(M,s)
         % Replication along I/O dimensions
         ios = s(1:2);
         if any(ios~=1)
            % Data
            Data = M.Data_;
            for ct=1:numel(Data)
               Data(ct) = iorep(Data(ct),ios);
            end
            M.Data_ = Data;
         end
         
         % Replicate along array dimensions
         if length(s)>2
            % First replicate along array dimensions
            M.Data_ = repmat(M.Data_,[s(3:end) 1]);
         end
      end
                  
   end
   
end
