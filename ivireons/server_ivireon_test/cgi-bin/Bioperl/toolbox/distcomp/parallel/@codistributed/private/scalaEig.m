function varargout = scalaEig(A)
% SCALAEIG  ScaLAPACK symmetric eigenvalue solver

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/21 21:14:43 $

error(nargoutchk(0, 2, nargout));   

% When there are no output arguments, the function should still return 
% the eigenvalues.
numOutputs = max(1, nargout);

% Redistribute input according to the default 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, codistributor2dbc());
end    
    
aDist = getCodistributor(A);
lbgrid = aDist.LabGrid;
localA = getLocalPart(A);

codistr1d = codistributor1d();

% Create array descriptor required by ScaLAPACK
descA = arraydescriptor(A);

% Output from ScalaPack is ordered with eigenvalues first, then eigenvectors. 
[eigOut{1:numOutputs}] = scalaEigmex(localA, descA, lbgrid(1), lbgrid(2), aDist.Orientation, isreal(A));

if (numOutputs == 1)
    % The ScaLAPACK output is replicated but we want codistributed output.
    varargout{1} = codistributed.pConstructFromReplicated( eigOut{1}, codistributor1d(1) );%#ok<DCUNK>
    warning('distcomp:codistributed:scalaEig:changeOutputCodistr', ...
            ['The behavior of codistributed/EIG has changed. In R2010a ',...
             'and earlier, D = EIG(A) returns a replicated array. In ',...
             'this release D is a codistributed array. To work ',...
             'with D as a replicated array, use gather(D). See the ',...
             'release notes for further information. ']);
else % nargout == 2
    % When there are multiple output arguments, they need to be rearranged.  The
    % ScaLAPACK ordering is [evals, evecs] while MATLAB expects [evecs, evals]
    codistr = codistributor2dbc(lbgrid, aDist.BlockSize, aDist.Orientation, size(A));
    A = codistributed.pDoBuildFromLocalPart(eigOut{2}, codistr); %#ok<DCUNK>
    varargout{1} = redistribute(A, codistr1d);
    C = codistributed.pConstructFromReplicated(eigOut{1}, codistr1d); %#ok<DCUNK>
    varargout{2} = diag(C);
end
