function [you,tou,ysdou] = step(varargin)
%STEP  Step response of IDMODELs and direct estimation from IDDATA sets.
%
%   STEP(MOD) plots the step response of the IDMODEL model MOD (either 
%   IDPOLY, IDARX, IDSS or IDGREY).  
%
%   STEP(DAT) estimates and plots the step response from the data set 
%   DAT given as an IDDATA object.
%
%   For multi-input models, independent step commands are applied to each 
%   input channel.  
%
%   STEP(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations. Add the argument 'FILL' after the models to show 
%   the confidence region(s) as a band instead: STEP(M,'sd',3,'fill'). The
%   confidence region is rendered using a lighter shade of the line color.
%
%   To obtain a stem plot rather than a regular plot, add the argument 'STEM'
%   after the models: STEP(M,'stem').
%
%   STEP(MOD,'InputLevels',[U1;U2]) (or STEP(MOD,'ULEV',[U1;U2]))
%   gives a step from level U1 to level U2. For multi-input models the
%   levels may be different for different inputs, by letting the InpuLevel
%   matrix be 2-by-nu. 
%
%   The time span of the plot is determined by the argument T: STEP(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For a
%   step response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0). If T is omitted, a default
%   choice is made
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input step occurs. The initial state vector
%   is determined as the equilibrium for the starting input level, even when 
%   specified to something else in MOD.
%
%   STEP(MOD1,MOD2,..,DAT1,..,T) plots the step responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot. 
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in  
%      STEP(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When responses of multiple models/data are plotted together, InputLevel
%   (if specified) should be the column vector [U1;U2] (same levels for all
%   inputs) or have as many columns as the maximum number of inputs 
%   across all models/data objects.
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = STEP(MOD) 
%   returns the output response Y and the time vector T used for 
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the step response of the 
%   j-th input channel. YSD contains the standard deviations of Y.
%   
%   For a DATA input MOD = STEP(DAT),  returns the model of the 
%   step response, as an IDARX object. This can of course be plotted
%   using STEP(MOD). The calculation of the step response from data is based a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the 
%   property/value pair  STEP( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list.
%
%   NOTE: IDMODEL/STEP and IDDATA/STEP are adjusted to the use with
%   identification tasks. If you have CONTROL SYSTEM TOOLBOX and want
%   to access the LTI/STEP, use VIEW(MOD1,....,'step').  

%   L. Ljung 10-2-90,1-9-93
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.22.4.14 $  $Date: 2009/03/09 19:13:40 $

try
    if nargout == 0
        utstep(varargin{:})
    elseif nargout == 1
        you = utstep(varargin{:});
    elseif nargout == 2
        [you,tou] = utstep(varargin{:});
    elseif nargout == 3
        [you,tou,ysdou] = utstep(varargin{:});
    end
catch E
    throw(E)
end


 