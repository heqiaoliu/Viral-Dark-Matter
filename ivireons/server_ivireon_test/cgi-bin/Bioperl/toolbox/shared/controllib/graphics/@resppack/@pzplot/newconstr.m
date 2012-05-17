function [out,constrClassTypes] = newconstr(this, keyword, CurrentConstr)
%Interface with dialog for creating new constraints.
%
%   [LIST,CLASSTYPES] = NEWCONSTR(View) returns the list of all available
%   constraint types for this view.
%
%   CONSTR = NEWCONSTR(View,TYPE) creates a constraint of the
%   specified type.

% Author(s): A. Stothert 23-Sep-2005
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/22 04:19:33 $

ReqDB = {...
    'SettlingTime',     sprintf('Settling time'),     'editconstr.SettlingTime',     'srorequirement.settlingtime';...
    'PercentOvershoot', sprintf('Percent overshoot'), 'editconstr.DampingRatio',     'srorequirement.dampingratio';...
    'DampingRatio',     sprintf('Damping ratio'),     'editconstr.DampingRatio',     'srorequirement.dampingratio';...
    'NaturalFrequency', sprintf('Natural frequency'), 'editconstr.NaturalFrequency', 'srorequirement.naturalfrequency'; ...
    'RegionConstraint', sprintf('Region constraint'), 'editconstr.PZLocation',       'srorequirement.pzlocation'};

ni = nargin;
if ni==1
    % Return list of valid constraints
    out = ReqDB(:,[1 2]);
    if nargout == 2
        constrClassTypes = unique(ReqDB(:,3));
    end
else
    keyword = localCheckKeyword(keyword,ReqDB);
    idx     = strcmp(keyword,ReqDB(:,1));
    Class   = ReqDB{idx,3};
    dClass  = ReqDB{idx,4};
    
    % Create instance
    reuseInstance = ni>2 && isa(CurrentConstr,Class);
    if reuseInstance && (strcmpi(keyword,'PercentOvershoot') || strcmpi(keyword,'DampingRatio'))
        if strcmp(keyword,'PercentOvershoot') && strcmp(CurrentConstr.Type,'damping') || ...
                strcmp(keyword,'DampingRatio') && strcmp(CurrentConstr.Type,'overshoot')
            reuseInstance = false;
        end
    end
    if reuseInstance
        % Recycle existing instance if of same class
        Constr = CurrentConstr;
    else
        %Create new requirement instance
        reqObj = feval(dClass);
        %Ensure feedback sign for requirement is zero (i.e., open loop)
        reqObj.FeedbackSign = 0;
        %Create corresponding requirement editor class
        Constr = feval(Class,reqObj);
        %Determine sampling time for the constraint
        if ~isempty(this.Responses) && ~isempty(this.Responses(1).DataSrc)
            Constr.Ts = this.Responses(1).DataSrc.Model.Ts;
        else
            %No way to determine discrete or continuous case,
            %default to continuous
            Constr.Ts = 0;
        end
        
        if strcmp(keyword,'PercentOvershoot')
            Constr.Type = 'overshoot';
        elseif strcmp(keyword,'DampingRatio')
            Constr.Type = 'damping';
        elseif strcmp(keyword,'NaturalFrequency')
            if Constr.Ts, Constr.Requirement.setData('xdata',1/Constr.Ts); end
            Constr.setDisplayUnits('xunits',this.FrequencyUnits);
        elseif strcmp(keyword,'SettlingTime') && Constr.Ts
            Constr.Requirement.setData('xData',10*Constr.Ts);
        end
    end
    
    out = Constr;
end

%--------------------------------------------------------------------------
function kOut = localCheckKeyword(kIn,ReqDB)
%Helper function to check keyword is correct, mainly needed for backwards
%compatibility with old saved constraints

if any(strcmp(kIn,ReqDB(:,1)))
    %Quick return is already an identifier
    kOut = kIn;
    return
end

%Now check display strings for matching keyword, may need to translate kIn
%from an earlier saved version
idx = strcmp(sprintf(kIn),ReqDB(:,2));
if any(idx)
    kOut = ReqDB{idx,1};
else
    kOut = [];
end

