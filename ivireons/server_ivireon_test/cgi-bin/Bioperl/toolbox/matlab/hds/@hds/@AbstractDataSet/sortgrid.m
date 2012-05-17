function sortgrid(this,mode)
%SORT  sort samples in the dataset based on independent variable.
%
%   SORT(MODE)
%   MODE selects the direction of the sort
%       'ascend' results in ascending order
%       'descend' results in descending ord
   
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/17 06:24:36 $

if isstr(mode) && isvector(mode)
    switch lower(mode)
        case 'ascend'
            option=true;
        case 'descend'
            option=false;
        otherwise
            error('Unknown mode.')
    end
end

% sort data for grid variables
AllVars = getvars(this);
GridVars=[];
if length(this.Grid_)==1 && isempty(this.Grid_.Variable)
    % since there is no grid variable, abort sort
    disp('No grid variable is available. Sort aborted.')
    return
else
    for ctd=1:length(this.grid)
        c = this.Data_(this.Grid_(ctd).Variable==AllVars);
        GridVars=[GridVars;this.Grid_(ctd).Variable];
        X=getArray(c);
        if option
            if iscell(X)
                [dummy,index{ctd}]=sort(X);
            else
                [dummy,index{ctd}]=sort(X,1,'ascend');
            end
        else
            if iscell(X)
                [dummy,tmp]=sort(X);
                index{ctd}=flipud(tmp);
            else
                [dummy,index{ctd}]=sort(X,1,'descend');
            end
        end
        c.setArray(X(index{ctd}));
    end
end

% sort value arrays for dependent values
[junk,idx_dv] = setdiff(AllVars,GridVars);
for ct=1:length(idx_dv)
    % for each value array
    c = this.Data_(idx_dv(ct));
    section=[];
    for i=1:length(this.grid)
        section=[section index(:,i)];
    end
    X=getArray(c);
    SampleSize = c.SampleSize;
    is = repmat({':'},[1 length(SampleSize)]);
    if c.GridFirst
        temp=[section is];
        c.setArray(X(temp{:}));
    else 
        temp=[is section];
        c.setArray(X(temp{:}));
    end
end

% sort link arrays
for ct=1:length(this.Children_)
    % for each value array
    c = this.Children_(ct);
    section=[];
    for i=1:length(this.grid)
        section=[section index(:,i)];
    end
    % sort value
    c.Links=c.Links(section{:});    
end
