function demo(action,categoryArg) 
% DEMO Access product demos via Help browser. 
%
%   DEMO opens the Help browser and selects the MATLAB Demos
%   entry in the table of contents.
%
%   DEMO SUBTOPIC CATEGORY opens the Demos entry to the specified CATEGORY. 
%   CATEGORY is a product or group within SUBTOPIC.  SUBTOPIC is 'matlab', 
%   'toolbox', 'simulink', 'blockset', or 'links and targets'. When 
%   SUBTOPIC is 'matlab' or 'simulink', do not specify CATEGORY to show all
%   demos for the product.
%   
%   Examples:
%       demo 'matlab'
%       demo 'toolbox' 'signal'
%       demo 'matlab' 'getting started'
%
%   See also ECHODEMO, GRABCODE, HELP, HELPBROWSER.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/03 16:09:21 $

error(javachk('mwt',mfilename))
import com.mathworks.mlservices.MLHelpServices;
if nargin<1,
    MLHelpServices.showDemos;
elseif nargin==1
    MLHelpServices.showDemos(action);
elseif nargin==2
    MLHelpServices.showDemos(action, categoryArg);
end
