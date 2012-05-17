function setdefaultfimathfrompref
% SETDEFAULTFIMATHFROMPREF Check to see if the defaut fimath preference has been set.
%      If it has been set then the default fimath needs to be set before fi or fimath constructors are called

%   Copyright 2008-2009 The MathWorks, Inc.

persistent defaultFimathAlreadySetFromPref;

if isempty(defaultFimathAlreadySetFromPref) || ~defaultFimathAlreadySetFromPref

    if ispref('embedded','defaultfimath')
        Fstruct = getpref('embedded','defaultfimath');
        structFields = fieldnames(Fstruct);
        F = embedded.fimath;
        for idx=1:length(structFields)
            F.(structFields{idx}) = Fstruct.(structFields{idx});
        end
        embedded.fimath.SetGlobalFimath(F);
    end   
    defaultFimathAlreadySetFromPref = true;
end

mlock;


