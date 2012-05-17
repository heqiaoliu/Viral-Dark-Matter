%SIMULINK.FINDVARS returns information describing variables both required 
%and used by a Simulink block or block diagram context
%
%    VARS = Simulink.findVars(CONTEXT) returns one or more 
%    Simulink.WorkspaceVar objects describing referenced workspace 
%    variables for the given Simulink block or block diagram CONTEXT(s).
%
%    VARS = Simulink.findVars(CONTEXT, C1, CV1, C2, CV2, ...) uses the
%    constraint/value pairs C1, CV1, etc. to constrain the search criteria.
%
%    VARS = Simulink.findVars(CONTEXT, C1, CV1, ..., P1, PV1, ...) uses the 
%    property/value pairs P1, PV1, etc. to filter the return values.
% 
%    VARS = Simulink.findVars(CONTEXT, VARS_IN, ...) limits results to the
%    variables specified in VARS_IN.
%
%    Optional input constraints (default values in parenthesis):
%
%      - 'SearchMethod' : ('compiled')|'cached'
%
%          'compiled' - Compile the parent model for each context involved 
%          in the search. Data returned from this search is guaranteed to 
%          be both accurate and complete.
%
%          'cached' - do not perform a search, simply return any values 
%          cached during the last compile (update-diagram) of the model 
%          containing CONTEXT. 
%
%      - 'Regexp' : ('off')|'on'
%        If on, use regular expression pattern matching when filtering 
%        results for string properties only. 
%
%    Examples:
%
%       % Find all workspace variables mymodel uses
%       vars = Simulink.findVars('mymodel');
%
%       % Find all uses of base workspace variable 'k' by model 'mymodel'.
%       var = Simulink.findVars('mymodel', ...
%                               'WorkspaceType', 'base', ...
%                               'Name', 'k');
%
%       % Find all uses of variables of a particular pattern by 
%       % model 'mymodel'
%       vars = Simulink.findVars('mymodel', 'Regexp', 'on', ...
%                                'Name', '^trans');
%  
%    See also Simulink.WorkspaceVar, find_system

%   Copyright 2009 The MathWorks, Inc.

