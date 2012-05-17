function p=pdf(pd,x)
%PDF Probability density function for piecewise distribution.
%    P=PDF(OBJ,X) returns an array P of values of the probability density
%    function (PDF) for the piecewise distribution object OBJ, evaluated
%    at the values in the array X.
%
%    For a PARETOTAILS object, the pdf is computed using the generalized
%    Pareto distribution in the tails.  In the center, the pdf is computed
%    using the slopes of the cdf, which are interpolated between a set of
%    discrete values.  Therefore the pdf in the center is piecewise constant.
%    It is noisy when the object is created using the 'ecdf' value for the
%    CDFFUN argument in the PARETOTAILS function, and somewhat smoother for
%    the 'kernel' value, but generally not a good estimate of the underlying
%    density of the original data.
%
%    See also PIECEWISEDISTRIBUTION, PIECEWISEDISTRIBUTION/CDF.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:05 $

if any(arrayfun(@(s) isempty(s.pdf),pd.distribution))
    error('stats:piecewisedistribution:pdf:EmptyPdf',...
          'No PDF function handle is defined for this object');
end

% Determine the segment that each point occupies
s = segment(pd,x);

% Invoke the appropriate pdf for each segment
p = NaN(size(x),class(x));
for j=1:max(s(:))
    t = (s==j);
    if any(t(:))
        p(t) = pd.distribution(j).pdf(x(t));
    end
end
