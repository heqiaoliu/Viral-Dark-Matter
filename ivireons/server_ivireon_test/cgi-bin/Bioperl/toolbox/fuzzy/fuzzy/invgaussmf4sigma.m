% Copyright 2005 The MathWorks, Inc.
    
function sigma = invgaussmf4sigma (x, m, c)

%INVGAUSSMF4SIGMA  Compute sigma value from memberships of datapoints to a cluster
%
% Help goes here
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter Checks 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check x
[N,dims] = size(x);  % num of samples
% check m
[Nm, dimsm] = size(m);

if ~isequal(N, Nm)
    error('FuzzyLogic:dimensionmismatch', ...
        'x and m must have the same number of rows');
end

if ~isequal(dims, dimsm, 1)
    error('FuzzyLogic:columnvectorsonly', ...
        'x and m must have only one column');
end

% check c
[Nc, dimsc] = size(c);
if ~isequal(Nc, dimsc, 1)
    error('FuzzyLogic:scalaronly', ...
        'c must be a scalar');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove 1's in m
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Why?
% Having 1's in m vector will make the sigma value -inf
% The only place where m, which represents the membership of the data
% points to the cluster, can be 1 is at the exact center of cluster. This
% means x=c, which implies the point x adds or removes nothing from the
% spread of the gaussian curve which is what sigma represents. Therefore it
% is safe to remove the datapoint from the computation without affecting
% the accuracy of results. Removing it allows us to sidestep the issue of
% getting -inf values for sigma.

rmindexes = find(m==1);

if ~isempty(rmindexes)
    tempdata = [x m];
    tempdata(rmindexes,:) = [];
    x = tempdata(:,1);
    m = tempdata(:,2);
end


%%%%%%%%%%%%%%%%%%%%%
% Compute sigma
%%%%%%%%%%%%%%%%%%%%%

sigma = sqrt(-((x-c).^2) ./ (2*log(m))); 
sigma = sum(sigma) / N; 



