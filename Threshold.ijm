function filter(input_path, output_folder){
	open(input_path);
	wellID = getTitle();
	selectWindow(wellID);
	Image.removeScale;
	setAutoThreshold("Li dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	saveAs("tiff", output_folder + wellID);
	run("Close");
}

setOption("JFileChooser", true);
input_directory = getDirectory("Choose Input Directory:");
wells = getFileList(input_directory);
well_num = wells.length;
output_directory = getDirectory("Choose Output Folder:");
setBatchMode("show");

for (i = 0; i<well_num; i++){
	well_directory = input_directory + wells[i];
	filter(well_directory, output_directory);
}