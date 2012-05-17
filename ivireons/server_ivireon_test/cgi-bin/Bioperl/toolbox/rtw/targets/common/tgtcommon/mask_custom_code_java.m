function varargout = mask_custom_code_java(action,varargin)
%MASK_CUSTOM_CODE

%   Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $

   import('javax.swing.*');
   import('java.awt.*');

   switch action
   case 'reset'
      block = varargin{1};

      % The data before mask processing occurs
      obj.unique = 1;
      obj.key='';
      obj.location='Subsystem Enable Function';
      obj.vars = '';
      obj.top = '';
      obj.middle = '';
      obj.bottom = '';

      set_param(block,'userdatapersistent','on');
      set_param(block,'userdata',obj);

   case 'initfcn'
      block = varargin{1};
      obj.block = varargin{1};
      data = get_param(block,'userdata');


      % Window
      dialogFrame = awtcreate('javax.swing.JFrame');
      obj.dialog = handle(dialogFrame, 'callbackproperties');

      b = awtcreate('javax.swing.Box', 'I', javax.swing.BoxLayout.Y_AXIS);      
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtinvoke(b, 'createVerticalStrut(I)', 12));
      awtinvoke(awtinvoke(dialogFrame, 'getContentPane'), 'add(Ljava.awt.Component;Ljava.lang.Object;)', b, java.awt.BorderLayout.NORTH);


      % UniqueCombo
      awtinvoke(b , 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JLabel', 'Ljava.lang.String;', 'Unique Code Generation'))
      obj.UniqueJComboBox = awtcreate('javax.swing.JComboBox');
      awtinvoke(obj.UniqueJComboBox, 'addItem(Ljava.lang.Object;)', 'Generate for every instance');
      awtinvoke(obj.UniqueJComboBox, 'addItem(Ljava.lang.Object;)', 'Generate once per functional mask');
      awtinvoke(obj.UniqueJComboBox, 'addItem(Ljava.lang.Object;)', 'Generate once per model');

      awtinvoke(b, 'add(Ljava.awt.Component;)', obj.UniqueJComboBox);
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtinvoke(b, 'createVerticalStrut(I)', 5));
      awtinvoke(obj.UniqueJComboBox, 'setSelectedIndex(I)', data.unique - 1);

      %Location
      awtinvoke(b , 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JLabel', 'Ljava.lang.String;', 'Code Location'));
      
      obj.LocationJComboBox = awtcreate('javax.swing.JComboBox');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Header File');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Export Header');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Parameter File');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Source File');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Registration File');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Initialize Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Outputs Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Update Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Derivatives Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Terminate Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Enable Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Subsystem Disable Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Registration Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Model Start Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Model Initialize Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Model Terminate Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Model Outputs Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Model Update Function');
      awtinvoke(obj.LocationJComboBox, 'addItem(Ljava.lang.Object;)', 'Model Derivatives Function');


      awtinvoke(b, 'add(Ljava.awt.Component;)', obj.LocationJComboBox);
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtinvoke(b, 'createVerticalStrut(I)', 5)); 
      awtinvoke(obj.LocationJComboBox , 'setSelectedItem(Ljava.lang.Object;)', data.location); 
      
      %Key
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JLabel', 'Ljava.lang.String;', 'Key'));
      obj.KeyTextField = awtcreate('javax.swing.JTextField', 'Ljava.lang.String;', '');
      awtinvoke(b, 'add(Ljava.awt.Component;)', obj.KeyTextField);
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtinvoke(b, 'createVerticalStrut(I)', 5));
      awtinvoke(obj.KeyTextField, 'setText(Ljava.lang.String;)', data.key);

      %Imported Vars
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JLabel', 'Ljava.lang.String;', 'Imported Variables'));
      obj.VariablesJTextField = awtcreate('javax.swing.JTextField');
      awtinvoke(b, 'add(Ljava.awt.Component;)', obj.VariablesJTextField);
      awtinvoke(b, 'add(Ljava.awt.Component;)', awtinvoke(b, 'createVerticalStrut(I)', 5));
      awtinvoke(obj.VariablesJTextField, 'setText(Ljava.lang.String;)', data.vars);
      
      %Code
      obj.tabbedPane = awtcreate('javax.swing.JTabbedPane');
      
      awtinvoke(obj.tabbedPane, 'setBorder(Ljavax.swing.border.Border;)', javax.swing.BorderFactory.createTitledBorder('Custom Code Sections'));
      obj.topPanel = awtcreate('javax.swing.JPanel', 'Ljava.awt.LayoutManager;', java.awt.BorderLayout);
      obj.middlePanel = awtcreate('javax.swing.JPanel', 'Ljava.awt.LayoutManager;', java.awt.BorderLayout);
      obj.bottomPanel = awtcreate('javax.swing.JPanel', 'Ljava.awt.LayoutManager;', java.awt.BorderLayout);

      awtinvoke(obj.tabbedPane, 'addTab(Ljava.lang.String;Ljava.awt.Component;)', 'Top', obj.topPanel);
      awtinvoke(obj.tabbedPane, 'addTab(Ljava.lang.String;Ljava.awt.Component;)', 'Middle', obj.middlePanel);
      awtinvoke(obj.tabbedPane, 'addTab(Ljava.lang.String;Ljava.awt.Component;)', 'Bottom', obj.bottomPanel);
      awtinvoke(obj.tabbedPane, 'setPreferredSize(Ljava.awt.Dimension;)', Dimension(300,350));
      awtinvoke(awtinvoke(dialogFrame, 'getContentPane'), 'add(Ljava.awt.Component;)', obj.tabbedPane);
      
      obj.topJTextArea = awtcreate('javax.swing.JTextArea');
      obj.middleJTextArea = awtcreate('javax.swing.JTextArea');
      obj.bottomJTextArea = awtcreate('javax.swing.JTextArea');

      awtinvoke(obj.topPanel, 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JScrollPane', 'Ljava.awt.Component;', obj.topJTextArea));
      awtinvoke(obj.middlePanel, 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JScrollPane', 'Ljava.awt.Component;', obj.middleJTextArea));      
      awtinvoke(obj.bottomPanel, 'add(Ljava.awt.Component;)', awtcreate('javax.swing.JScrollPane', 'Ljava.awt.Component;', obj.bottomJTextArea));
      awtinvoke(obj.topJTextArea, 'setText(Ljava.lang.String;)', data.top);
      awtinvoke(obj.middleJTextArea, 'setText(Ljava.lang.String;)', data.middle);
      awtinvoke(obj.bottomJTextArea, 'setText(Ljava.lang.String;)', data.bottom);

      % Apply Cancel OK Buttons
      p = awtcreate('javax.swing.JPanel', 'Ljava.awt.LayoutManager;', awtcreate('java.awt.FlowLayout', 'III', java.awt.FlowLayout.RIGHT, 5, 5));
      obj.applyButton = handle(awtcreate('javax.swing.JButton', 'Ljava.lang.String;', 'Apply'), 'callbackproperties');
      obj.okButton = handle(awtcreate('javax.swing.JButton', 'Ljava.lang.String;', 'OK'), 'callbackproperties');
      obj.cancelButton = handle(awtcreate('javax.swing.JButton', 'Ljava.lang.String;', 'Cancel'), 'callbackproperties');

      awtinvoke(p, 'add(Ljava.awt.Component;)', obj.okButton.java);
      awtinvoke(p, 'add(Ljava.awt.Component;)', obj.cancelButton.java);
      awtinvoke(p, 'add(Ljava.awt.Component;)', obj.applyButton.java);

      set(obj.applyButton,'ActionPerformedCallback', { @i_action_button_callback obj 'apply' }); 
      set(obj.okButton,'ActionPerformedCallback', { @i_action_button_callback obj 'ok' }); 
      set(obj.cancelButton,'ActionPerformedCallback', { @i_action_button_callback obj 'cancel' }); 

      awtinvoke(awtinvoke(dialogFrame, 'getContentPane'), 'add(Ljava.awt.Component;Ljava.lang.Object;)', p, java.awt.BorderLayout.SOUTH);

      awtinvoke(dialogFrame, 'pack()');

      screen_size = java.awt.Toolkit.getDefaultToolkit.getScreenSize;
      dialog_size = obj.dialog.getSize;

      new_pos = Dimension((screen_size.width-dialog_size.width)/2,(screen_size.height-dialog_size.height)/2);
      awtinvoke(dialogFrame, 'setLocation(II)', new_pos.width, new_pos.height);

      awtinvoke(dialogFrame, 'show()');
      awtinvoke(dialogFrame, 'toFront()');
      
   case 'process_code'
      block = varargin{1};
      data = get_param(block,'userdata');

      % Generate a string like
      % '{ var1 var2 var3 }'
      % that can be evaluated
      vars = [ '{ ' data.vars ' } ' ]; 
      parent = get_param(block,'parent');

      %% Evaluate the imported variables and
      %% place the results in a cell array
      try
         parent = i_get_masked_parent(block);
         if ~isempty(parent)
            ws_name = parent;
            ws = get_param(parent,'maskwsvariables'); 
            evaluated_vars = local_eval(ws,vars);
            key = local_eval(ws,data.key);

         else
            ws_name = 'base';
            evaluated_vars = evalin('base',vars);
            key = evalin('base',data.key);
         end
      catch e
         str =[ 'Tried to import variables : ', vars ,...
              'from the "' ws_name '" workspace. ' ,...
            'but got the error ',...
            e.message, ...
            '. Either change the variable name or make sure the variable exists.']; 
         error(str);

      end

      %% Turn the varnames into a cell array
      %% of strings.
      if ~isempty(data.vars)
         varnames = strread(data.vars,'%s');
      else
         varnames = {};
      end

      %% Process each code snippet in a TLC workspace
      top    = process_template(data.top,    varnames, evaluated_vars);
      middle = process_template(data.middle, varnames, evaluated_vars);
      bottom = process_template(data.bottom, varnames, evaluated_vars);

      [dispstr,rtwdata] = mask_custom_code(data.unique,key,data.location, top, middle, bottom);
      varargout = { dispstr,rtwdata };

   otherwise
      error([action ' is an invalid action.']);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CREATE_TEMPLATE - generate a MatlabTemplateEngine template
   %%
   %% text  -  the text from the template body
   %% vars  -  the list of variables to be passed to the template
   function text = process_template(text, vars, varvalues)
       if isempty(regexp(text,'^\s*$'))
           arglist = sprintf('%s, ', vars{:});
           arglist = ['( ' arglist(1:end-1) ')' ];
           header = ['#template ' arglist ];
           templatetext = sprintf('%s\n%s',header,text);
           % get the current MATLAB display format
           currentFormat = get(0, 'Format');
           % set the MATLAB display format to avoid the possibility
           % that the user has it set to 'bank'; the 'bank' format
           % causes problems when the MATLAB Template Engine trys to
           % process unformatted arguments
           format('short');
           template = MatlabTemplateEngine.Template('<',templatetext);
           try
               text = template.exec(varvalues{:});
           catch e
               % always return the MATLAB display format to the
               % appropriate setting
               format(currentFormat);
               error(sprintf('TEMPLATE ERROR\n--------------\n%s\n%s',template.mlint, e.message));
           end
           % always return the MATLAB display format to the
           % appropriate setting
           format(currentFormat);
       else
           text = '';
       end
      

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Evaluate the expr in a TLC context after
   %% loading in the variables into the TLC 
   %% context
function code = tlc_expr(expr,varnames,evaluated_vars,error_str)
   try
      h = tlchandle;
      load_vars(h,varnames,evaluated_vars);
      code = tlc('execstring',h.Handle,  expr );
      close(h);
   catch e
      close(h);
      
      error([sprintf('\n-------------------------\n') error_str ...
         sprintf('\n-------------------------\n') expr ...
         sprintf('\n-------------------------\n') e.message]);
   end



   %%--------------------------------------------------------------------- 
   %% Evaluate the expression in the context of the workspace object
   %%
   %% Arguments
   %%   ws_xa_yz_zt_8123   -  The workspace object
   %%   expr_xa_yz_zt_8123 -  The string expression 

function return_value_x9_a_rzd = local_eval(ws_xa_yz_zt_8123,expr_xa_yz_zt_8123)
    setvar_(ws_xa_yz_zt_8123);
    return_value_x9_a_rzd = eval(expr_xa_yz_zt_8123);

    %%-------------------------------------------------------------------
    %% Load the workspace object into the workspace of the calling
    %% function
function ret = setvar_(ws)
    for i = 1:length(ws)
        assignin('caller',ws(i).Name,ws(i).Value)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  
    %%  CALLBACKS
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_action_button_callback(src,evt,obj,action)
   import('com.mathworks.toolbox.ecoder.utils.*');
   import('javax.swing.*');

   switch action
   case 'ok'
      i_apply_gui(obj);
      rw = RunnableWrapper(obj.dialog.java,'dispose',{});
      SwingUtilities.invokeLater(rw);
    case 'apply'
      i_apply_gui(obj);
    case 'cancel'
      rw = RunnableWrapper(obj.dialog.java,'dispose',{});
      SwingUtilities.invokeLater(rw);
   end;

	%% I_GET_MASK_PARENT get the handle of a parent block that has a mask
	%% 
	%% Searches up the model hierarchy to find a parent
	%% block that is masked

function parent = i_get_masked_parent(block)
    block = get_param(block,'parent');
	while(~(isempty(block) || hasmask(block)==2))
		block = get_param(block, 'parent');
	end
	if ~isempty(block)
		parent = block;
	else
		parent = [];
	end


function i_apply_gui(obj)
   data = get_param(obj.block,'userdata'); 
   data.unique  = awtinvoke(obj.UniqueJComboBox, 'getSelectedIndex()') + 1;
   data.key = char(awtinvoke(obj.KeyTextField, 'getText()'));
   data.location = char(awtinvoke(obj.LocationJComboBox, 'getSelectedItem()'));
   data.vars = char(awtinvoke(obj.VariablesJTextField, 'getText()'));
   data.top = char(awtinvoke(obj.topJTextArea, 'getText()'));
   data.middle = char(awtinvoke(obj.middleJTextArea, 'getText()'));
   data.bottom = char(awtinvoke(obj.bottomJTextArea, 'getText()'));
   set_param(obj.block,'userdata',data);

%   $Revision: 1.1.6.9 $  $Date: 2008/05/01 20:22:56 $
