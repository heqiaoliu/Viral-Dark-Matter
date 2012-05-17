<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nl "&#10;">
  <!ENTITY nbsp "&#160;">
  ]>

<!-- 
   Copyright 2006-2010 The MathWorks, Inc.
   $Revision: 1.1.6.15 $
-->

<!-- Use this stylesheet when there are multiple MDLDepSet instances.
     The "root" model is assumed to be the first in the array. -->

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dependencies="http://www.mathworks.com/manifest">
    <xsl:output method="html" encoding="utf-8"
        media-type="text/html" indent="yes" />

    <xsl:key name="distinct-toolboxname" match="Toolboxes/ToolboxDetails" use="."/>

    <xsl:param name="language">en</xsl:param>
    <xsl:param name="strings"
        select="document(concat($language,'/','strings.xml'))/strings"/>

    <!--xsl:strip-space elements="*"/-->
    <xsl:function name="dependencies:analysis_option_value">
        <xsl:param name="option_name"/>
        <xsl:choose>
            <xsl:when test="$option_name='true'">
                &nbsp;<b><xsl:value-of select="$strings/true"/></b>
            </xsl:when>
            <xsl:when test="$option_name='false'">
                &nbsp;<b><xsl:value-of select="$strings/false"/></b>
            </xsl:when>
            <xsl:otherwise>
                <!-- empty, since the only allowed values are true and false -->
                &nbsp;<i><xsl:value-of select="$strings/not_specified"/></i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="dependencies:exportable_value">
        <xsl:param name="option_name"/>
        <xsl:choose>
            <xsl:when test="$option_name='true'">
                <xsl:value-of select="$strings/true"/>
            </xsl:when>
            <xsl:when test="$option_name='false'">
                <xsl:value-of select="$strings/false"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- empty, since the only allowed values are true and false -->
                <i><xsl:value-of select="$strings/not_specified"/></i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="DependencyReport">
        <html><head>
                <!--link rel="stylesheet" type="text/css" href="mcss.css"/-->
                <title><xsl:value-of select="$strings/title"/>
                    <xsl:value-of select="MDLDepSet[1]/MDLName"/>
                </title>
            </head>
            <body bgcolor="#ffffff">
                <h1><xsl:value-of select="$strings/title"/>
                    <xsl:value-of select="MDLDepSet[1]/MDLName"/>
                </h1>
                <p><xsl:value-of select="$strings/analysis_performed"/>
                    <xsl:value-of select="MDLDepSet[1]/AnalysisDate"/>
                </p>

                <h2><xsl:value-of select="$strings/hierarchy"/></h2>
                <ul>
                    <xsl:apply-templates select="MDLDepSet[1]" mode="tree">
                        <xsl:with-param name="already_processed" select="','"/>
                    </xsl:apply-templates>
                </ul>

                <!-- Files in the manifest -->
                <h2><xsl:value-of select="$strings/files_used"/></h2>
                <p><b><xsl:value-of select="$strings/root_directory"/></b>:
                    <xsl:choose>
                        <xsl:when test="FileList/@ProjectRoot=''">
                            <em><xsl:value-of select="$strings/no_project_root"/></em>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="FileList/@ProjectRoot"/>
                        </xsl:otherwise>
                    </xsl:choose></p>

                <xsl:choose>
                    <xsl:when test="count(FileList/FileState)=0">
                        <!-- This is the only likely reason for an empty file list -->
                        <xsl:value-of select="$strings/all_in_toolboxes"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <table border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/filename"/></th>
                                <th><xsl:value-of select="$strings/filesize"/></th>
                                <th><xsl:value-of select="$strings/lastmodified"/></th>
                                <th><xsl:value-of select="$strings/exportable"/></th>
                            </tr>
                            <!-- Manifests in R2008b and earlier do not have FileList sections.
                                 But since we always resave the manifest before creating the
                                 report, we can assume here that all manifests have this section. --> 
                            <xsl:for-each select="./FileList/FileState">
                                <tr>
                                    <td><xsl:call-template name="absname_display"/>&nbsp;</td>
                                    <td><xsl:value-of select="Size"/><xsl:value-of select="$strings/bytes"/></td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="LastModifiedDate!='&lt;file not found&gt;'">
                                                <xsl:value-of select="LastModifiedDate"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$strings/file_not_found"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <td><xsl:value-of select="dependencies:exportable_value(Exportable)"/></td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:otherwise>
                </xsl:choose>

                <h2><xsl:value-of select="$strings/toolboxes"/></h2>
                <ul>
                    <xsl:choose>
                        <xsl:when test="count(MDLDepSet/Toolboxes/ToolboxDetails)=0">
                            <xsl:value-of select="$strings/no_toolboxes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Show each toolbox once only.
                                generate-id() returns the ID of this node.
                                key('distinct-toolboxname',.) returns all nodes with the same content as this one,
                                so key(...)[1] returns the first node in that set
                                generate-id(...) returns the ID of that node, so the '=' operation is true only
                                  if the current node is the first in the set of nodes which have the content as it
                                so the for-each loop rejects nodes which have the same content as an earlier node,
                                 i.e. it selects a unique set of nodes
                            -->
                            <xsl:for-each select="./MDLDepSet/Toolboxes/ToolboxDetails[generate-id()=generate-id(key('distinct-toolboxname',.)[1])]">
                                <li><xsl:value-of select="Name"/> (<xsl:value-of select="Version"/>)</li>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>

                <!-- References -->
                <h2><xsl:value-of select="$strings/references_in_model"/></h2>
                <xsl:choose>
                    <xsl:when test="MDLDepSet[1]/AnalysisOptions/StoreReferences='true'">                        
                        <p><xsl:value-of select="$strings/references_table_description"/></p>
                        
                        <xsl:choose>
                            <xsl:when test="count(./MDLDepSet/AllReferences/FileReference)>0">
                                <table border="1">
                                    <tr>
                                        <th><xsl:value-of select="$strings/reference_type"/></th>
                                        <th><xsl:value-of select="$strings/reference_location"/></th>
                                        <th><xsl:value-of select="$strings/filename"/></th>
                                        <th><xsl:value-of select="$strings/toolbox"/></th>
                                    </tr>
                                    <xsl:apply-templates select="./MDLDepSet/AllReferences/FileReference"/>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <h3><xsl:value-of select="$strings/references"/></h3>
                                <p><xsl:value-of select="$strings/no_references"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>  
                    <xsl:otherwise>
                        <p><xsl:value-of select="$strings/references_not_stored"/></p>
                    </xsl:otherwise>    
                </xsl:choose>

                <!-- Folders -->
                <h2><xsl:value-of select="$strings/directories"/></h2>
                <xsl:choose>
                    <xsl:when test="count(./MDLDepSet/AllIncludeDirs/DirReference)>0">
                        <table border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/reference_type"/></th>
                                <th><xsl:value-of select="$strings/reference_location"/></th>
                                <th><xsl:value-of select="$strings/directory_name"/></th>
                            </tr>
                            <xsl:apply-templates select="./MDLDepSet/AllIncludeDirs/DirReference"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <h3><xsl:value-of select="$strings/references"/></h3>
                        <p><xsl:value-of select="$strings/no_directories"/></p>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Orphaned Data -->
                <h2><xsl:value-of select="$strings/orphaneddata"/></h2>
                <p><xsl:value-of select="$strings/orphaneddata_description"/></p>
                <xsl:choose>
                    <xsl:when test="count(./OrphanedData/Orphan)>0">
                        <table class="sortable" border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/variable_name"/></th>
                                <th><xsl:value-of select="$strings/variable_type"/></th>
                                <th><xsl:value-of select="$strings/reference_location"/></th>
                            </tr>
                            <xsl:apply-templates select="./OrphanedData/Orphan"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="MDLDepSet[1]/AnalysisOptions/FindWorkspaceVars[.!='true']">
                                <p><xsl:value-of select="$strings/orphans_not_stored"/></p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p><xsl:value-of select="$strings/no_orphans"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Warnings -->
                <h2><xsl:value-of select="$strings/warnings"/></h2>
                <xsl:choose>
                    <xsl:when test="count(./Warnings/Warning)>0">
                        <table border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/reference_type"/></th>
                                <th><xsl:value-of select="$strings/reference_location"/></th>
                                <th><xsl:value-of select="$strings/warning_message"/></th>
                            </tr>
                            <xsl:apply-templates select="./Warnings/Warning"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="MDLDepSet[1]/AnalysisOptions/StoreWarnings[.!='true']">
                                <p><xsl:value-of select="$strings/warnings_not_stored"/></p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p><xsl:value-of select="$strings/no_warnings"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Analysis options -->
                <h3><xsl:value-of select="$strings/settings"/></h3>
                <xsl:apply-templates select="MDLDepSet[1]/AnalysisOptions"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="MDLDepSet" mode="tree">
        <xsl:param name="already_processed"/>
        <xsl:choose>
            <!-- If this MDL has already been processed, skip it now to avoid
                 infinite recursion.  Search for the name with leading and trailing
                 commas just incase this MDL has a name which is a subset of
                 another MDL's name -->
            <xsl:when test="contains($already_processed,concat(',',MDLName,','))">
                <xsl:value-of select="MDLName"/> <xsl:value-of select="$strings/recurses"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="now_processed"><xsl:value-of select="$already_processed"/><xsl:value-of select="MDLName"/>,</xsl:variable>
                <li>
                    <xsl:value-of select="MDLName"/>
                    <xsl:if test="count(LinkedLibraries/MDLFile)>0 or count(ReferencedModels/MDLFile)>0">
                        <ul>
                            <xsl:for-each select="ReferencedModels/MDLFile">
                                <xsl:apply-templates select="." mode="tree">
                                    <xsl:with-param name="already_processed" select="$now_processed"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                            <xsl:for-each select="LinkedLibraries/MDLFile">
                                <xsl:apply-templates select="." mode="tree">
                                    <xsl:with-param name="already_processed" select="$now_processed"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="MDLFile" mode="tree">
        <xsl:param name="already_processed"/>
        <!-- temporary variable for the name of this file -->
        <xsl:variable name="tempname">
            <xsl:value-of select="MDLName"/>
        </xsl:variable>
        <!-- find the matching MDLDepSet node -->
        <xsl:for-each select="/DependencyReport/MDLDepSet">
            <xsl:if test="MDLName=$tempname">
                <!-- got it.  Call the template on it -->
                <xsl:apply-templates select="." mode="tree">
                    <xsl:with-param name="already_processed"><xsl:value-of select="$already_processed"/></xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="AllFiles">
    </xsl:template>

    <xsl:template match="ToolboxDetails" mode="unique">
        <xsl:param name="already_processed"/>
        <xsl:choose>
            <xsl:when test="contains($already_processed,Name)">
                <!-- nothing -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="now_processed"><xsl:value-of select="$already_processed"/><xsl:value-of select="Name"/>,</xsl:variable>
                <li>
                    <xsl:value-of select="Name"/>
                    (<xsl:value-of select="Version"/>)
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="AllReferences">
        <xsl:choose>
            <xsl:when test="count(./FileReference)>0">
                <h3><xsl:value-of select="$strings/references"/></h3>
                <table border="1">
                    <tr>
                            <th><xsl:value-of select="$strings/reference_type"/></th>
                            <th><xsl:value-of select="$strings/reference_location"/></th>
                            <th><xsl:value-of select="$strings/filename"/></th>
                            <th><xsl:value-of select="$strings/toolbox"/></th>
                    </tr>
                    <xsl:apply-templates select="FileReference"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <h3><xsl:value-of select="$strings/references"/></h3>
                <p><xsl:value-of select="$strings/no_files"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="FileReference">
        <tr>
            <td><xsl:value-of select="ReferenceType"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="ReferenceLocation[.!='']">
                        <xsl:value-of select="ReferenceLocation"/>&nbsp;
                    </xsl:when>
                    <xsl:otherwise>&nbsp;</xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:call-template name="absname_display"/>&nbsp;
                <xsl:choose>
                    <xsl:when test="Resolved!='true'">
                        <xsl:value-of select="$strings/not_found"/>
                    </xsl:when>
                </xsl:choose>
            </td>
            <td><xsl:apply-templates select="ToolboxDetails" mode="fileref"/></td>
        </tr>
    </xsl:template>

    <!-- ToolboxDetails inside a FileReference, shown in the final column
         of the "References in this model" table. -->
    <xsl:template match="ToolboxDetails" mode="fileref">
        <xsl:choose>
            <xsl:when test="count(./Name)=0">
                <xsl:value-of select="$strings/not_in_toolbox"/>
            </xsl:when>
            <xsl:otherwise>
            <xsl:value-of select="Name"/>
            (<xsl:value-of select="Version"/>)
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="DirReference">
        <tr>
            <td><xsl:value-of select="ReferenceType"/></td>
            <td><xsl:value-of select="ReferenceLocation"/></td>
            <!-- This is an equivalent of the "absname_display" template, but for
                 DirName elements. -->
             <td><xsl:choose>
                <xsl:when test="DirName/@RelativeTo='matlabroot'">$matlabroot/<xsl:value-of select="DirName"/></xsl:when>
                <xsl:when test="DirName/@RelativeTo='projectroot'">$projectroot/<xsl:value-of select="DirName"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="DirName"/></xsl:otherwise>
            </xsl:choose></td>
       </tr>
    </xsl:template>

   <xsl:template match="Warning">
        <tr>
            <td><xsl:value-of select="@ReferenceType"/></td>
            <td><xsl:value-of select="ReferenceLocation"/>
                <xsl:choose>
                    <xsl:when test="@ReferenceType[.='MATLABFile'] and ReferenceLocation/@Line[.!='']">
                        (<xsl:value-of select="$strings/line_number"/>&nbsp;
                        <xsl:value-of select="ReferenceLocation/@Line"/>)
                    </xsl:when> 
                </xsl:choose>
            </td>
            <td><xsl:value-of select="Message"/></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="Orphan">
        <tr>
            <td><xsl:value-of select="@VariableName"/></td>
            <td><xsl:value-of select="VariableType"/></td>
            <td><xsl:value-of select="ReferenceLocation"/></td>
        </tr>
    </xsl:template>
    
    <!-- For any element that contains a FileName element, returns the
         absolute file name in a form that can be evaluated by MATLAB -->
    <xsl:template name="absname_matlab">
        <xsl:choose>
            <xsl:when test="FileName/@RelativeTo='matlabroot'">fullfile(matlabroot,'<xsl:value-of select="FileName"/>')</xsl:when>
            <xsl:when test="FileName/@RelativeTo='projectroot'">'<xsl:value-of select="replace(/DependencyReport/FileList/@ProjectRoot, '''', '''''')"/>/<xsl:value-of select="FileName"/>'</xsl:when>
            <xsl:otherwise>'<xsl:value-of select="FileName"/>'</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- For any element that contains a FileName element, returns the
         file name in a form that can be displayed to the user -->
    <xsl:template name="absname_display">
        <xsl:choose>
            <xsl:when test="FileName/@RelativeTo='matlabroot'">$matlabroot/<xsl:value-of select="FileName"/></xsl:when>
            <xsl:when test="FileName/@RelativeTo='projectroot'">$projectroot/<xsl:value-of select="FileName"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="FileName"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="AnalysisOptions">
        <ul>
            <li>
                <xsl:value-of select="$strings/find_orphans"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindWorkspaceVars)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_mdlrefs"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindModelRefs)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_liblinks"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindLibraryLinks)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/unsaved_changes"/>
                <xsl:sequence select="dependencies:analysis_option_value(AllowUnsavedChanges)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_sfcns"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindSFunctions)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_callbacks"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindCallbackFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_codegen"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindCodeGenFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_datafiles"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindDataFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_stateflow"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeStateflow)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_eml"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeEML)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_reqs"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindRequirementsDocs)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_user"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeUserToolboxFiles)"/>
            </li>            
            <li>
                <xsl:value-of select="$strings/analyze_mfiles"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeMFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/report_dependency_locations"/>:
                <xsl:choose>
                    <xsl:when test="StoreReferences='true'">
                        <xsl:choose>
                            <xsl:when test="StoreMathWorksReferences='true'">
                                &nbsp;<b><xsl:value-of select="$strings/all_files"/></b>
                            </xsl:when>
                            <xsl:otherwise>
                                &nbsp;<b><xsl:value-of select="$strings/user_files"/></b>
                            </xsl:otherwise>    
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        &nbsp;<b><xsl:value-of select="$strings/none"/></b>
                    </xsl:otherwise>   
                </xsl:choose> 
            </li>
            <li>
                <xsl:value-of select="$strings/store_warnings"/>
                <xsl:sequence select="dependencies:analysis_option_value(StoreWarnings)"/>
            </li>
        </ul>
    </xsl:template>

</xsl:stylesheet>

