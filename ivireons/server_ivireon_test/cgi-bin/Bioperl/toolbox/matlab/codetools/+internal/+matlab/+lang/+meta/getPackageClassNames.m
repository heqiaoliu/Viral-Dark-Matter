function S = getPackageClassNames(pkgName)
S = {};

try
    P = meta.package.fromName(pkgName);
    if ~isempty(P)
        C = P.Classes;
        for i = 1:length(C)
            try
                if ~C{i}.Hidden,
                    S{end+1} = regexprep(C{i}.Name, [pkgName '\.'], ''); %#ok<AGROW>
                end
            end
        end
    end
end
end
