function square(input_path, output_folder, coefficient){
	open(input_path);
	wellID = getTitle();
	selectWindow(wellID);
	Image.removeScale;
	getDimensions(width, height, channels, slices, frames);
	
	x = coefficient*width;
	makeRectangle(x, 0, height, height);
	roiManager("Add");
	roiManager("Select", 0);
	run("Duplicate...", "title=crop");
	selectWindow(wellID);
	run("Close");
	roiManager("Deselect");
	roiManager("Delete");
	selectWindow("ROI Manager");
	run("Close");
	selectWindow("crop");
	saveAs("tiff", output_folder + wellID);
	run("Close");
}

setOption("JFileChooser", true);
input_directory = getDirectory("Choose Input Directory:");
wells = getFileList(input_directory);
well_num = wells.length;
output_directory = getDirectory("Choose Output Folder:");
setBatchMode("show");

a = newArray(0.19, 0.34, 0.37, 0.24, 0.2, 0.21, 0.24, 0.26, 0.09, 0.15, 0.15, 0.27, 0.18, 0.11, 0.01, 0.04, 0.15, 0.07, 0.16, 0.15, 0.16, 0.22, 0.12, 0.08);
	
for (i = 0; i<well_num; i++){
	well_directory = input_directory + wells[i];
	square(well_directory, output_directory, a[i]);
}
