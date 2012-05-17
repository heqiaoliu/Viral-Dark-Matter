classdef (Hidden) LFTBlockWrapper
% Wrapper for Control Design blocks to facilitate block management in LFT models.
%
%   This class supports block management in LFT models of the form
%      LFT ( H , blkdiag ( f(B1) , ... , f(BN) ) )
%   where B1,...,BN are Control Design block instances and f(Bj) is a simple
%   block transformation of the form
%      f(Bj) = LFT (Rj, Bj - Sj)   % Rj,Sj= matrices
%   Each LFTBlockWrapper instance encapsulates one (Bj,Rj,Sj) triplet and
%   vectors of LFTBlockWrapper objects represent
%      blkdiag ( f(B1) , ... , f(BN) ) .
%   The Rj transform is used only for uncertain blocks and f(Bj) = Bj-Sj when 
%   Rj=[].

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:35:54 $

% Note: Separate LFTBlockWrapper instances with the same Data value are
% used for repeated blocks. This facilitates Offset management when
% merging block lists (different offsets may be used for the same block,
% e.g., in c = a*b/(a+b)).
   
   properties (Access = protected)
      % Block data
      Data_
      % Block size
      Size_
      % Offset Sj
      Offset_
      % Fractional transformation Rj (for uncertain blocks only)
      Transform_
   end
   
   % BLOCK LIST MANAGEMENT
   methods
      
      function this = LFTBlockWrapper(Block)
         % Constructor
         if nargin>0
            this.Data_ = Block;
            ios = iosize(Block);
            this.Size_ = ios;
            this.Offset_ = zeros(ios);
         end
      end
      
      function [ny,nu] = iosize(BlockVector)
         % Total I/O size
         ios = zeros(1,2);
         for ct=1:numel(BlockVector)
            ios = ios + BlockVector(ct).Size_;
         end         
         if nargout<2
            ny = ios;
         else
            ny = ios(1);  nu = ios(2);
         end
      end
      
      function ns = order(BlockVector)
         % Returns number of states in block vector. The order is assessed
         % based on the current value of each block.
         ns = 0;
         for ct=1:numel(BlockVector)
            blk = BlockVector(ct).Data_;
            if isa(blk,'DynamicSystem')
               ns = ns + order(blk);
            end
         end
      end
      
      function boo = isstatic(BlockVector)
         % Returns true if all blocks are static
         boo = true;
         for ct=1:numel(BlockVector)
            if ~isstatic(BlockVector(ct).Data_)
               boo = false;  break
            end
         end
      end
      
      function boo = isreal(BlockVector)
         % Returns true if all blocks have real coefficients
         boo = true;
         for ct=1:numel(BlockVector)
            if ~isreal(BlockVector(ct).Data_)
               boo = false;  break
            end
         end
      end
      
      function boo = logicalfun(F,BlockVector)
         % Applies logical function to each entry in block list
         nblk = numel(BlockVector);
         boo = true(nblk,1);
         for ct=1:nblk
            boo(ct) = F(BlockVector(ct).Data_);
         end
      end
      
      function Ts = getTs(BlockVector)
         % Gets sampling times of dynamic blocks
         nblk = numel(BlockVector);
         cTs = cell(nblk,1);
         for ct=1:nblk
            if isa(BlockVector(ct).Data_,'ltipack.SingleRateSystem')
               cTs{ct} = BlockVector(ct).Data_.Ts;
            end
         end
         Ts = cat(1,cTs{:});
      end
      
      function BlockVector = setTs(BlockVector,Ts)
         % Modifies sampling times of dynamic blocks
         for ct=1:numel(BlockVector)
            if isa(BlockVector(ct).Data_,'ltipack.SingleRateSystem')
               BlockVector(ct).Data_.Ts = Ts;
            end
         end
      end
      
      function [irange,jrange] = getRowColRange(BlockVector)
         % Computes the row and column index ranges associated with each block.
         % If M = blkdiag(B), then B(k) = M(IRANGE{K},JRANGE{K}).
         nb = numel(BlockVector);
         irange = cell(nb,1);
         jrange = cell(nb,1);
         i = 0;  j = 0;
         for ct=1:nb
            bs = BlockVector(ct).Size_;
            irange{ct} = i+1:i+bs(1);
            jrange{ct} = j+1:j+bs(2);
            i = i+bs(1); j = j+bs(2);
         end
      end                  
      
      function [rperm,cperm] = getRowColPerm(BlockVector,bperm)
         % Computes the row and column permutations RPERM and CPERM
         % corresponding to a permutation BPERM of the blocks.
         % If M = blkdiag(B), then M(RPERM,CPERM) = blkdiag(B(BPERM)).
         % Construct index range for each block
         [irange,jrange] = getRowColRange(BlockVector);
         rperm = cat(2,[],irange{bperm});
         cperm = cat(2,[],jrange{bperm});
      end
      
      function [rsel,csel] = getRowColSelection(BlockVector,bsel)
         % Computes the row and column indices for the selected blocks B(ISEL). 
         % If M = blkdiag(B), then M(RSEL,CSEL) = blkdiag(B(BSEL)).
         [irange,jrange] = getRowColRange(BlockVector);
         rsel = cat(2,[],irange{bsel});
         csel = cat(2,[],jrange{bsel});
      end

      %-----------------------
      function BlockNames = getBlockName(BlockVector)
         % Get block names
         nb = numel(BlockVector);
         BlockNames = cell(nb,1);
         for ct=1:nb
            % Use subsref-free access to block name
            BlockNames{ct} = getName(BlockVector(ct).Data_);
         end
      end
      
      function s = getBlockSet(BlockVector)
         % Returns structure of block names and block data.
         [BlockNames,iu] = unique(getBlockName(BlockVector));
         if isempty(iu)
            s = struct;
         else
            s = cell2struct({BlockVector(iu).Data_},BlockNames,2);
         end
      end
      
      function BlockVector = setBlockSet(BlockVector,s)
         % Modifies the block data
         % Note: Name change must be supported for backward compatibility with RCTB
         [BlockNames,iu,ju] = unique(getBlockName(BlockVector));
         % Validate specified data
         if ~(isstruct(s) && isequal(sort(fieldnames(s)),BlockNames))
            ctrlMsgUtils.error('Control:lftmodel:set5')
         else
            % Verify that blocks with the same name have the same definition
            newValues = struct2cell(s);
            if ~all(cellfun(@(x) isa(x,'ControlDesignBlock'),newValues))
               ctrlMsgUtils.error('Control:lftmodel:set2')
            else
               newNames = cellfun(@(x) x.Name,newValues,'UniformOutput',false);
            end
            [newNames,is] = sort(newNames);
            iDupe = find(strcmp(newNames(1:end-1),newNames(2:end)));
            for ct=1:length(iDupe)
               if ~isequal(newValues{is(iDupe(ct))},newValues{is(iDupe(ct)+1)})
                  % Two blocks with the same name but different definitions
                  ctrlMsgUtils.error('Control:lftmodel:set3',newNames{iDupe(ct)})
               end
            end
         end
         for ct=1:length(BlockNames)
            blkName = BlockNames{ct};
            oldValue = BlockVector(iu(ct)).Data_;
            newValue = s.(blkName);
            if ~isequal(iosize(oldValue),iosize(newValue))
               % New value has incompatible class or size
               ctrlMsgUtils.error('Control:lftmodel:set4')
            end
         end
         % Apply new value
         for ct=1:numel(BlockVector)
            BlockVector(ct).Data_ = s.(BlockNames{ju(ct)});
         end
      end
      
      function [BList,R,S] = getBlockList(BlockVector)
         % Returns list of blocks and cumulatibe transform R and offset S.
         % R is set to [] if empty in all blocks
         BList = reshape({BlockVector.Data_},[length(BlockVector) 1]);
         if nargout>1
            S = blkdiag([],BlockVector.Offset_);
            RList = {BlockVector.Transform_};
            if all(cellfun(@isempty,RList))
               R = [];
            else
               [nw,nz] = iosize(BlockVector);
               R = zeros(nw+nz,nz+nw);
               i1 = 0;  i2 = nw;  j1 = 0;  j2 = nz;
               for k=1:numel(BlockVector)
                  [nwk,nzk] = iosize(BlockVector(k));
                  Rk = RList{k};
                  if isempty(Rk)
                     Rk = [zeros(nwk,nzk) eye(nwk);eye(nzk) zeros(nzk,nwk)];
                  end
                  R([i1+1:i1+nwk,i2+1:i2+nzk],[j1+1:j1+nzk,j2+1:j2+nwk]) = Rk;
                  i1 = i1+nwk;  i2 = i2+nzk;  j1 = j1+nzk;  j2 = j2+nwk;
               end
            end
         end
      end
            
      function Value = evaluate(Block,Value)
         % Evaluates the LFTBlockWrapper for a given value of the underlying
         % Control Design Block (taking the R,S transformation into account).
         % The Control Design Block value can be specified as a double matrix 
         % or a ltipack.*data* object.
         
         % Apply offset B -> B-S
         S = Block.Offset_;
         if norm(S,1)>0
            if isnumeric(Value)
               Value = Value - S;
            else
               Value = applyOffset(Value,S);
            end
         end
         % Apply LFT transform B-S -> LFT(R,B-S)
         R = Block.Transform_;
         if ~isempty(R)
            if isnumeric(Value)
               Value = ltipack.lftdataM.matrixLFT(R,Value);
            else
               Value = applyTransform(Value,R);
            end
         end
      end
      
      function [BlockVector,rperm,cperm] = sortByName(BlockVector)
         % Sorts blocks by name. RPERM and CPERM are corresponding
         % row and column permutations of blkdiag(B1,...,BN).
         [~,is] = sort(getBlockName(BlockVector));
         [rperm,cperm] = getRowColPerm(BlockVector,is);
         BlockVector = BlockVector(is,:);
      end
      
      function B = append(B1,B2)
         % Appends two block lists B1 and B2.
         B = [B1 ; B2];
         % Check that blocks with the same name have the same definition
         [BlockNames1,i1] = unique(getBlockName(B1));
         [BlockNames2,i2] = unique(getBlockName(B2));
         [~,j1,j2] = intersect(BlockNames1,BlockNames2);
         i1 = i1(j1);  i2 = i2(j2);
         for ct=1:length(i1)
            if ~isequal(B1(i1(ct)).Data_,B2(i2(ct)).Data_)
               ctrlMsgUtils.error('Control:lftmodel:REVISIT')
            end
         end
      end
            
      function [BlockVector,Shift] = center(BlockVector)
         % Sets Offset value to default static value (default feedthrough gain 
         % for dynamic systems)
         Shift = zeros(iosize(BlockVector));
         ir = 0;   ic = 0;
         for ct=1:numel(BlockVector)
            blk = BlockVector(ct);
            rbs = blk.Size_(1);
            cbs = blk.Size_(2);
            NewOffSet = getOffset(blk.Data_);
            DOffset = NewOffSet - blk.Offset_;
            if isempty(blk.Transform_)
               % Shift must be absorbed by IC model
               Shift(ir+1:ir+rbs,ic+1:ic+cbs) = DOffset;
            elseif norm(DOffset,1)>0
               % Absorb shift in block transform R
               BlockVector(ct).Transform_ = ltipack.lftdataM.shiftLFT(blk.Transform_,DOffset);
            end
            ir = ir + rbs;   ic = ic + cbs;
            BlockVector(ct).Offset_ = NewOffSet;
         end
      end
      
      function BlockVector = replace(BlockVector,B2BMap)
         % Replaces blocks according to replacement map B2BMAP (Nx2 cell array)
         BlockNames = getBlockName(BlockVector);
         nblk = numel(BlockVector);
         [~,iLoc] = ismember(BlockNames,B2BMap(:,1));
         for ct=1:nblk
            if iLoc(ct)>0,
               newblk = B2BMap{iLoc(ct),2};
               BlockVector(ct).Data_ = newblk;
               BlockNames{ct} = getName(newblk);
            end
         end
         % Checks that blocks with the same name have the same definition
         [BN,is] = sort(BlockNames);
         BV = BlockVector(is);
         for ct=1:nblk-1
            if strcmp(BN{ct},BN{ct+1}) && ~isequal(BV(ct).Data_,BV(ct+1).Data_)
               ctrlMsgUtils.error('Control:lftmodel:repblock5',BN{ct})
            end
         end
      end
      
      
      function [BlockVector,bnorm,Tnorm] = normalize(BlockVector)
         % Normalizes uncertain blocks. The index vector BNORM flags blocks
         % that need normalization and TNORM is the normalization transformation
         % for these blocks, i.e., B(BNORM) = LFT(TNORM,BN(BNORM)) where BN
         % are the normalized block wrappers.
         nblk = numel(BlockVector);
         needNorm = false(nblk,1);  % true for blocks that need normalization
         T11 = []; T12 = []; T21 = []; T22 = [];
         for ct=1:nblk
            blk = BlockVector(ct);
            if isUncertain(blk.Data_)
               R0 = blk.Transform_;
               S0 = blk.Offset_;
               % Computes R,S,T such that
               %    * LFT(R,blk-S) is normalized
               %    * blk = LFT(T,LFT(R,blk-S))
               % Returns R=[] if blk-S is already normalized (then blk = LFT(T,blk-S))
               [R,S,T] = normalize(blk.Data_);
               if ~(isequal(R,R0) && isequal(S,S0))
                  needNorm(ct) = true;
                  [ny,nu] = iosize(blk);
                  % Compute (re)normalization transformation T
                  T(1:ny,1:nu) = T(1:ny,1:nu)-S0;
                  if ~isempty(R0)
                     T = ltipack.lftdataM.matrixLFT(R0,T,nu+1:nu+ny,ny+1:ny+nu,1:nu,1:ny);
                  end
                  % Append to overall normalizing transformation
                  T11 = blkdiag(T11,T(1:ny,1:nu));
                  T12 = blkdiag(T12,T(1:ny,nu+1:nu+ny));
                  T21 = blkdiag(T21,T(ny+1:ny+nu,1:nu));
                  T22 = blkdiag(T22,T(ny+1:ny+nu,nu+1:nu+ny));
                  % Update block wrapper data
                  blk.Offset_ = S;
                  blk.Transform_ = R;
                  BlockVector(ct) = blk;
               end
            end
         end
         Tnorm = [T11 T12;T21 T22];
         bnorm = find(needNorm);
      end
      
      function cstr = getSummary(BlockVector)
         % Prints summary of blocks in LFT model
         [BlockNames,is] = sort(getBlockName(BlockVector));
         [~,iu] = unique(BlockNames,'first');
         nblk = length(iu);
         ncopies = diff([iu;length(BlockNames)+1]);
         cstr = cell(nblk,1);
         for ct=1:nblk
            cstr{ct} = getDescription(BlockVector(is(iu(ct))).Data_,ncopies(ct));
         end
      end
      
      function display(BlockVector)
         nb = numel(BlockVector);
         if nb==0
            disp('Empty block list')
         else
            for ct=1:nb
               disp(getDescription(BlockVector(ct).Data_,1))
            end
         end
      end      
      
   end
   
      
   % CASTING TO DOUBLE OR LTI VALUE
   methods
                  
      function D = ltipack_ssdata(BlockVector)
         % Converts block list to ltipack.ssdata object.
         nb = numel(BlockVector);
         if nb==0
            D = ltipack.ssdata.default();
         else
            for ct=1:nb
               blk = BlockVector(ct);
               Dct = ltipack_ssdata(blk.Data_,blk.Transform_,blk.Offset_);
               if ct==1
                  D = Dct;
               else
                  D = append(D,Dct);
               end
            end
         end
      end
      
      function D = ltipack_frddata(BlockVector,freq,unit)
         % Converts block list to ltipack.frddata object.
         nf = length(freq);
         nb = numel(BlockVector);
         if nb==0
            D = ltipack.frddata(zeros([0,0,nf]),freq,0);
            D.FreqUnits = unit;
         else
            for ct=1:numel(BlockVector)
               blk = BlockVector(ct);
               Dct = ltipack_frddata(blk.Data_,freq,unit,...
                  blk.Transform_,blk.Offset_);
               if ct==1
                  D = Dct;
               else
                  D = append(D,Dct);
               end
            end
         end
      end
      
      function M = double_(BlockVector)
         % Converts block list to double array (requires all blocks to be static).
         M = zeros(iosize(BlockVector));
         ir = 0;  ic = 0;
         for ct=1:numel(BlockVector)
            blk = BlockVector(ct);
            rbs = blk.Size_(1);
            cbs = blk.Size_(2);
            M(ir+1:ir+rbs,ic+1:ic+cbs) = ...
               numeric_array(blk.Data_,blk.Transform_,blk.Offset_);
            ir = ir + rbs;   ic = ic + cbs;
         end
      end
      
   end
   
   % INTERFACE WITH HINFSTRUCT
   methods
      
      function [pInfo,bperm] = HINFSTRUCT_ParamInfo(BlockVector)
         %PARAMINFO  Gathers static information about multi-block parameterization.
         %
         %   This function takes a vector of blocks (possibly repeated) and returns a
         %   block permutation BPERM and a structure PINFO with the following fields
         %   (here P refers to the vector of all parameters, X to the vector of 
         %   free parameters or optimization variables, and NBLK to the number of 
         %   distinct blocks):
         %     Blocks    NBLK-by-1 structure with fields:
         %                  Data    block data (ControlDesignBlock)
         %                  Offset  block offsets in LFT model. SIZE(Offset,3) is 
         %                          the number of occurrences of this block
         %                  nx      number of states in block
         %                  nu      number of block inputs
         %                  ny      number of block outputs
         %                  np      number of parameters P in block
         %                  npf     number of free parameters X in block
         %     p0        Initial value of the parameter vector
         %     iFree     Index vector such that X = P(iFree)
         %     iBlock    Index vector of the same length as X linking X(j) back 
         %               to the block k=iBlock(j).
         %     nx        total number of states (taking repetitions into account)
         %     nu        total number of inputs
         %     ny        total number of outputs
         %     iu        mapping from original block list to unique block set:
         %                  pInfo.Blocks == BlockVector(iu)
         %     ju        inverse mapping from unique block set to original block list
         %                  BlockVector  == pInfo.Blocks(ju)
         
         % Sort blocks by name
         [BlockNames,bperm] = sort(getBlockName(BlockVector));
         BlockVector = BlockVector(bperm);
         [~,iu,ju(bperm)] = unique(BlockNames,'first');
         nblk = length(iu);
         nrepeat = diff([iu ; length(BlockNames)+1]);
         B = struct('Data',cell(nblk,1),'Offset',[],'nx',[],'nu',[],'ny',[],'np',[],'npf',[]);
         p0 = zeros(0,1);
         iFree = zeros(0,1);
         iBlock = zeros(0,1);
         ip = 0;  ix = 0;
         for j=1:nblk
            blk = BlockVector(iu(j)).Data_;
            [ny,nu] = iosize(blk);
            p = getp(blk);
            np = length(p);
            indf = find(isfree(blk));
            npf = length(indf);
            % Block sizes
            B(j).Data = blk;
            % NOTE: Assume Transform_ = []
            B(j).Offset = cat(3,BlockVector(iu(j):iu(j)+nrepeat(j)-1).Offset_);
            B(j).nx = numState(blk);
            B(j).nu = nu;
            B(j).ny = ny;
            B(j).np = np;
            B(j).npf = npf;
            % Block contribution to p0
            p0 = [p0 ; p]; %#ok<AGROW>
            % Contribution of block to free parameter set
            iFree = [iFree ; ip+indf]; %#ok<AGROW>
            iBlock(ix+1:ix+npf,:) = j;
            ip = ip+np;  ix = ix+npf;
         end
         pInfo = struct('Blocks',B,'p0',p0,'iFree',iFree,'iBlock',iBlock,...
            'nx',sum(nrepeat.*cat(1,B.nx)),...
            'nu',sum(nrepeat.*cat(1,B.nu)),...
            'ny',sum(nrepeat.*cat(1,B.ny)),...
            'iu',bperm(iu),'ju',ju);
      end
      
   end  
   
   methods (Static)
      
      function BL = emptyBlockList()
         % Create 0x1 vector of LFTBlockWrapper objects
         BL = ltipack.LFTBlockWrapper.newarray([0 1]);
      end         
      
      function BlockVector = readOldFormat(AtomList,Copies,Literal)
         % Read pre-MCOS description of block structure
         BlockVector = ltipack.LFTBlockWrapper.emptyBlockList();
         for ct=1:numel(AtomList)
            B = ltipack.LFTBlockWrapper(AtomList{ct});
            if ~Literal(ct)
               % Normalized block
               [B.Transform_,B.Offset_] = normalize(B.Data_);
            end
            BlockVector = [BlockVector ; repmat(B,[Copies(ct) 1])]; %#ok<AGROW>
         end
      end
      
   end

end
