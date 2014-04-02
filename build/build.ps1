properties {
	#PARAMS
	$build_level = "Debug"
	$build_number = "build_number_not_set"
	$commit_hash = "hash_not_set"
	
	#PATHS
	$build_dir = Split-Path $psake.build_script_file
	$solution_dir = Split-Path $build_dir
	$build_output = "$build_dir\artifacts"
	$srcDir = "$solution_dir\src"
	$nuget_dir = "$build_dir\..packages\"
	$package_dir = "$build_dir\..packages\"
	$artifacts_dir = "$build_dir\..\artifacts"
	$msbuildpath = "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe"
	
	#SLN INFO
	$solution_file = "$srcDir\WebApplication1.sln"
	
	$client_apps = @()
	$web_apps = @("WebApplication1")
	$assemblies = @()
	$tests = @()
}

task default -depends Web-Publish

task Package-Restore {
	Create-Directory (join-path -path $build_dir "..\packages")
	$package_directory = resolve-path (join-path -path $build_dir "..\packages")
	Create-Directory ($package_directory)
	$nugetpath = (join-path -path $package_directory "nuget.exe")
	if ((Test-Path -path $nugetpath) -eq $False){
		Write-Host "Downloading nuget.exe"
		(new-object System.Net.WebClient).Downloadfile("https://nuget.org/nuget.exe", $nugetpath)
	}
	& $nugetpath restore $solution_file -NOCACHE
}

task Web-Publish -depends Clean, Package-Restore { 
	$script:build_level = $build_level
	
	$outputDir = "my_published_website"
	
	Delete-Directory "$artifacts_dir\$outputDir"
	
	$msbuild_args = "$solution_file /m /nr:false /p:VisualStudioVersion=12.0 /p:Configuration=""$build_level"" /p:WebPublishMethod=FileSystem /p:publishUrl=""$artifacts_dir\$outputDir"" /p:DeployOnBuild=true /p:DeployTarget=WebPublish"
	Write-Host "Executing command: $msbuildpath $msbuild_args" -foregroundcolor DarkYellow -backgroundcolor DarkMagenta
	$process = Start-Process $msbuildpath -argumentlist $msbuild_args -Wait -PassThru -NoNewWindow
	
	Get-ChildItem "$artifacts_dir\$outputDir"
}

task Clean { 
	foreach($assembly in $assemblies + $client_apps + $web_apps + $tests){
		$bin = "$srcDir\$assembly\bin\"
		$obj = "$srcDir\$assembly\obj\"
		Write-Host "Removing $bin"
		Delete-Directory($bin)
		Write-Host "Removing $obj"
		Delete-Directory($obj)
	}
}

function Delete-Directory($directoryName){
	if ((Test-Path -path $directoryName) -eq $True){
		Remove-Item -Force -Recurse $directoryName -ErrorAction SilentlyContinue
	}
}
 
function Create-Directory($directoryName){
	if ((Test-Path -path $directoryName) -eq $False){
		New-Item $directoryName -ItemType Directory | Out-Null
	}
}