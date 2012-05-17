%% Optimizing Generated Code Using Specified Minimum and Maximum Values
% This demo shows how the minimum and maximum values specified on signals
% and parameters in a model can be used to optimize the generated code.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 02:55:21 $

%% Overview
% The specified minimum and maximum values usually represent environmental
% limits, such as temperature, or mechanical and electrical limits, such as
% output ranges of sensors.
%
% This optimization uses these values to streamline the generated code, for
% example, by reducing expressions to constants or by removing dead branches of
% conditional statements.
%
% *NOTE:* You must ensure that the specified minimum and maximum values are
% accurate and trustworthy.  Otherwise, this optimization might result in
% numerical mismatch with simulation.
%
% The benefits of optimizing the generated code are:
%
% * Reducing the ROM and RAM consumption.
% * Improving the execution speed.


%% Review Minimum and Maximum Information
% Consider the model <matlab:rtwdemo_minmax rtwdemo_minmax>.
% In this model, there are minimum and maximum values specified on Inports and
% on the gain parameter of the Gain block.
open_system('rtwdemo_minmax');

%% Generate Code Without This Optimization
% 
% First, generate code for this model without considering the min and max values:
%
% # Double-click the blue button.  
% # An HTML Code Generation Report opens.
% # In the Code Generation Report, click "rtwdemo_minmax.c".
% # The generated code is:
%
%   void rtwdemo_minmax_step(void)
%   {
%     if (U1 + U2 <= k * U3) {
%       rtY.Out1 = (U1 + U2) + U3;
%     } else {
%       rtY.Out1 = U1 * U2 * U3;
%     }
%   }
% 

%% Enable This Optimization
% # Double-click the yellow button to open the Configuration Parameters
%   dialog box.  
% # In the dialog, under *Code generation*, select 
%   *Optimize using the specified minimum and maximum values*.
%

%% Generate Code With This Optimization
% In the model, with the specified minimum and maximum values for U1 and U2,
% the sum of U1 and U2 has a minimum value of 50.  Considering the range of U3
% and the specified minimum and maximum values for the Gain block parameter, the
% maximum value of the Gain block's output is 40.
%
% Therefore, the output of the Relational Operator block is always false, and
% the output of the Switch block is always the product of the three inputs.
%
% To generate code, double-click the blue button and examine the Code Generation
% Report.  The generated code shows that the output is always equal to the
% product of the three inputs, optimizing out the conditional statement:
%
%   void rtwdemo_minmax_step(void)
%   {
%     rtY.Out1 = U1 * U2 * U3;
%   }


displayEndOfDemoMessage(mfilename)
