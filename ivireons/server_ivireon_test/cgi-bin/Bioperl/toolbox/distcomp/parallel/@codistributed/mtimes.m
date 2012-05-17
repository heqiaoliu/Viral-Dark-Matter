function C = mtimes(A,B)
%* Matrix multiply for codistributed array
%   C = A * B
%   C = MTIMES(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(N)
%       B = codistributed.rand(N)
%       C = A * B
%   end
%   
%   See also MTIMES, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4.2.1 $  $Date: 2010/06/24 19:32:59 $

if isscalar(A) || isscalar(B)
    C = codistributed.pElementwiseBinaryOp(@times,A,B); %#ok<DCUNK>
elseif ndims(A) > 2 || ndims(B) > 2
    error('distcomp:codistributed:mtimes:inputsMustBe2D', ...
        'Matrix multiplication is limited to two dimensional arrays.')
elseif size(A,2) ~= size(B,1)
    error('distcomp:codistributed:mtimes:innerdim', ...
        'Inner dimensions must be equal.');
elseif isa(A,'codistributed') && ~isa(B,'codistributed')
    % This implementation only supports codistributor1d.
    codistributed.pVerifyUsing1d('mtimes', A, B); %#ok<DCUNK> private static

    aDist = getCodistributor(A);
    switch aDist.Dimension 
      case 1
          C = gop(@vertcat,getLocalPart(A)*B);
      case 2
        k = globalIndices(A, aDist.Dimension, labindex);
        C = gplus(getLocalPart(A)*B(k,:));
      otherwise
        error('distcomp:codistributed:mtimes:HighDistDimNotSupported', ...
              ['Matrix multiplication only supported for arrays ' ...
               'distributed along rows or columns.']);
    end
elseif ~isa(A,'codistributed') && isa(B,'codistributed')
    % This implementation only supports codistributor1d.
    codistributed.pVerifyUsing1d('mtimes', A, B); %#ok<DCUNK> private static

    bDist = getCodistributor(B);
    switch bDist.Dimension
      case 1
        k = globalIndices(B, bDist.Dimension, labindex);
        C = gplus(A(:,k)*getLocalPart(B));
      case 2
        C = gop(@horzcat,A*getLocalPart(B));
      otherwise
        error('distcomp:codistributed:mtimes:HighDistDimNotSupported', ...
              ['Matrix multiplication only supported for arrays ' ...
               'distributed along rows or columns.']);
    end
else
    % This implementation only supports codistributor1d.
    codistributed.pVerifyUsing1d('mtimes', A, B); %#ok<DCUNK> private static

    % Both A and B are codistributed arrays.
    Aloc = getLocalPart(A);
    Bloc = getLocalPart(B);
    aDist = getCodistributor(A);
    bDist = getCodistributor(B);
    Apart = aDist.Partition;
    Bpart = bDist.Partition;
    m = size(A,1);
    n = size(B,2);
    cSize = [m, n];
    switch 10*aDist.Dimension + bDist.Dimension

        case 11
            % Rows * rows -> rows.
            % C(i,:) = sum over k A(i,k)*B(k,:) where A(i,k) is a
            % submatrix of the local portion of A the k-th lab and
            % B(k,:) is the entire local portion of B the k-th lab.
            % Send B(k,:)'s around a ring of labs.

            k = partitionIndices(Bpart,labindex);
            Cloc = Aloc(:,k)*Bloc;
            to = mod(labindex-2,numlabs)+1;
            from = mod(labindex,numlabs)+1;
            for p = [labindex+1:numlabs 1:labindex-1]
                mwTag1 = 32113;
                Bloc = labSendReceive(to, from, Bloc,mwTag1);
                k = partitionIndices(Bpart,p);
                Cloc = Cloc + Aloc(:,k)*Bloc;
            end
            cCodistr = codistributor1d(1, Apart, cSize);
            C = codistributed.pDoBuildFromLocalPart(Cloc, cCodistr); %#ok<DCUNK>

        case 12
            % Rows * columns -> columns.
            % No partial sums required.
            % C(i,j) = A(i,:)*B(:,j) where A(i,:) and B(:,j)
            % are the entire local portions i-th and j-th labs.
            % Send A(i,:)'s around a ring of labs.

            nb = size(Bloc,2);
            outputClass = superiorfloat(Aloc, Bloc);
            Cloc = zeros(m,nb,outputClass);
            i = partitionIndices(Apart,labindex);
            Cloc(i,:) = Aloc*Bloc;
            to = mod(labindex-2,numlabs)+1;
            from = mod(labindex,numlabs)+1;
            for p = [labindex+1:numlabs 1:labindex-1]
                mwTag2 = 32114;
                Aloc = labSendReceive( to, from, Aloc, mwTag2 );
                i = partitionIndices(Apart,p);
                Cloc(i,:) = Aloc*Bloc;
            end
            cCodistr = codistributor1d(2, Bpart, cSize);
            C = codistributed.pDoBuildFromLocalPart(Cloc, cCodistr); %#ok<DCUNK>

        case 21
            % Two subcases:
            % Matrix * matrix -> matrix.
            % Matrix * vector -> vector.
            % Reduction over distributed dimensions.
            % Make sure size(getLocalPart(A),2) == size(getLocalPart(B),1), then
            % compute T = getLocalPart(A)*getLocalPart(B), C = codistributed(gplus(T))
            % without actually using gplus and codistributed(...).
            % Message pattern is all-to-all to sum and distribute T's.

            if ~isequal(Apart,Bpart)
                B = redistribute(B,codistributor('1d',1,Apart));
            end
            if n == 1
                % Matrix * vector, result distributed by rows.
                T = getLocalPart(A)*getLocalPart(B);
                Cpart = codistributor1d.defaultPartition(m);
                i = partitionIndices(Cpart,labindex)';  % Must be a column vector.
                Cloc = T(i);
                for p = 1:numlabs-1
                    to = mod(labindex+p-1,numlabs)+1;
                    from = mod(labindex-p-1,numlabs)+1;
                    i = partitionIndices(Cpart,to)';
                    mwTag3 = 32115;
                    Cloc = Cloc + labSendReceive( to, from, T(i), mwTag3 );
                end
                cCodistr = codistributor1d(1, Cpart, cSize);
                C = codistributed.pDoBuildFromLocalPart(Cloc, cCodistr); %#ok<DCUNK>
            else
                % Matrix * matrix, result distributed by columns.
                T = getLocalPart(A)*getLocalPart(B);
                Cpart = codistributor1d.defaultPartition(n);
                j = partitionIndices(Cpart,labindex);
                Cloc = T(:,j);
                for p = 1:numlabs-1
                    to = mod(labindex+p-1,numlabs)+1;
                    from = mod(labindex-p-1,numlabs)+1;
                    j = partitionIndices(Cpart,to);
                    mwTag3 = 32115;
                    Cloc = Cloc + labSendReceive( to, from, T(:,j), mwTag3 );
                end
            
                cCodistr = codistributor1d(2, Cpart, cSize);
                C = codistributed.pDoBuildFromLocalPart(Cloc, cCodistr); %#ok<DCUNK>
            end

        case 22
            % Columns * columns -> columns.
            % (Includes default matrix distributions.)
            % C(:,j) = sum over k A(:,k)*B(k,j) where A(:,k) is the
            % entire local portion of A on the k-th lab and B(k,j) is
            % a submatrix of the local portion of B on the k-th lab.
            % Send A(:,k)'s around a ring of labs.

            k = partitionIndices(Apart,labindex);
            Cloc = Aloc*Bloc(k,:);
            to = mod(labindex-2,numlabs)+1;
            from = mod(labindex,numlabs)+1;
            for p = [labindex+1:numlabs 1:labindex-1]
                mwTag4 = 32116;
                Aloc = labSendReceive(to, from, Aloc, mwTag4);
                k = partitionIndices(Apart,p);
                Cloc = Cloc + Aloc*Bloc(k,:);
            end
            cCodistr = codistributor('1d',2,Bpart, cSize);
            C = codistributed.pDoBuildFromLocalPart(Cloc, cCodistr); %#ok<DCUNK>
      otherwise
            error('distcomp:codistributed:mtimes:HighDistDimNotSupported', ...
                  ['Matrix multiplication only supported for arrays ' ...
                   'distributed along rows or columns.']);
    end
end
