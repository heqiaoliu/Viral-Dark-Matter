function S = getClassEnumerationNames(className)
S = {};

try
  C = meta.class.fromName(className);
  if ~isempty(C)
    E = C.EnumeratedValues;
    for i = 1:length(E)
      S{end+1} = E{i}.Name; %#ok<AGROW>
    end
  end
end
end
