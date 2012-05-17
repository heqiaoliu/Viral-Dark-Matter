%% Using the IEC 61508 Modeling Standard Checks
% This demonstration uses Model Advisor checks for the IEC 61508 
% standard to facilitate developing a model and code that comply with that
% standard.
%
% The IEC 61508 checks quickly identify issues with a model 
% that impede deployment in safety-related applications or limit 
% traceability.
%

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/12/01 07:30:48 $


%% Understanding the Model to be Checked
% According to the functional requirements, a model shall be created 
% that checks whether the 1-norm distance between points |(x1,x2)| and 
% |(y1,y2)| is less than or equal to a given threshold |thr|. 
% For two points |(x1,x2)| and |(y1,y2)|, the 1-norm distance is
% given as:
%
% $$ \sum_{i=1}^{2} | x_i -y_i | $$
% 
% The <matlab:open_system('rtwdemo_iec61508'); |rtwdemo_iec61508|> model 
% implements the preceding requirement. Open and get familiar with the 
% model.
model='rtwdemo_iec61508';
open_system(model)

%% Applying the IEC 61508 Modeling Standard Checks
% To deploy the model in a safety-related software component that 
% must comply with the IEC 61508 safety standard, check the model for issues 
% that might impede deployment in such an environment or limit traceability 
% between the model and generated source code.
%
% To identify possible compliance issues with the model:
%
% # Start the Model Advisor by selecting *Tools > Model Advisor* or by 
% entering 
% <matlab:modeladvisor('rtwdemo_IEC61508'); |modeladvisor('rtwdemo_IEC61508')|> 
% at the MATLAB command line.    
% # In the *Task Hierarchy*, expand *By Product > Simulink Verification and
% Validation > Modeling Standards > IEC 61508 Checks* or *By Task > Modeling  
% Standards for IEC 61508*.  
% # Select all checks within the group.
% # Select *Show report after run* to generate an HTML report that shows 
% the check results. 
% # Click *Run Selected Checks*. 
% Model Advisor processes the IEC 61508 checks and displays the results.
% 
% To review the check results and make changes: 
%
% # Review the *Summary* in the *Report* section of the right pane.
% # In the *Task Hierarchy*, select a check that did not pass. Review the 
% results that appear in the right pane for that check. For more 
% information on the check and on how to resolve reported issues, with the 
% check selected, click *Help*.
% # Click the *Generate Code Using Real Time Workshop Embedded Coder*
% button in the model to inspect the generated code and the traceability
% report.
% # Resolve the reported issues and rerun the checks. 
% # Review the generated HTML report of the check results by clicking the 
% link in the *Report* box.
% # Print the generated HTML report. You can use the report as evidence in 
% the IEC 61508 compliance demonstration process.


%% See Also
%
% * For descriptions of the IEC 61508 checks, see   
% <matlab:helpview(fullfile(docroot,'toolbox','slvnv','ug','brlhdal.html')); IEC 61508 Checks> 
% in the Simulink Verification and Validation documentation.
%
% * For more information on using Model Advisor, see 
% <matlab:helpview(fullfile(docroot,'toolbox','simulink','ug','f4-141979.html')); Consulting the Model Advisor> 
% in the Simulink documentation.
%
% * For more information on IEC 61508 compliance, see   
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','ug','brj5vje-1.html')); Developing Models and Code That Comply with the IEC 61508 Standard>
% in the Real-Time Workshop Embedded Coder documentation.

displayEndOfDemoMessage(mfilename)
