function alnew = utAlgoFieldsUpdate(s,v)
% update algorithm fields when loading objects
% s: model being loaded
% v: version number
% called by loadobj methods

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/05/19 23:05:58 $

isLinear = isa(s,'idmodel');

if v<3
    % R2008a version or older
    % Algorithm property Trace renamed to Display in R2008b
    
    al = s.Algorithm;
    f = fieldnames(al);
    val = struct2cell(al);
    IndTr = strcmpi(f,'Trace');
    if any(IndTr)
        f{IndTr} = 'Display';
    end
    
    if isLinear
        % Algorithm field "Approach" of linear models is obsolete
        IndApp = strcmpi(f,'Approach');
        if any(IndApp)
            f(IndApp) = [];
            val(IndApp) = [];
        end
    end
    
    if v<2
        % R2007b version or older
        % Does not have Criterion, Weighting algorithm props
        
        % Replace SearchDirection with SearchMethod
        if isLinear
            IndSD = strcmpi(f,'SearchDirection');
            if any(IndSD)
                f{IndSD} = 'SearchMethod';
            end
        end
        
        % Add Criterion and Weighting
        IndSM = find(strcmpi(f,'SearchMethod'));
        newfs = {'Criterion';'Weighting'};
        valnew = {'Trace';eye(size(s,1))};
        f   = [f(1:IndSM);   newfs;  f(IndSM+1:end)];
        val = [val(1:IndSM); valnew; val(IndSM+1:end)];
        
        if isLinear
            % Replace GNS with GN for SearchMethod
            if strcmpi(val{IndSM},'gns')
                val{IndSM} = 'gn';
            end
            
            % Replace GnsPinvTol with GnPinvConst
            IndAD = find(strcmp(f,'Advanced'));
            se = val{IndAD}.Search;
            fse = fieldnames(se);
            IndGns = strcmpi(fse,'GnsPinvTol');
            if any(IndGns)
                fse{IndGns} = 'GnPinvConst';
            end
            valse = struct2cell(se);
            se = cell2struct(valse,fse);
            se.GnPinvConst = 1e4; % default value
            val{IndAD}.Search = se;
        end
    end
    
    alnew = cell2struct(val,f,1);
end
