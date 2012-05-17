function slpmioporthelp(pmioport)
%SLPMIOPORTHELP - Execute the domain-specific help function for
%  the passed PMIO port block. If SLPMIOPORT is unable to determine
%  the block's domain because the block is unconnected, SLPMIOPORTHELP
%  creates and displays a generic help page on the fly that instructs the
%  user to connect the block and then request help. SLPMIOPORTHELP
%  throws an error if either of the following conditions occur:
%
%     * The passed block is not a PMIO port block.
%
%     * The associated physical domain has no portHelpFcn.
%  
  
%  $Revision: 1.1.6.7 $ $Date: 2010/05/20 03:18:23 $
%  Copyright 2004-2010 The MathWorks, Inc.
  
  error(nargchk(1, 1, nargin, 'struct'));
  
  pmioport = get_param(pmioport, 'Handle');
  
  if strcmp(get_param(pmioport, 'BlockType'), 'PMIOPort')
    try
      success = feature('PhysicalModelingPMIOPortHelp', pmioport);
    catch e
      rethrow(e);
    end
    
    if (success == false)
      display_generic_help;
    end
    
  else
    error('Simulink:slpmioport:invalidblocktype', 'Not a connection port.');
  end

end

function display_generic_help()
  
  CR = sprintf('\n');  % Set carriage-return character.
  SL_DOC_ROOT =  ['file:///' docroot '/toolbox/simulink'];
  SL_BLOCKS_PAGE = [SL_DOC_ROOT '/slref/blocks_alphabetical_list.html'];

  out_str = [...
        '<html>',CR,...
        '<head>',CR,...
        '<title>Connection Port</title>',CR,...
        '</head>',CR,...
        '<body bgcolor=#FFFFFF>',CR,...
        '<table border=0 width="100%" cellpadding=0 cellspacing=0><tr>', ...
        '<td valign=baseline bgcolor="#e7ebf7"><b>Simulink Reference</b></td>', ...
        '</tr></table>', ...
        '<p>',CR,...
        'The Connection Port block provides a connection port for subsystems in certain products dependent on Simulink.',CR,...
        'You have obtained this general help page for the Connection Port block because',CR,...
        'this copy of the block is currently not connected to another block from one of those products.',CR,...
        '</p>',CR,...
        '<p>',CR,...
        'To get a product-specific reference page for the Connection Port block:',CR,...
        '<p>',CR,...
        '<ol>',CR,...
        '<li>Copy the Connection Port block into a subsystem.<br>A distinctive nonsignal port appears on the boundary of the subsystem.</li>',CR,...
        '<li>Identify and copy another block from one of the products that contains Connection Port in its library.<br>',CR,...
        'This new block must appear one level up in the model hierarchy (in the parent level of the subsystem) and',CR,...
        'must have one or more distinctive, nonsignal ports.</li>',CR,...
        '<li>Connect the new Connection Port in the subsystem, through the distinctive subsystem port,',CR,...
        'to a distinctive nonsignal port on the other block in the subsystem''s parent level.</li>',CR,...
        '<li>Select <b>Help</b> in the Connection Port block dialog box or block context menu.</li>',CR,...
        '</ol>',CR,...
        '</body>', ...
        '</html>', ...
        ];

  % Output to a temporary file.
  % Start by finding the location of the correct file name for this session.
  fig = findobj(allchild(0),'Type','figure','Tag','Simulink Help Temp File Name');
  if isempty(fig)
    % Get a temporary name and store it in the userdata of an invisible,
    % hidden figure.
    % The DeleteFcn deletes the last temporary file if the figure is
    % closed.  This will happen upon a 'close all force' or when MATLAB
    % is exited.
    fname = [tempname '.html'];

    % for unix use the user's home dir, temp is not available
    % across different machines, so if browser is on a different
    % machine than MATLAB, this will still work.  bmb
    if isunix
      % put the html tempfile in the users home dir
      [dirx,filey,extx]=fileparts(fname);
      fname = [getenv('HOME'),'/',filey,extx];
    end

    figure('Visible','off', ...
           'HandleVisibility','off', ...
           'IntegerHandle','off', ...
           'Tag','Simulink Help Temp File Name', ...
           'UserData',fname, ...
           'DeleteFcn',['delete(''' fname ''');']);

  else
    % Just pull the temporary file name out of the figure userdata.
    fname = get(fig,'UserData');
  end

  % Open the file and write to it.
  fid = fopen(fname,'wt');
  if fid==-1,
    error( 'Simulink:slpmioport:UnableToOpenTempFile', ...
           'Error opening temporary file in slhelp.m. Temporary storage not available.' );
  end
  fprintf(fid,'%s',out_str);
  fclose(fid);

  % Open the web page.  Throw an error if the browser is not found.
  if (strncmp(computer,'MAC',3))
    fname = strrep(fname,filesep,'/');
  end
  helpview(fname)
  
end
