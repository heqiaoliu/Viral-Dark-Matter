function S = getClassStaticMethodNames(className)
S = {};

try
  C = meta.class.fromName(className);
  if ~isempty(C)
    M = C.Methods;
    for i = 1:length(M)
        if M{i}.Static && ~M{i}.Hidden && strcmp(M{i}.Access, 'public') == 1
            S{end+1} = M{i}.Name; %#ok<AGROW>
        end 
    end
  end
end
end
