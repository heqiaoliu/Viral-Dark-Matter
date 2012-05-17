function [acodes,bcodes] = nominalcheck(a,b)
%NOMINALCHECK Utility for logical comparison of nominal arrays.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:34 $

if ischar(a) % && isa(b,'nominal')
    if size(a,1) > 1 || ndims(a) > 2
        error('stats:nominal:nominalcheck:InvalidComparison', ...
              'Cannot compare array to multiple strings.');
    end
    if isequal(a,'')
        acodes = 0;
    else
        acodes = find(strcmp(a,b.labels));
        if isempty(acodes)
            acodes = length(b.labels) + 1;
        end
    end
    bcodes = b.codes;
elseif ischar(b) % && isa(a,'nominal')
    acodes = a.codes;
    if size(b,1) > 1 || ndims(b) > 2
        error('stats:nominal:nominalcheck:InvalidComparison', ...
              'Cannot compare nominal array to multiple strings.');
    end
    if isequal(b,'')
        bcodes = 0;
    else
        bcodes = find(strcmp(b,a.labels));
        if isempty(bcodes)
            bcodes = length(a.labels) + 1;
        end
    end
elseif isa(a,'nominal') && isa(b,'nominal')
    acodes = a.codes;
    if isequal(a.labels,b.labels)
        bcodes = b.codes;
    else
        % get a's codes for b's data
        convert = zeros(1,length(b.labels)+1);
        nomatches = 0;
        for i = 1:length(b.labels)
            found = find(strcmp(b.labels(i),a.labels));
            if ~isempty(found) % a unique match
                convert(i+1) = found;
            else % no match
                nomatches = nomatches + 1;
                convert(i+1) = length(a.labels) + nomatches;
            end
        end
        bcodes = reshape(convert(b.codes+1), size(b.codes));
    end
else
    error('stats:nominal:nominalcheck:InvalidComparison', ...
          'Invalid types for comparison.');
end
