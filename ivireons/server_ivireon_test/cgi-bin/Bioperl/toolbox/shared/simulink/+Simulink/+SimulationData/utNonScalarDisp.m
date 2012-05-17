function utNonScalarDisp(obj)
% Utility function used by MCOS display functions to display non-scalar
% objects

    % Print size and class name
    str = sprintf('%dx', size(obj));
    str(end) = [];
    mc = metaclass(obj);
    fprintf('  %s %s\n\n', str, mc.Name);

    % Print properties list
    p = properties(obj);
    if(~isempty(p))
        fprintf('  Properties:\n');
        for idx = 1:length(p)
            fprintf('    %s\n', p{idx});
        end
		fprintf('\n');
    end                

    % Print methods list
    m = methods(obj);
    if(~isempty(m))
        fprintf('  Methods:\n');
        for idx = 1:length(m)
            fprintf('    %s\n', m{idx});
        end
		fprintf('\n');
    end
   
% end function