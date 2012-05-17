function varargout = subsref(h, S)
%SUBSREF  Overloaded subsref

%   Copyright 2005-2010 The MathWorks, Inc.

if length(S)>=1 && strcmp(S(1).type,'()') 
    % TS(IND)
    % Determine which members have been selected
    memberVars = gettimeseriesnames(h);
    
    % First dimension: sample index -- I
    % Second dimension: time series object index/names -- J
    % get J
    if length(S(1).subs)==2
        if islogical(S(1).subs{2})
            J = find(S(1).subs{2});
        elseif isnumeric(S(1).subs{2})        
            if (any(S(1).subs{2}<1) || any(S(1).subs{2}>length(memberVars)) || ...
                      ~isequal(round(S(1).subs{2}),S(1).subs{2}))
                 error('tscollection:subsref:badIndex',...
                     'The member index must be integers between 1 and the total number of members of the tscollection.')
            end
             J = S(1).subs{2};
        elseif iscell(S(1).subs{2})
            [flag J] = ismember(S(1).subs{2},memberVars);
            if ~any(flag)
                error('tscollection:subsref:notMember',...
                    'One or more of the specified time series are not members of the tscollection.')
            end
        elseif ischar(S(1).subs{2})
            if S(1).subs{2}~=':'
                [flag J] = ismember(lower(S(1).subs{2}),lower(memberVars));
                if ~any(flag)
                    error('tscollection:subsref:notMember',...
                        'One or more of the specified time series are not members of the tscollection.')
                end
            else
                J = 1:length(memberVars);
            end
        end
    elseif length(S(1).subs)==1
        J = 1:length(memberVars);
        if isempty(S(1).subs{1})
            varargout{1} = tscollection;
            return
        end
    else
        error('tscollection:subsref:badIndex',...
            'Sub-referencing depth cannot exceed two.')
    end
    % get I
    if ischar(S(1).subs{1}) 
        % : case
        if S(1).subs{1}==':'
            I = 1:length(h.Time);
        else
            error('tscollection:subsref:badSep',...
                'Use a colon operator or a numeric index to specify the samples in the time series.')
        end
    elseif ~isempty(S(1).subs{1}) && isreal(S(1).subs{1})
        I = unique(S(1).subs{1});
        if isnumeric(I) && (any(I<1) || any(I>h.TimeInfo.Length) || ~isequal(round(I),I))
            error('tscollection:subsref:badIndex',...
                'Each time index must be an integer between 1 and the tscollection length.')
        elseif islogical(I)
            I = find(I);
        end
    else
        return
    end
    
    % Intitilialize new @tscollection
    tscout = tscollection(h.Time(I));

    % Copy metadata
    tscout.timeInfo = reset(h.TimeInfo,h.Time(I));
    
    % Add subreferenced @timeseries one at a time
    for k=1:length(J)
        thists = getts(h,memberVars{J(k)});
        tscout = setts(tscout,thists.getsamples(I),...
            thists.Name);
    end   

    % If there are more subref arguments call the subsref
    % method on the time series with the remaining arguments
    if length(S)>1
        if nargout>0
            varargout = cell(1,nargout);
            varargout{:} = subsref(tscout,S(2:end));
        else
            varargout{1} = subsref(tscout,S(2:end)); 
        end
    else
        varargout{1} = tscout;
    end
% coll.MemberName
elseif length(S)>=1 && strcmp(S(1).type,'.') && ~isempty(h.Members_) && ...
        any(strcmpi(S(1).subs,{h.Members_.('Name')}))
    ind = find(strcmpi(S(1).subs,{h.Members_.('Name')}));
    ts = getts(h,h.Members_(ind(1)).Name);
    if length(S)>1
        if nargout>0
           varargout = cell(1,nargout);
           varargout{:} = builtin('subsref',ts,S(2:end));
        else
           clear ans;
           builtin('subsref',ts,S(2:end));
           if exist('ans','var')
              varargout{1} = ans; %#ok<NOANS>
           end  
        end
    else
        varargout{1} = ts;
    end       
else
    % TS.Fieldname
    if nargout>0
        varargout = cell(1,nargout);
        [varargout{:}] = builtin('subsref',h,S);
    else
        clear ans;
        builtin('subsref',h,S);
        if exist('ans','var')
            varargout{1} = ans; %#ok<NOANS>
        end
    end 
end



        
