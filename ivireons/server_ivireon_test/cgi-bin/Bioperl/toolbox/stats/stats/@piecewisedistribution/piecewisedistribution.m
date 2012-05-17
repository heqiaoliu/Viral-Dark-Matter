classdef piecewisedistribution
%PIECEWISEDISTRIBUTION Create a piecewise distribution object.
%    PIECEWISEDISTRIBUTION is an abstract class, and you cannot create
%    instances of it directly.  You can create PARETOTAILS objects that
%    are derived from this class.

%    O=PIECEWISEDISTRIBUTION(P,Q,DISTN) creates an object O representing a
%    distribution defined piecewise in different regions.  P is a sorted vector
%    defining the probability values at the boundaries between the regions.  Q
%    is a sorted vector of the same length as P defining the quantile values at
%    the boundaries.  If P and Q have K values, then DISTN is a structure array
%    containing K+1 values, defining the distribution in each region.  Each
%    element of DISTN can have the following fields:
%       'cdf'          function handle defining cdf
%       'icdf'         function handle defining inverse cdf
%       'pdf'          optional function handle defining density
%       'random'       optional function handle to generate random values; if
%                         empty random values are generated using icdf
%       'description'  optional text description
%
%   Example: Define distribution that is uniform over [-1,0] and the
%            positive part of the normal distribution over [0,Inf]
%      p = 0.5; q = 0;
%      d.cdf = @(x) max(0,min(0.5,(x+1)/2));
%      d.icdf = @(p) -1 + 2*p;
%      d.pdf = @(x) 0.5*(x>=-1 & x<=0);
%      d.random = @(sz) rand(sz) - 1;
%      d(2) = struct('cdf',@normcdf,'icdf',@norminv,'pdf',@normpdf,...
%                    'random',@(varargin)abs(randn(varargin{:})));
%      o = piecewisedistribution(p,q,d);
%      xx = linspace(-1.5,2.5);
%      plot(xx,cdf(o,xx))

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:06 $

    properties(GetAccess='protected', SetAccess='protected')
        P = []; % boundaries between segments on probability scale
        Q = []; % boundaries between segments on quantile scale
    end

    properties(GetAccess='protected', SetAccess='protected', Transient=true)
        distribution = {}; % structure array with one element per segment
    end
    
    methods(Access='protected')
    function obj = piecewisedistribution(p,q,distn)
        % default constructor with no args gives standard normal
        if nargin==0
            p = zeros(1,0);
            q = p;
            distn = struct('pdf',@normpdf,'cdf',@normcdf,'icdf',@norminv,...
                       'random',@randn,'description','standard normal');
        else
            error(nargchk(3,3,nargin,'struct'))
        end
        obj = setpieces(obj,p,q,distn);
        end % piecewisedistribution constructor
    end % methods block

    methods(Access='protected')
    
    function obj=setpieces(obj,p,q,distn)
        % Argument checking
        nsegments = 1 + numel(p);
        if ~isvector(p) || any(p<=0) || any(p==1) || ~issorted(p) || any(isnan(p))
            error('stats:piecewisedistribution:BadP',...
                  'P must be a sorted vector of probabilities with 0<P<1.');
        end
        if ~isvector(q) || any(~isfinite(q)) || ~issorted(q) || numel(q)~=nsegments-1
            error('stats:piecewisedistribution:BadQ',...
                  'Q must be a sorted vector of quantiles of the same length as P.');
        end
        if ~isstruct(distn) || numel(distn)~=nsegments
            error('stats:piecewisedistribution:BadDistn',...
                  'DISTN must be a structure array with %d elements.',...
                  nsegments);
        end

        nrequired = 2;  % the required fields are listed first
        allfields = {'cdf' 'icdf' 'pdf' 'random' 'description'};
        fieldtype = [repmat({'function_handle'},1,4),{'char', ''}];
        fieldexists = ismember(allfields,fieldnames(distn));
        if any(~fieldexists(1:nrequired))
            j = find(~fieldexists(1:nrequired),1,'first');
            error('stats:piecewisedisribution:BadDistn',...
                  'Required field "%s" missing from DISTN structure.', ...
                  allfields{j});
        end
        
        % Set up struct in the proper format
        args = [allfields; cell(1,numel(allfields))];
        s(1:nsegments) = struct(args{:});
        for k=find(fieldexists)
            thisfield = allfields{k};
            thistype = fieldtype{k};
            for j=1:nsegments
                val = distn(j).(thisfield);
                if (k<=nrequired) || ~isempty(val)
                    if isa(val,thistype) || isempty(thistype)
                        s(j).(thisfield) = val;
                    else
                        error('stats:piecewisedistribution:BadField',...
                              'DISTN element %d, field "%s" must be of type %s.',...
                              j,thisfield,thistype);
                    end
                end
            end
        end

        % Set properties
        obj.P = p(:);
        obj.Q = q(:);
        obj.distribution = s;
        end % of setpieces
    end % of protected methods

    methods(Hidden = true)        
        function a = properties(obj)
            a = {'nsegments'};
        end
        function b = fieldnames(a)
            b = properties(a);
        end
        
        % Methods that we inherit, but do not want
        function a = fields(varargin),     throwUndefinedError(); end
        function a = ctranspose(varargin), throwUndefinedError(); end
        function a = transpose(varargin),  throwUndefinedError(); end
        function a = permute(varargin),    throwUndefinedError(); end
        function a = reshape(varargin),    throwUndefinedError(); end
        function a = cat(varargin),        throwNoCatError(); end
        function a = horzcat(varargin),    throwNoCatError(); end
        function a = vertcat(varargin),    throwNoCatError(); end
    end
    methods(Hidden = true, Static = true)
        function a = empty(varargin)
            error(['stats:' mfilename ':NoEmptyAllowed'], ...
                  'Creation of empty %s objects is not allowed.',upper(mfilename));
        end
    end
   
end % classdef

function throwNoCatError()
error(['stats:' mfilename ':NoCatAllowed'], ...
      'Concatenation of %s objects is not allowed.  Use a cell array to contain multiple objects.',upper(mfilename));
end

function throwUndefinedError()
st = dbstack;
name = regexp(st(2).name,'\.','split');
error(['stats:' mfilename ':UndefinedFunction'], ...
      'Undefined function or method ''%s'' for input arguments of type ''%s''.',name{2},mfilename);
end

