classdef ProbDistKernel < ProbDist
%ProbDistKernel Probability distribution defined by kernel smoothing.
%   ProbDistKernel is an abstract class defining the properties and methods
%   for a nonparametric distribution defined by a kernel smoothing function.
%   You cannot create instances of this class directly.  You must create a
%   derived class such as ProbDistUnivKernel.
%
%   ProbDistKernel properties:
%       Kernel     - kernel smoothing function
%       BandWidth  - bandwidth for kernel smoothing
%
%   See also PROBDIST, PROBDISTUNIVKERNEL, FITDIST.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:04 $

    properties(GetAccess='public', SetAccess='protected')
%KERNEL - Kernel smoothing function.
%   The Kernel property specifies the name of the kernel smoothing function
%   to be used to compute a nonparametric estimate of the probability
%   distribution.  Choices are 'normal', 'box', 'triangle', and
%   'epanechnikov'.
%
%   See also PROBDIST, KSDENSITY.
        Kernel = 'normal';

%BANDWIDTH - Bandwidth of kernel smoothing function.
%   The BandWidth property specifies the width of the kernel smoothing
%   function to be used to compute a nonparametric estimate of the
%   probability distribution.  For a distribution specified to cover only
%   the positive numbers or only a finite interval, the data are
%   transformed before the kernel density is applied, and the bandwidth is
%   on the scale of the transformed data.
%
%   See also PROBDIST, KSDENSITY.
        BandWidth = [];
    end
end % classdef
