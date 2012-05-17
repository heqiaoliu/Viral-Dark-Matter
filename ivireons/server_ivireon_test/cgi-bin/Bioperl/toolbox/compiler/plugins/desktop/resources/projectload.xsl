<?xml version="1.0"?>
        
<!-- Converts the legacy mcc-specific project file format to the new standard project file format. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" />
    
    <xsl:template match="project">
    	<deployment-project>
            <configuration>
                <!-- Figure out the target used by this project. The name and location normally appear here also in a 
                     new-format project file, but they are irrelevant for loading so we don't need to generate them. -->
                <xsl:variable name="WrapperType"><xsl:value-of select="MCCProperties/wrapper/type" /></xsl:variable> 
                <xsl:variable name="EmbedCTF"><xsl:value-of select="MCCProperties/create_CTF='false'" /></xsl:variable>
                <xsl:attribute name="target"><xsl:choose>
                    <xsl:when test="$WrapperType = 'main'">target.standalone</xsl:when>
                    <xsl:when test="$WrapperType = 'WinMain'">target.standalone.win</xsl:when>
                    <xsl:when test="$WrapperType = 'lib'">target.library.c</xsl:when>
                    <xsl:when test="$WrapperType = 'cpplib'">target.library.cpp</xsl:when>
                    <xsl:when test="$WrapperType = 'java'">target.java.package</xsl:when>
                    <xsl:when test="$WrapperType = 'excel'">target.ex.addin</xsl:when>
                    <xsl:when test="$WrapperType = 'com'">target.com.component</xsl:when>
                    <xsl:when test="$WrapperType = 'dotnet'">target.net.component</xsl:when>
                    <xsl:when test="$WrapperType = ''">
                        <xsl:if test="$EmbedCTF = 'false'">target.ctfx</xsl:if>
                    </xsl:when>
                </xsl:choose></xsl:attribute>
                
                <param.appname>
                  <xsl:choose>
                    <xsl:when test="MCCProperties/output != ''"><xsl:value-of select="MCCProperties/output" /></xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="MCCProperties/wrapper/component_name" />
                    </xsl:otherwise>
                  </xsl:choose>
                </param.appname>
                <param.intermediate><xsl:value-of select="MCCProperties/intermediate_dir" /></param.intermediate>
                <param.output><xsl:value-of select="MCCProperties/output_dir" /></param.output>
                <param.embed.ctf><xsl:value-of select="MCCProperties/create_CTF = 'false'" /></param.embed.ctf>
                <param.warnings>
                    <xsl:for-each select="MCCProperties/warning">
                        <warning.fullpath><xsl:for-each select="warn[@name ='specified_file_mismatch']"><xsl:call-template name="warning" /></xsl:for-each></warning.fullpath>
                        <warning.duplicate><xsl:for-each select="warn[@name = 'repeated_file']"><xsl:call-template name="warning" /></xsl:for-each></warning.duplicate>
                        <warning.option.ignored><xsl:for-each select="warn[@name = 'switch_ignored']"><xsl:call-template name="warning" /></xsl:for-each></warning.option.ignored>
                        <warning.libname><xsl:for-each select="warn[@name = 'missing_lib_sentinel']"><xsl:call-template name="warning" /></xsl:for-each></warning.libname>
                        <warning.demo><xsl:for-each select="warn[@name = 'demo_license']"><xsl:call-template name="warning" /></xsl:for-each></warning.demo>
                    </xsl:for-each>
                </param.warnings>
                
                <!-- The user-specified app version number is only there for excel and com targets -->
                <xsl:if test="$WrapperType = 'excel' or $WrapperType = 'com'">
                    <param.version><xsl:value-of select="MCCProperties/wrapper/additionalProperty[position() = 1]" /></param.version>    
                </xsl:if>
                
                <!-- Include directories -->
                <param.include.dirs>
                    <xsl:for-each select="MCCProperties/mbuild_flag[starts-with(normalize-space(.), '-I')]">
                        <file><xsl:value-of select="substring(normalize-space(.), 3)" /></file>
                    </xsl:for-each>
                </param.include.dirs>
                
                <!-- Library directories -->
                <param.lib.dirs>
                    <xsl:for-each select="MCCProperties/mbuild_flag[starts-with(normalize-space(.), '-L')]">
                        <file><xsl:value-of select="substring(normalize-space(.), 3)" /></file>
                    </xsl:for-each>                    
                </param.lib.dirs>
                
                <!-- Specific library files -->
                <param.lib.files>
                    <xsl:for-each select="MCCProperties/mbuild_flag[starts-with(normalize-space(.), '-l')]">
                        <file><xsl:value-of select="substring(normalize-space(.), 3)" /></file>
                    </xsl:for-each>                                
                </param.lib.files>
                
                <!-- Preprocessor defines -->
                <param.defines>
                    <xsl:for-each select="MCCProperties/mbuild_flag[starts-with(normalize-space(.), '-D')]">
                        <item><xsl:value-of select="substring(normalize-space(.), 3)" /></item>
                    </xsl:for-each>                
                </param.defines>
                
                <!-- Preprocessor undefines -->
                <param.undefines>
                    <xsl:for-each select="MCCProperties/mbuild_flag[starts-with(normalize-space(.), '-U')]">
                        <item><xsl:value-of select="substring(normalize-space(.), 3)" /></item>
                    </xsl:for-each>                             
                </param.undefines>
                
                <param.debug><xsl:value-of select="MCCProperties/debug = 'true'" /></param.debug>
                
                <param.tbx_on_path>
                	<xsl:choose>
                		<xsl:when test="MCCProperties/toolboxes_on_path/@shortcut = 'all'">
                			<item>all</item>
                		</xsl:when>
                		
                		<xsl:when test="MCCProperties/toolboxes_on_path/@shortcut = 'none'">
                			<item>none</item>
                		</xsl:when>
                		
                		<xsl:otherwise>
                			<xsl:for-each select="MCCProperties/toolboxes_on_path/toolbox">
                				<item><xsl:value-of select="." /></item>
                			</xsl:for-each>
                		</xsl:otherwise>
                	</xsl:choose>
                </param.tbx_on_path>
                
                <param.share.mcr><xsl:value-of select="MCCProperties/MCR_runtime_options/share_mcr = 'true'" /></param.share.mcr>
                <param.disable.jvm><xsl:value-of select="count(MCCProperties/MCR_runtime_options/runtime_option[. = '-nojvm']) > 0" /></param.disable.jvm>
                <param.disable.display><xsl:value-of select="count(MCCProperties/MCR_runtime_options/runtime_option[. = '-nodisplay']) > 0" /></param.disable.display>
                <xsl:choose>
                    <xsl:when test="count(MCCProperties/MCR_runtime_options/runtime_option[starts-with(normalize-space(.), '-logfile')]) > 0">
                        <param.create.log>true</param.create.log>

                        <!-- In case there are multiple -logfile entries, the first one wins -->		
                        <xsl:variable name="LogFileEntry"><xsl:value-of select="MCCProperties/MCR_runtime_options/runtime_option[starts-with(normalize-space(.), '-logfile')][position() = 1]" /></xsl:variable>
                        <param.log.file><xsl:value-of select="normalize-space(substring-after($LogFileEntry, '-logfile,'))" /></param.log.file>
                    </xsl:when>
                    <xsl:otherwise>
                        <param.create.log>false</param.create.log>
                        <param.log.file/>
                    </xsl:otherwise>
                </xsl:choose>                

                <param.user.defined.mcr.options>
                    <xsl:for-each select="MCCProperties/MCR_runtime_options/runtime_option">
                        <xsl:if test=".!='-nojvm' and .!='-nodisplay' and not(starts-with(normalize-space(.), '-logfile'))">
                            <item><xsl:value-of select="." /></item>
                        </xsl:if>
                    </xsl:for-each>                             
                </param.user.defined.mcr.options>
                
                <!-- .NET Parameters -->
                <xsl:choose>
                	<xsl:when test="count(MCCProperties/wrapper/additionalProperty[. = '2.0']) != 0">
                		<param.net.framework>option.net.framework.2.0</param.net.framework>
                	</xsl:when>
                	<xsl:when test="count(MCCProperties/wrapper/additionalProperty[. = '3.0']) != 0">
                		<param.net.framework>option.net.framework.3.0</param.net.framework>
                	</xsl:when>
                	<xsl:when test="count(MCCProperties/wrapper/additionalProperty[. = '3.5']) != 0">
                		<param.net.framework>option.net.framework.3.5</param.net.framework>
                	</xsl:when>
			<xsl:otherwise>
                		<param.net.framework>option.net.framework.default</param.net.framework>
                	</xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                	<xsl:when test="count(MCCProperties/wrapper/additionalProperty[. = 'private']) != 0">
                		<param.assembly.type>option.assembly.type.private</param.assembly.type>
                	</xsl:when>
                	<xsl:otherwise>
                		<param.assembly.type>option.assembly.type.shared</param.assembly.type>
                		<param.encryption.key.file><xsl:value-of select="MCCProperties/wrapper/additionalProperty[. != '2.0' and . != '0.0' and . != 'remote']" /></param.encryption.key.file>
                	</xsl:otherwise>
                </xsl:choose>				    
		<xsl:choose>
			<xsl:when test="count(MCCProperties/wrapper/additionalProperty[. = 'remote']) != 0">
				<param.net.enable.remoting>true</param.net.enable.remoting>
			</xsl:when>
			<xsl:otherwise>
				<param.net.enable.remoting>false</param.net.enable.remoting>
			</xsl:otherwise>
		</xsl:choose>
		
                
                <!-- Read the classes file set, if applicable -->
                <xsl:variable name="ClassCategories" select="file_info/category[@name != 'Main function' and @name != 'Exported functions' and @name != 'Other files' and @name != 'C/C++ files']" />
                <xsl:if test="count($ClassCategories) > 0">
		    <fileset.classes>
			<entity.package name="">                        
			    <xsl:for-each select="$ClassCategories">
				<entity.class>
				    <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>
				    <xsl:apply-templates select="file" />
				</entity.class>
			    </xsl:for-each>
			</entity.package>
		    </fileset.classes>
                </xsl:if> 
                
                <!-- Read the Main or Exports file set (only one of the two is actually present in a given project) -->
                <xsl:for-each select="file_info/category">
                    <xsl:choose>
                        <!-- Main file (for standalone) -->
                        <xsl:when test="@name = 'Main function'">
                            <fileset.main>
                                <xsl:apply-templates select="file" />
                            </fileset.main>
                        </xsl:when>
                        
                        <!-- Exports (for libraries) -->
                        <xsl:when test="@name = 'Exported functions'">
                            <fileset.exports>
                                <xsl:apply-templates select="file" />
                            </fileset.exports>
                        </xsl:when> 
                    </xsl:choose>
                </xsl:for-each> 
                
                <!-- The resources file set is a combination of Other files and C/C++ files in the old format. They 
                     cannot be dealt with in the above loop because their contents need to be under one header. -->
                <xsl:variable name="ResourcesCategories" select="file_info/category[@name = 'C/C++ files' or @name = 'Other files']" />
                <xsl:if test="count($ResourcesCategories) > 0">
                    <fileset.resources>
                        <xsl:for-each select="$ResourcesCategories">
                            <xsl:apply-templates select="file" />
                        </xsl:for-each>
                    </fileset.resources>
                </xsl:if>
                
                <!-- Read the packaging file set -->
                <fileset.package>
                  <xsl:apply-templates select="packaging/additional_files" />
		  <xsl:if test="packaging/mcr/@include='true'">
		    <file special-file="file.mcr">
		      <xsl:attribute name="reference-mode"><xsl:value-of select="packaging/mcr/@reference-mode" /></xsl:attribute>
		    </file>
		  </xsl:if>
                </fileset.package> 
                
                <!-- The other sections, such as path and platform, are irrelevant to loading into Deploy Tool and don't 
                     need to be generated. The unset section should be here but it's unavoidably lost data and there
                     isn't much of a user impact (basically a future version of Deploy Tool that has different defaults
                     will think the user explicitly modified stuff when really they left the defaults. --> 
            </configuration>            
        </deployment-project>
    </xsl:template>
    
    <!-- This template converts a warning value from the old to the new format -->
    
    <xsl:template name="warning">
        <xsl:choose>
            <xsl:when test=". = 'enable'">on</xsl:when>
            <xsl:when test=". = 'disable'">off</xsl:when>
            <xsl:otherwise>error</xsl:otherwise>
        </xsl:choose>        
    </xsl:template>    
    
    <!-- This template is to copy file elements from the old to the new format. This is basically an identity copy;
         we don't need to do translation on the aliases because ProjectManager understands the old aliases. -->
    
    <xsl:template match="file">
        <file><xsl:value-of select="." /></file>
    </xsl:template>    
    
</xsl:stylesheet>        
