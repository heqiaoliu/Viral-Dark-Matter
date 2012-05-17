function [yh1, fit1, x01] = compare(varargin)
%COMPARE  Compares the simulated/predicted output(s) with the measured output(s).
%
%   COMPARE(DATA, SYS, M)
%
%   DATA: The data (an IDDATA or IDFRD object) for which the comparison is
%         made (the validation data set). For nonlinear models, DATA must
%         be in the time domain.
%   SYS : A linear (IDMODEL) or a nonlinear model (IDNLMODEL).
%   M   : The prediction horizon. Old outputs up to time t-M are used to
%         predict the output at time t. All relevant inputs are used.
%         M = Inf gives a pure simulation of the system. (Default: M =
%         Inf). 
%   
%   COMPARE(DATA, SYS, STYLE, M) allows specification of line style, color
%   or marker for the plot of the response of model SYS. STYLE should be a
%   string of applicable characters, as available for MATLAB's PLOT
%   command. Note that STYLE, if used, should precede the specification of
%   prediction horizon M.
%
%   COMPARE plots the simulated/predicted output together with the measured
%      output in DATA, and displays how much of the output variation has
%      been explained by the model. When DATA is in the frequency domain,
%      the absolute value of the corresponding frequency functions are
%      shown. When DATA is a frequency response data (IDFRD), the amplitude
%      of the model's and the data's frequency functions are shown in a
%      log-log diagram. A table of model fit to data is also shown. The fit
%      is calculated as
%
%      FIT = 100(1-norm(Y-YHAT)/norm(Y-mean(Y))) (in %)
%
%      where Y is the output of the validation data and YHAT is the model
%      output. The matching of input/output channels in DATA and SYS is
%      based on the channel names. It is thus possible to evaluate models
%      that do not use all input channels available in DATA.
%
%   Several Models:
%   COMPARE(DATA, SYS1, SYS2, ..., SYSn, M) compares several models. You
%      can also specify a color, line style, and marker for each system. If
%      both plot styles and prediction horizon are specified, the prediction
%      horizon must be specified as the last argument (following the list
%      of models and their plot styles), as in:
%      COMPARE(DATA, sys1, 'r', sys2, 'y--', sys3, 'gx', M). 
%
%   Further Options:
%   After the list of regular input arguments, Property-Value pairs can
%   be added:
%
%   COMPARE(DATA, SYS, .., SYSn, M, Prop_1, Value_1, Prop_2, Value_2);
%
%   Useful Property/Value pairs are:
%   'Samples'/SAMPNR: 
%      Here SAMPNR are the sample numbers in DATA to be plotted and used
%      for the computation of FIT. For multi-experiment data, SAMPNR must
%      be a cell array of the same size as the number of experiments.
%
%   'InitialState'/INIT: 
%      Handles the initial state of the model/predictor.
%      INIT = 'e' (default when data is iddata): Estimate the initial
%                  state for best fit.
%      INIT = 'm': Use the models' internally stored initial state.
%      INIT = 'z': (default when data is idfrd): Set the initial state to
%                  zero.
%      INIT = X0 : X0 is a column vector of the same length as the state
%                  vector. When using multi-experiment data, X0 may be
%                  specified as a matrix with as many columns as there are
%                  data experiments. 
%      INIT = X0struct:  Specify INIT using a struct array. This option is
%                  available only for Nonlinear Grey-Box (IDNLGREY) models.
%                  Type "idprops idnlgrey initialstates" for more
%                  information about this syntax. 
%
%      When using numerical values for INIT (X0 or X0struct) with multiple
%      models, make sure that the supplied values are meaningful for all
%      models.
%
%   'OutputPlots'/YPLOTS: Here YPLOTS is a cell array of those OutputNames
%         in DATA to be plotted. All outputs in DATA are used for the
%         computation of the predictions, though.
%
%   Output arguments:
%   [YH, FIT, X0] = COMPARE(DATA, SYS, ..., SYSn, M);
%   produces no plot, but returns the simulated/predicted model output YH,
%   FIT and X0, the initial states used in the computation.
%
%   YH is a cell array of IDDATA data sets, one for each model.
%   FIT is the percentage of the measured output that was explained by the
%      model. The formula for computing FIT is given above. FIT is a 3-D
%      array with element FIT(Kexp, Kmod, Ky) containing the fit for
%      experiment Kexp, model Kmod, and output Ky.
%   X0 is a cell array, so that X0{Kmod} is the initial state(s) used for
%      model Kmod. If DATA is multi-experiment. X0{Kmod} is a matrix, whose
%      column number Kexp is the initial state vector used for experiment
%      Kexp.
%
%   See also IDMODEL/SIM, IDMODEL/PREDICT, IDNLARX/SIM, IDNLARX/PREDICT,
%   IDNLHW/SIM, IDNLHW/PREDICT, IDNLGREY/SIM and IDNLGREY/PREDICT.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2008/03/13 17:24:43 $

% Author(s): L. Ljung

% Determine list of inputs.
no = nargout;
inpn = cell(1, length(varargin));
for kn = 1:length(varargin);
        inpn{kn} = inputname(kn);
end
v = {varargin{:} inpn};

% Call utcompare.
if (no == 0)
    utcompare(v{:});
elseif (no == 1)
    yh1 = utcompare(v{:});
elseif (no == 2)
    [yh1, fit1] = utcompare(v{:});
else
    [yh1, fit1, x01] = utcompare(v{:});
end
