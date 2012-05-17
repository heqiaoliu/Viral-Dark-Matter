function S = getPackageFunctionNames(pkgName)
S = {};

P = meta.package.fromName(pkgName);
if ~isempty(P)
    F = P.Functions;
    for i = 1:length(F)
        if ~F{i}.Hidden && strcmp(F{i}.Access, 'public') == 1 
            S{end+1} = F{i}.Name; %#ok<AGROW>
        end 
    end
end
end
