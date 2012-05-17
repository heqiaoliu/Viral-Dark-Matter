function iddemo
%   SYSTEM IDENTIFICATION TOOLBOX is an analysis module
%   that contains tools for building mathematical models of
%   dynamical systems, based upon observed input-output data.
%   The toolbox contains both PARAMETRIC and NON-PARAMETRIC
%   MODELING methods.
%
%   System Identification Toolbox demonstrations:
%
%   Linear Model Estimation Features:
%   --------------------------------
%   1) The Graphical User Interface (ident): A guided Tour.
%   2) Build simple models from real laboratory process data.
%   3) Compare different identification methods.
%   4) Data and model objects in the Toolbox.
%   5) Dealing with multivariable systems.
%   6) Building structured and user-defined models.
%   7) Model structure determination case study.
%   8) Use of frequency domain data.
%   9) How to deal with multiple experiments.
%   10) Spectrum estimation (Marple's test case).
%   11) Adaptive/Recursive algorithms.
%   12) Use of SIMULINK and continuous time models.
%   13) Case studies.
%   14) Use of process models (gain+time constant+delay)
%
%   0) Quit
%
%   Nonlinear Black Box Model Estimation Features
%   ----------------------------------------------
%   1) SISO model estimation - a two tank system example
%   2) MIMO model estimation  - a motorized camera example
%   3) Nonlinear ARX models with custom regressors
%   4) Nonlinear modeling of a magneto-rheological fluid damper (case study)
%
%   0) Quit
%
%   Nonlinear Grey Box Model Estimation Features
%   --------------------------------------------
%    1) Linear modeling of a DC-motor                     (MATLAB file modeling of time-continuous SIMO system)
%    2) A two tank system                                 (C MEX-file modeling of time-continuous SISO system)
%    3) Three ecological population systems               (MATLAB and C MEX-file modeling of time-continuous time-series)
%    4) Narendra-Li benchmark system                      (MATLAB file modeling of time-discrete SISO system)
%    5) Friction modeling                                 (MATLAB file modeling of static SISO system)
%    6) Signal transmission system                        (C MEX-file modeling using optional input arguments)
%    7) Dry friction between two bodies                   (C MEX-file modeling using multiple experiments)
%    8) An industrial three degrees of freedom robot      (C MEX-file modeling of MIMO system using vector/matrix parameters)
%    9) A non-adiabatic continuous stirred tank reactor   (MATLAB file modeling with simulations in Simulink)
%   10) A classical pendulum                              (some algorithm related issues)
%
%   11) A vehicle dynamics system                         (case study based on real-world data)
%   12) Modeling an aerodynamic body                      (case study based on large system modeling)
%   13) An industrial robot arm                           (case study based on real-world data)
%
%   14) Creating IDNLGREY Model Files                     (discusses various aspects of IDNLGREY model files)
%
%    0) Quit

%   L. Ljung, Peter Lindskog, Qinghua Zhang
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.13.4.8 $ $Date: 2010/03/22 03:48:22 $

fprintf('%s\n  %s\n  %s\n  %s\n  %s\n',...
    'Select the category of demos to expore: ',...
    'Enter 1 for linear model and general features demos.',...
    'Enter 2 for nonlinear black box demos.',...
    'Enter 3 for nonlinear grey box demos.',...
    'Enter 0 to Quit.')

while true
    Type = input('Demo type: ');
    %[status,k] = localQualifyType(typestr)
    if (Type==1) || (Type==2) || (Type==3) || (Type==0)
        break;
    else
        disp('Invalid selection for demo type.')
        disp('Enter 1 for linear, 2 for nonlinear black box, or 3  for nonlinear grey box demos. (0 to Quit).')
        disp(' ')
    end
end

switch Type
    case 1
        localShowLinearDemos;
    case 2
        localShowNonlinearBlackBoxDemos;
    case 3
        localShowNonlinearGreyBoxDemos;
    otherwise
        disp('End of demo mode.')
        return;
end

%--------------------------------------------------------------------------
function localShowLinearDemos
%---------------------------------------------------------
%   Linear Model Estimation Features:
%---------------------------------------------------------
%   1) The Graphical User Interface (System Identification Tool): A guided tour.
%   2) Build simple models from real laboratory process data.
%   3) Compare different identification methods.
%   4) Data and model objects in the Toolbox.
%   5) Dealing with multivariable systems.
%   6) Building structured and user-defined models.
%   7) Model structure determination case study.
%   8) Use of frequency domain data.
%   9) How to deal with multiple experiments.
%   10) Spectrum estimation (Marple's test case).
%   11) Adaptive/Recursive algorithms.
%   12) Use of SIMULINK and continuous time models.
%   13) Case studies.
%   14) Use of process models (gain+time constant+delay)
%
%   0) Quit


help iddemo>localShowLinearDemos
k = localPromptForDemoNumber('l');

switch k
    case 0
        return;
    case 1
        iduidemo(0)
    case 2
        echodemo iddemo1
    case 3
        echodemo iddemo2
    case 4
        echodemo iddemo6
    case 5
        echodemo iddemo9
    case 6
        echodemo iddemo7
    case 7
        echodemo iddemo3
    case 8
        echodemo iddemofr
    case 9
        echodemo iddemo8
    case 10
        echodemo iddemo4
    case 11
        echodemo iddemo5
    case 12
        echodemo iddemosl
    case 13
        cs
    case 14
        echodemo iddemopr
    otherwise
        disp('Invalid choice linear model demos. Choose 1, 2, ... or 14.');
        return;
end

%--------------------------------------------------------------------------
function localShowNonlinearBlackBoxDemos
%----------------------------------------------------------------
%   Nonlinear Black Box Model Estimation Features
%----------------------------------------------------------------
%   1) SISO model estimation - a two tank system example
%   2) MIMO model estimation  - a motorized camera example
%   3) Nonlinear ARX models with custom regressors
%   4) Nonlinear modeling of a magneto-rheological fluid damper (case study)

help iddemo>localShowNonlinearBlackBoxDemos
k = localPromptForDemoNumber('nlb');

switch k
    case 0
        return;
    case 1
        echodemo idnlbbdemo_siso
    case 2
        echodemo idnlbbdemo_mimo
    case 3
        echodemo idnlbbdemo_customreg
    case 4
        echodemo idnlbbdemo_damper
    otherwise
        disp('Invalid choice for nonlinear black box demos. Choose 1, 2, 3 or 4.');
        return;
end

%--------------------------------------------------------------------------
function localShowNonlinearGreyBoxDemos
%----------------------------------------------------------------------------------------------------------
%   Nonlinear Grey Box Model Estimation Features
%----------------------------------------------------------------------------------------------------------
%    1) Linear modeling of a DC-motor                     (MATLAB file modeling of time-continuous SIMO system)
%    2) A two tank system                                 (C MEX-file modeling of time-continuous SISO system)
%    3) Three ecological population systems               (MATLAB and C MEX-file modeling of time-continuous time-series)
%    4) Narendra-Li benchmark system                      (MATLAB file modeling of time-discrete SISO system)
%    5) Friction modeling                                 (MATLAB file modeling of static SISO system)
%    6) Signal transmission system                        (C MEX-file modeling using optional input arguments)
%    7) Dry friction between two bodies                   (C MEX-file modeling using multiple experiments)
%    8) An industrial three degrees of freedom robot      (C MEX-file modeling of MIMO system using vector/matrix parameters)
%    9) A non-adiabatic continuous stirred tank reactor   (MATLAB file modeling with simulations in Simulink)
%   10) A classical pendulum                              (some algorithm related issues)
%
%   11) A vehicle dynamics system                         (case study based on real-world data)
%   12) Modeling an aerodynamic body                      (case study based on large system modeling)
%   13) An industrial robot arm                           (case study based on real-world data)
%
%   14) Creating IDNLGREY Model Files                     (discusses various aspects of IDNLGREY model files)
%
%    0) Quit


help iddemo>localShowNonlinearGreyBoxDemos
k = localPromptForDemoNumber('nlg');

switch k
    case 0
        return;
    case 1
        echodemo idnlgreydemo1;
    case 2
        echodemo idnlgreydemo2;
    case 3
        echodemo idnlgreydemo3;
    case 4
        echodemo idnlgreydemo4;
    case 5
        echodemo idnlgreydemo5;
    case 6
        echodemo idnlgreydemo6;
    case 7
        echodemo idnlgreydemo7;
    case 8
        echodemo idnlgreydemo8;
    case 9
        echodemo idnlgreydemo9;
    case 10
        echodemo idnlgreydemo10;
    case 11
        echodemo idnlgreydemo11;
    case 12
        echodemo idnlgreydemo12;
    case 13
        echodemo idnlgreydemo13;
    case 14
        echodemo idnlgreymodelfile;
    otherwise
        disp('Invalid choice for nonlinear grey box demos. Choose 1, 2, ... or 14.');
        return;
end



%--------------------------------------------------------------------------
function k = localPromptForDemoNumber(type)

if strcmpi(type,'l')
    str = '1 to 14 (0 to quit)';
elseif strcmpi(type,'nlg')
    str = '1 to 14 (0 to quit)';
elseif strcmpi(type,'nlb')
    str = '1 to 4 (0 to quit)';
end

% no demo number specified; prompt for it
k = input(sprintf('Select a demo number (%s):',str));
if isempty(k),
    k = 50;
end
