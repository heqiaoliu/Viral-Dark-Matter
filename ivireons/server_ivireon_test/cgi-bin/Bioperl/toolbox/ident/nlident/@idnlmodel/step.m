function [you ,tou, yousd] = step(varargin)
%STEP  Step response of nonlinear models and direct estimation from IDDATA sets. 
%
%   STEP(MOD) plots the step response of the IDNLMODEL model MOD (either
%   IDNLGREY, IDNLARX, or IDNLHW).
%
%   STEP(DAT) estimates and plots the step response from the data set
%   DAT given as an IDDATA object.
%
%   For multi-input models, independent step commands are applied to each
%   input channel.
%
%   To obtain a stem plot rather than a regular plot, add the argument
%   'STEM' after the models: STEP(M, 'stem').
%
%   STEP(MOD, 'InputLevels', [U1; U2]) (or STEP(MOD, 'ULEV', [U1; U2))
%   gives a step from level U1 to level U2. For multi-input models the
%   levels may be different for different inputs, by letting InputLevels
%   be a 2-by-Nu matrix. The default is [1; 0].
%
%   The time span of the plot is determined by the argument T: STEP(MOD, T).
%   If T is a scalar, then the time from -T/4 to T is covered. For a step
%   response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t = 0). Default is T = 10.
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant
%   values: T = [T1:ts:T2] thus defining the sampling interval. For
%   discrete time models only max(T) and min(T) determine the time span.
%   The time interval is modified to contain the time t = 0, where the
%   input step occurs. The initial state vector is taken as the equilibrium
%   for the starting InputLevel, even when specified to something else in
%   MOD.
%
%   STEP(MOD1, MOD2, ..., DAT1, ..., T) plots the step responses of
%   multiple IDNLMODEL/IDMODEL models and IDDATA sets MOD1, MOD2, ...,
%   DAT1, ... in a single plot. The time vector T is optional. You can also
%   specify a color, line style, and markers for each system, as in
%      STEP(MOD1, 'r', MOD2, 'y--', MOD3, 'gx');
%
%   When responses of multiple models/data are plotted together, InputLevel
%   (if specified) should be the column vector [U1;U2] (same levels for all
%   inputs) or have as many columns as the maximum number of inputs 
%   across all models/data objects.
%
%   When invoked with left-hand arguments and a model input argument
%      [Y, T] = STEP(MOD);
%   returns the output response Y and the time vector T used for the
%   simulation.  No plot is drawn on the screen. If MOD has NY outputs and
%   NU inputs, and LT = length(T), Y is an array of size [LT NY NU] where
%   Y(:, :, j) gives the step response of the j-th input channel.
%
%   For a DATA input MOD = STEP(DAT), returns the model of the step
%   response, as an IDARX object. This can of course be plotted using
%   STEP(MOD). The calculation of the step response from data is based a
%   'long' FIR model, computed with suitably prewhitened input signals. The
%   order  of the prewhitening filter (default 10) can be set to NA by the
%   property/value pair STEP(..., 'PW', NA, ...) appearing anywhere in the
%   input argument list.
%
%   See also IDNLARX/SIM, IDNLHW/SIM, IDNLGREY/SIM, IDNLARX/LINEARIZE,
%   IDNLHW/LINEARIZE, IDNLARX/PLOT, IDNLHW/PLOT.

%   L. Ljung 10-2-90,1-9-93
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/10/02 18:54:37 $

% Retrieve the number of outputs.
no = nargout;

% Call utstep.
try
    if (no == 0)
        utstep(varargin{:});
    elseif (no == 1)
        you = utstep(varargin{:});
    elseif (no == 2)
        [you, tou] = utstep(varargin{:});
    else
        [you, tou] = utstep(varargin{:});
        yousd = [];
        ctrlMsgUtils.warning('Ident:idnlmodel:NoStdForIdnlmodel')
    end
catch E
    throw(E)
end