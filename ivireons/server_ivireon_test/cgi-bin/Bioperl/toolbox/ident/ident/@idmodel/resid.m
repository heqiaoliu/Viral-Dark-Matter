function [e1,r1,adv]=resid(varargin)
%RESID  Compute and test the residuals associated with a model.
%
% Usage:
%   RESID(MODEL,DATA)
%   RESID(MODEL,DATA,MODE)
%   RESID(MODEL,DATA,MODE,LAGS)
%  
%   DATA: The output-input data as an IDDATA or IDFRD object.
%   MODEL: The model to be evaluated on the given data set.
%          This is an IDMODEL object, like IDPOLY, IDPROC, IDSS,IDARX or IDGREY.
%   MODE: One of:
%    'CORR' (default). Correlation analysis performed.
%    'IR' : The impulse response from the input to the residuals is shown
%    'FR' : The (amplitude) frequency response from the input to the
%           residuals is shown.
%    (For frequency domain data, 'FR' is default.)
%  
% The model residuals (prediction errors) E from MODEL when applied to
% DATA are computed. When MODE = 'CORR', the autocorrelation function of
% E and the cross correlation between E and the input(s) is computed and
% displayed. When MODE = 'IR' or 'FR' a model from the inputs to E is
% computed, and displayed either as an impulse response or a frequency
% response. 
%  
% All these response curves should be "small". In all cases, 99 % confidence
% regions around zero limits for these values are also given.
% For a model to pass the residual test, the curves should thus ideally
% be inside the yellow regions.
%  
% The correlation functions for MODE = 'CORR' are given up to lag 25, which
% can be changed to M by RESID(MODEL,DATA,MODE,M). If M is specified, this
% will also be the number of positive lags used for the impulse response in
% the 'IR' case. Specification of lags is not meaningful when MODE = 'FR'.
% 
% Note that the confidence intervals obtained for IDFRD data may be
% misleading depending on the amount of data compression in the data set.
% 
% E = RESID(MODEL,DATA,...) produces no plot but returns residuals E
% associated with MODEL and DATA. E an IDDATA object with the residuals
% as output and the input of DATA as input.  
%  
% See also PE, PREDICT, COMPARE.

%   L. Ljung 10-1-86,1-25-92
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.25.4.7 $  $Date: 2008/04/28 03:19:51 $

no = nargout;
for kn = 1:length(varargin);
    if isa(varargin{kn},'idmodel')
        inpn = inputname(kn);
        break;
    end
end

v = {varargin{:} inpn};
if no == 0
    utresid(v{:});
elseif no == 1
    e1 = utresid(v{:});
elseif no == 2
    [e1,r1] = utresid(v{:});
else
    [e1,r1,adv] = utresid(v{:});
end

% A variable named value of inpn should have been created by utcompare,
% provided inpn is not empty
try
    assignin('caller',inpn,eval(inpn));
end
