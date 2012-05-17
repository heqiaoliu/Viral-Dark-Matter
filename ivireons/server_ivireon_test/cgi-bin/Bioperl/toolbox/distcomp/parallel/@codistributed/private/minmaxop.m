function [Y I] = minmaxop(fcnMinMax,varargin)
%minmaxop    template for max and min

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/08 13:25:45 $

try
    if nargin == 2 || nargin == 4
        % Handle fMinMax(X) and fMinMax(X, [], dim).
        X = varargin{1};
        if nargin == 2
            dim = distributedutil.Sizes.firstNonSingletonDimension(size(X));
        else
            if ~isempty(varargin{2})
                % This is the same error message as with builtin min and max.
                % For example, min(3, 4, 2).
                error(['distcomp:codistributed:' func2str(fcnMinMax) ':caseNotSupported'], ...
                      [upper(func2str(fcnMinMax)) ' with two matrices to compare and '...
                       'a working dimension is not supported.']);
            end
            dim =  distributedutil.CodistParser.gatherIfCodistributed(varargin{3});
            if ~isa(X, 'codistributed')
                if nargout > 1
                    [Y, I] = fcnMinMax(X, [], dim);
                else
                    Y = fcnMinMax(X, [], dim); 
                end
                return;
            end
        end
        wantI = nargout > 1;
        [Y, I] = iMinMaxAlongDim(fcnMinMax, X, dim, wantI);
    elseif nargin == 3
        % Handle fMinMax(X, Y), i.e. elementwise comparison between X and Y.
        if nargout > 1
            error(['distcomp:codistributed:' func2str(fcnMinMax) ':maxlhs'], ...
                  'Too many output arguments.');
        end
        X = varargin{1};
        Z = varargin{2};
        Y = codistributed.pElementwiseBinaryOp(fcnMinMax, X, Z); %#ok<DCUNK> private method.

    else

        % The error ID depends on the function, so we cannot simply call error(nargchk(...)).
        error(['distcomp:codistributed' func2str(fcnMinMax) ':maxrhs'], 'Too many input arguments.');
    end
catch E
    % Error stack should only show min or max, not minmaxop.
    throwAsCaller(E);
end

end % End of minmaxop.

function [Y, I] = iMinMaxAlongDim(fcnMinMax, X, dim, wantI)
I = [];
if any(size(X, dim) == [0, 1])
    % min/max on a singleton dimension or an empty dimension is a no-op.
    % This is completely different from any/all/sum/prod.
    Y = X;
    if wantI
        I = codistributed.ones(size(X), getCodistributor(X), 'noCommunication');
    end
    return;
end
% Defer to implementation of non-trivial min-max.
codistr = getCodistributor(X);
LP = getLocalPart(X);
[LPY, LPI, codistr] = codistr.hMinMaxImpl(fcnMinMax, LP, dim, wantI);
Y = codistributed.pDoBuildFromLocalPart(LPY, codistr);  %#ok<DCUNK> private static.
if wantI
    I = codistributed.pDoBuildFromLocalPart(LPI, codistr);  %#ok<DCUNK> private static.
end

end % End of iMinMaxAlongDim.
