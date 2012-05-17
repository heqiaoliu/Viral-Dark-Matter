function S = getClassPropertyNames(className)
S = {};

try
  C = meta.class.fromName(className);
  if ~isempty(C)
    P = C.Properties;
    for i = 1:length(P)
        if ~P{i}.Constant && ~P{i}.Hidden && ...
                (strcmp(P{i}.GetAccess, 'public') == 1 || ...
                 strcmp(P{i}.SetAccess, 'public') == 1)
            S{end+1} = P{i}.Name; %#ok<AGROW>
        end
    end
  end
end
end
