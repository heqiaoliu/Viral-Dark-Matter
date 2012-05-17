function sys = linearnlrset(sys, nlobj)
%LINEARNLRSET set NonlinearRegressors=[] for Nonlinearity=linear

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:58:52 $

% Author(s): Qinghua Zhang

if nargin<2
  nlobj = sys.Nonlinearity;
end

ny = size(sys,'ny');

nlr = sys.NonlinearRegressors;
for ky=1:ny
  if isa(nlobj(ky), 'linear')
    if ny==1
      nlr = [];
    elseif  iscell(nlr) && numel(nlr)>=ky ...
            && ~(ischar(nlr{ky}) && strcmpi(nlr{ky}, 'search'))
      nlr{ky} = [];
    end
  end
end
sys.NonlinearRegressors = nlr;

% FILE END