classdef InheritRuleCustomizer < handle
%InheritRuleCustomizer  Class definition of InheritRuleCustomizer.

% Copyright 2001-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/09/28 20:44:56 $

% This is a Singleton class that maintains a list of inheritance rules
% used by (built-in or user-defined) Simulink blocks.

    properties (SetAccess=private)
        mCustomRules;
    end % properties

    methods (Access=public)
        function registerCustomRules(obj, rules)
            try 
                Simulink.InheritRuleCustomizer.verifyRules(rules);
            catch me
                throwAsCaller(me);
            end

            % Rules that are already registered are ignored.
            % The rules are sorted in chronicle order of their registration
            obj.mCustomRules = [obj.mCustomRules; ...
                                setdiff(setdiff(rules(:), obj.mBuiltinRules), ...
                                        obj.mCustomRules)];
        end

        function rules = getCustomRules(obj)
            rules = obj.mCustomRules;
        end
    end

    methods (Access=public,Hidden)
        % Used for testing only
        function clearCustomRules(obj)
            obj.mCustomRules = {};
        end
    end % public methods

    methods (Access=public,Static)
        function customizer = getCustomizer()
            customizer = Simulink.InheritRuleCustomizer.mCustomizer;
        end
    end

    properties (GetAccess=private,Constant)
        mCustomizer = Simulink.InheritRuleCustomizer();
    end

    properties (Constant)
        mBuiltinRules = { 'Inherit: Inherit via internal rule'; ...
                          'Inherit: Inherit via back propagation'; ...
                          'Inherit: Same as input'; ...
                          'Inherit: Same as first input'; ...
                          'Inherit: Same as second input'; ... ...
                          'Inherit: All ports same datatype'; ...
                          'Inherit: Inherit from ''Breakpoint data'''; ...
                          'Inherit: Inherit from ''Constant value'''; ...
                          'Inherit: Inherit from ''Table data'''; ...
                          'Inherit: Logical (see Configuration Parameters: Optimization)'; ...
                          'Inherit: Same as accumulator'; ...
                          'Inherit: Same as product output'; ...
                          'Inherit: Same as output'; ...
                          'Inherit: Same as Simulink'; ...
                          'Inherit: Same word length as input' 
                       };
    end % properties

    methods (Access=private)
        function obj = InheritRuleCustomizer()
            mlock; % lock the class definition to suppress 'clear classes' warning
            obj.mCustomRules = {};
        end

        % Make object.delete illegal.
        function delete(object) %#ok
        end
    end

    methods (Access=private,Static)
        function verifyRules(rules)
            rules = rules(:);
            if ~iscell(rules)
                throw(MException('Simulink:tools:RegRuleInvalidSignature', ...
                                 DAStudio.message('Simulink:tools:RegRuleInvalidSignature', ...
                                                  'rules')));
            end
            me = [];
            for i = 1:length(rules)
                rule = rules{i};
                if ~isempty(regexp(rule, '[|{},]', 'once'))
                    if isempty(me)
                        me = MException('Simulink:tools:RegRuleInvalidRuleSet', ...
                                        DAStudio.message('Simulink:tools:RegRuleInvalidRuleSet'));
                    end
                    causeME = MException('Simulink:tools:RegRuleInvalidChar', ...
                                         DAStudio.message('Simulink:tools:RegRuleInvalidChar', ...
                                                          rule));
                    me = addCause(me, causeME);
                end

                if ~strncmp(rule, 'Inherit: ', 9);  % 9 == length('Inherit: ')
                    if isempty(me)
                        me = MException('Simulink:tools:RegRuleInvalidRuleSet', ...
                                        DAStudio.message('Simulink:tools:RegRuleInvalidRuleSet'));
                    end
                    causeME = MException('Simulink:tools:RegRuleInvalidPrefix', ...
                                         DAStudio.message('Simulink:tools:RegRuleInvalidPrefix', ...
                                                          rule));
                    me = addCause(me, causeME);
                end
            end
            if ~isempty(me)
                throw(me);
            end
        end
    end % private methods
end
        
