# msbuild-file-publish #

Simple repro to show MSBuild team my current issue with web publishing

----------

The desired purpose is

- the make a build script on a machine with out visual studio installed
- make no changes to the project file regarding build tasks etc
- require no additional msbuild files
- only used msbuild command line & parameters

----------
The solution is a simple File > New > MVC 5 app and the repo has come simple package relocation happening that doesn't interfere with the repro as hand.  Other than relocation the packages folder no hand crafted modifications have been make the the project file.  This is the desired result to that a stock project file can be used on a build server agent.

The build script is using PSake ([https://github.com/psake/psake](https://github.com/psake/psake))

----------
Get the bits

1. **git clone git@github.com:motowilliams/msbuild-file-publish.git**
2. Open a powershell promt (as admin && Set-ExecutionPolicy Unrestricted) to **path\to\msbuild-file-publish**
3. **.\build\run.ps1**
4. Observe published output in **path\to\msbuild-file-publish\artifacts** directory

This will work just fine on a machine with Visual Studio 2013 installed

This will not work on a machine with
 
- BuildTools_Full.exe
- NDP451-KB2859818-Web.exe
- NDP451-KB2861696-x86-x64-DevPack.exe

nor does it work with the following also installed

 - WebDeploy_amd64_en-US.msi


Adding an following build target doesn't change the results 

    <Import Project="$(MSBuildThisFileDirectory)Web\Microsoft.Web.Publishing.targets"
	Condition="Exists('$(MSBuildThisFileDirectory)Web\Microsoft.Web.Publishing.targets')" />

