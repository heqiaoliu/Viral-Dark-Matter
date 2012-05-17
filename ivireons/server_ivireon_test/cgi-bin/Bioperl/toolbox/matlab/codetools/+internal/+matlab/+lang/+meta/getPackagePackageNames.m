function S = getPackagePackageNames(pkgName)
S = {};

P = meta.package.fromName(pkgName);
if ~isempty(P)
    PKGS = P.Packages;
    for i = 1:length(PKGS)
        S{end+1} = regexprep(PKGS{i}.Name, [pkgName '\.'], ''); %#ok<AGROW>
    end
end
end
