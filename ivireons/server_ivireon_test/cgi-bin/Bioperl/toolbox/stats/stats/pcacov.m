function [coeff,latent,explained] = pcacov(v)
% PCACOV  Principal Components Analysis using a covariance matrix.
%   COEFF = PCACOV(V) performs principal components analysis on the P-by-P
%   covariance matrix V, and returns the principal component coefficients,
%   also known as loadings.  COEFF is a P-by-P matrix, with each column
%   containing coefficients for one principal component.  The columns are
%   in order of decreasing component variance.
%
%   PCACOV does not standardize V to have unit variances.  To perform PCA
%   on standardized variables, use the correlation matrix R = V./(SD*SD'),
%   where SD = sqrt(diag(V)), in place of V.
%
%   [COEFF, LATENT] = PCACOV(V) returns the principal component variances,
%   i.e., the eigenvalues of V.
%
%   [COEFF, LATENT, EXPLAINED] = PCACOV(V) returns the percentage of the
%   total variance explained by each principal component.
%
%   See also BARTTEST, BIPLOT, FACTORAN, PCARES, PRINCOMP, ROTATEFACTORS.

%   References:
%     [1] Jackson, J.E., A User's Guide to Principal Components
%         Wiley, 1988.
%     [2] Jolliffe, I.T. Principal Component Analysis, 2nd ed.,
%         Springer, 2002.
%     [3] Krzanowski, W.J., Principles of Multivariate Analysis,
%         Oxford University Press, 1988.
%     [4] Seber, G.A.F., Multivariate Observations, Wiley, 1984.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:59:08 $

[~,latent,coeff] = svd(v);
latent = diag(latent);

totalvar = sum(latent);
explained = 100*latent/totalvar;

% Enforce a sign convention on the coefficients -- the largest element in each
% column will have a positive sign.
[p,d] = size(coeff);
[~,maxind] = max(abs(coeff),[],1);
colsign = sign(coeff(maxind + (0:p:(d-1)*p)));
coeff = bsxfun(@times,coeff,colsign);

