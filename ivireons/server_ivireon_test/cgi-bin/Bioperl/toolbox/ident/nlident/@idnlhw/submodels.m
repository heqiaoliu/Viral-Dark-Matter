function submdl = submodels(sys, str)
%SUBMODELS submodel extraction

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:24:19 $

% Author(s): Qinghua Zhang

switch lower(str)
    case 'measured'
        submdl = sys;
        submdl = pvset(submdl, 'NoiseVariance', zeros(size(sys,'ny')));
        submdl.EstimationInfo = iddef('estimation');
    case'noise'
        ny = size(sys,'ny');
        if ny==1
            submdl = idpoly(1,[],1,1,[],pvget(sys, 'Ts'));
        else
            submdl = idss([],[],zeros(ny,0),zeros(ny,0),zeros(0,ny), zeros(0,1), pvget(sys, 'Ts'));
        end
        %submdl.EstimationInfo = iddef('estimation');
    otherwise
        submdl = [];
end

% FILE END
