function setSlice(this,Section,B,GridSize)
%SETSLICE  Modifies multi-dimensional slice of value array.
%
%   SETSLICE(ValueArray,Section,Array,GridSize)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:25 $

% RE: Assumes that 
%  1) the size of B is compatible with the grid slice specified by SECTION
%  2) this assignment does not grow the grid
%  3) If B is not a cell array of samples, it is treated as a SINGLE sample
%     (B -> {B})
Ns = prod(GridSize);
NsB = prod(cellfun('length',Section));
isCellofSampleB = (iscell(B) && numel(B)==NsB);

% Get current array
A = getArray(this); 
Uninitialized = isempty(A);
isCellofSampleA = (iscell(A) && (Uninitialized || all(this.SampleSize==[1 1])));

% Special case handling
if isequal(B,[])
   % Deleting a slice
   if isscalar(A)
      % Scalar storage: Turn A into full-size array
      A = hdsReplicateArray(A,[GridSize 1]);
   end
   % Update container data
   is(:,1:length(this.SampleSize)) = {':'};
   if this.GridFirst
      A = hdsSetSlice(A,[Section is],B);
   else
      A = hdsSetSlice(A,[is Section],B);
   end
   
else
   % Modifying a slice
   if isCellofSampleA && ~isCellofSampleB
      % Treat non-cell B as single sample
      B = {B};
      isCellofSampleB = true;
   end
   
   % Initialize A if empty (uninitialized variable)
   if Uninitialized
      if isCellofSampleB && isequal(B{:},[])
         % Empty sample values for uninitialized variable: do nothing
         % (leave it uninitialized)
         return
      elseif isCellofSampleA
         % A is {}. Use cell-based storage
         this.SampleSize = [1 1];
      elseif isCellofSampleB
         % A is []. Try converting B to an homogenous array
         % RE: Must be done here because B's storage type is 
         % used to create A
         try
            [B,this.SampleSize] = utCell2Array(this,B);
            isCellofSampleB = false;
         catch
            this.SampleSize = [1 1];
            isCellofSampleA = true;
         end
      end
      % Create new array of size grid size and data type inherited from SLICE
      if this.GridFirst
         A = hdsNewArray(B,[GridSize this.SampleSize]);
      else
         A = hdsNewArray(B,[this.SampleSize GridSize]);
      end
   end

   % Align the formats of A and B
   % RE: this.SampleSize known at this point
   if isCellofSampleB && ~isCellofSampleA
      % Try converting B to an homogenous array
      if isscalar(B)
         % Optimization
         B_Array = B{1};
         SampleSizeB = size(B_Array);
      else
         try
            [B_Array,SampleSizeB] = utCell2Array(this,B);
         catch
            SampleSizeB = [];
         end
      end
      if isequal(this.SampleSize,SampleSizeB)
         % Conversion successful
         B = B_Array;
         isCellofSampleB = false;
      else
         % Conversion failed: must convert A to cell format
         A = this.utArray2Cell(A);
         isCellofSampleA = true;
         this.SampleSize = [1 1];
      end
   end

   % Scalar expansion of A (scalar storage)
   if isscalar(A)
      if isscalar(B) && isequal(A,B)
         % No change (optimization)
         return
      else
         % Turn A into full-size array
         A = hdsReplicateArray(A,[GridSize 1]);
      end
   end
   
   % Handle absolute indexing
   AbsoluteIndex = (length(Section)<length(GridSize));
   if AbsoluteIndex
      % Absolute indexing
      A = this.utReshape(A,Ns);
      B = this.utReshape(B,NsB);
   end
   
   % Perform assignment   
   is = cell(size(this.SampleSize));
   is(:) = {':'};
   try
      if this.GridFirst
         A = hdsSetSlice(A,[Section is],B);
      else
         A = hdsSetSlice(A,[is Section],B);
      end
   catch
      % Assignment may fail due to incompatible array types. In such case,
      % convert both A and B to cell array format and try again
      if ~isCellofSampleA
         A = this.utArray2Cell(A);
         B = this.utArray2Cell(B);
         this.SampleSize = [1 1];
      end
      if this.GridFirst
         A = hdsSetSlice(A,[Section is],B);
      else
         A = hdsSetSlice(A,[is Section],B);
      end
   end      

   if AbsoluteIndex
      % Absolute indexing
      A = this.utReshape(A,GridSize);
   end
end

% Update container data
this.setArray(A)
