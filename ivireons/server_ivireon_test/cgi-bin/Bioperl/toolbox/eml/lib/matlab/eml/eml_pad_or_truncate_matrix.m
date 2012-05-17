function y = eml_pad_or_truncate_matrix(x,n) %#eml
%Embedded MATLAB Library Function

% Y = EML_ADJUST_MATRIX_SIZE(X,N) zero-pads or truncates the leading
% nonsingleton dimension of X so that it is length N.
% Input X must be a two-dimensional matrix.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/10/24 19:03:39 $

eml_lib_assert(isnumeric(x) && ~isempty(x) && length(size(x))==2,...
                       'eml_adjust_matrix_size:XMustBe2D',...
                       'X must be a non-empty two-dimensional numeric matrix.');

eml_lib_assert(eml_is_const(n),...
                       'eml_adjust_matrix_size:NMustBeConst',...
                       'N must be const.');
if isvector(x)
    % Vector
    if n<=length(x)
        % Truncate
        y = x(1:n);
    else
        % Pad
        siz = size(x);
        if siz(1) > 1
            % Column vector
            siz(1) = n;
        else
            % Row vector
            siz(2) = n;
        end
        if isreal(x)
            y = zeros(siz,class(x));
        else
            y = complex(zeros(siz,class(x)));
        end
        y(1:length(x)) = x;
    end
else
    % Matrix
    if n<=size(x,1)
        % Truncate
        y = x(1:n,:);
    else
        % Pad
        siz = size(x);
        siz(1) = n;
        if isreal(x)
            y = zeros(siz,class(x));
        else
            y = complex(zeros(siz,class(x)));
        end
        y(1:size(x,1),:) = x;
    end
end

