%#eml
% This function is never invoked directly. Instead, all clients (including internal)
% should use strcmp(), which is either computed at compile time, or invokes this eml_strcmp
% for run-time comparison.
function bool = eml_strcmp(a,b)

bool = false;
if ischar(a) && ischar(b) && ndims(a) == ndims(b)
    sza = size(a);
    szb = size(b);
    % Sizes must match.
    for k = 1:ndims(a)
        if sza(k) ~= szb(k)
            return
        end
    end
    % Elements must match.
    for k = 1:eml_numel(a)
        if a(k) ~= b(k)
            return
        end
    end
    bool = true;
end

%--------------------------------------------------------------------------
