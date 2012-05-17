classdef ProbDist
%ProbDist Probability distribution object.
%   ProbDist is an abstract class representing a probability distribution.
%   You cannot create instances of this class directly.  You must create
%   a derived class such as ProbDistUnivParam or ProbDistUnivKernel,
%   either by calling the class constructor or by using a function such as
%   FITDIST.
%
%   ProbDist properties:
%       DistName    - name of the distribution
%       InputData   - structure containing data used to fit the distribution
%       Support     - structure describing the support of the distribution
%
%   ProbDist methods:
%       cdf         - cumulative distribution function
%       pdf         - probabability density or probability function
%       random      - random number generation
%
%   See also FITDIST, PROBDISTUNIVPARAM, PROBDISTUNIVKERNEL.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:58 $

    properties(GetAccess='public', SetAccess='protected') % Public properties
%DISTNAME - Distribution name.
%   The DistName property specifies the name of the probability
%   distribution.  It may be the name of a parametric family such as
%   'normal', or the name of a nonparametric specification such as
%   'kernel'.
%
%   See also PROBDIST, FIT.
        DistName = '';

%INPUTDATA - Input data.
%   The InputData property is a structure that contains information about
%   the data used when a ProbDist object is created by fitting to data.
%
%   See also PROBDIST, FIT.
        InputData = struct('data',[],'cens',[],'freq',[]);

%SUPPORT - Support.
%   The Support property contains information about the support of the
%   distribution, or the range of values over which the distribution has
%   positive probability.  It contains three fields:
%
%       'range'        a two-element vector [L,U] such that all of the
%                      probability is contained between L and U
%       'closedbound'  a two-element logical vector indicating whether the
%                      corresponding range endpoint is included
%       'iscontinuous' true if the distribution takes values on the
%                      entire interval from L to U, or false if it takes
%                      only integer values within this range
%
%   See also PROBDIST, FIT.
        Support = struct('range',[-Inf Inf], 'closedbound',[false false], 'iscontinuous',true);
    end
    
    properties(GetAccess='protected', SetAccess='protected')
        % Private properties containing function handles
        cdffunc = [];
        pdffunc = [];
        randfunc = [];
    end
    
    methods(Access = 'protected')
        function pd = ProbDist(distname)
            if nargin>0
                pd.distname = distname;
            end
        end %constructor
    end

    methods(Static = true,Abstract = true)
        pd = fit(distname,x,varargin)
    end % static methods

    methods(Hidden = true)
        % Methods that we inherit from opaque, but do not want
        function a = fields(varargin),          throwUndefinedError; end
        function varargout = cat(varargin),     throwNoCatError; end
        function varargout = horzcat(varargin), throwNoCatError; end
        function varargout = vertcat(varargin), throwNoCatError; end
        function varargout = empty(varargin)
            error('stats:ProbDist:NoEmpty','Empty ProbDist objects are not allowed.')
        end
    end % hidden methods block

end % classdef

function throwNoCatError
error('stats:ProbDist:NoCatAllowed', ...
    'Concatenation of ProbDist objects not allowed.\nUse a cell array to contain multiple objects.');
end

function throwUndefinedError
st = dbstack;
name = regexp(st(2).name,'\.','split');
error(['stats:' name{1} ':UndefinedFunction'], ...
      'Undefined function or method ''%s'' for input arguments of type ''%s''.',name{2},name{1});
end
