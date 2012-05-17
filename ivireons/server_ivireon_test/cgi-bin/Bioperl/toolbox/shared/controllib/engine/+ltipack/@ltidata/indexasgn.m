function Data = indexasgn(Data,indices,rhs,ioSize,ArrayMask,D0)
% Data management during SYS(INDICES) = RHS.
%
% ioSize:    New I/O size after assignment
% ArrayMask: SIZE(ArrayMask) is the new system array size,
%            and ArrayMask(i)=j>0 means Data(i) is partially
%            reassigned by Drhs(j)
%
% New entries in the resulting DATA array are initialized to D0
% (essentially a zero static gain). 

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:18 $

% Align all models to new I/O size (skip if unchanged)
if ~isempty(Data) && any(ioSize>iosize(Data(1)))
   for ct=1:numel(Data)
      Data(ct) = utGrowIO(Data(ct),ioSize(1),ioSize(2));
   end
end

% Grow model array
% RE: All new models are initialized to D0
ArraySize = size(ArrayMask);
if prod(ArraySize)>numel(Data)
   % Determine which models were added
   sizeData = size(Data);
   nd = length(sizeData);
   Mask = ones(ArraySize);
   ind = cell(1,nd);
   for ct=1:nd
      ind{ct} = 1:sizeData(ct);
   end
   Mask(ind{:}) = 0;
   idxNew = find(Mask);
   % Grow data array to right size and shape
   % RE: Data(prod(ArraySize)) = null not enough for sys(2,1) = rhs where sys is a 1x2 array
   ind = num2cell(ArraySize);
   Data(ind{:}) = D0;
   for ct=1:length(idxNew)
      Data(idxNew(ct)) = D0;
   end
end

% Update modified models
idxLHSModels = find(ArrayMask>0); % modified LHS models (absolute indices, monotonic)
idxRHSModels = ArrayMask(idxLHSModels); % rhs model assigned to idxLHSModels(k)   
for ct=1:length(idxLHSModels)
   Data(idxLHSModels(ct)) = setsubsys(Data(idxLHSModels(ct)),...
      indices{1:2},rhs(idxRHSModels(ct)));
end

% Resolve remaining NaN input and output delays to zero
idxLHSModels = find(ArrayMask==0);
for ct=1:length(idxLHSModels)
   cti = idxLHSModels(ct);
   Delay = Data(cti).Delay;
   Delay.Input(isnan(Delay.Input)) = 0;
   Delay.Output(isnan(Delay.Output)) = 0;
   Data(cti).Delay = Delay;
end
