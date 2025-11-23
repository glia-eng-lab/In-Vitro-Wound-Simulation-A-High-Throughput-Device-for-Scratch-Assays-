function processSkeleton(input_image_path, longest_shortest, image_output, MATLAB_path_info){
	open(input_image_path);
	wellID = getTitle();
	selectWindow(wellID);
	Image.removeScale;
	run("Skeletonize");
	run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] calculate show");
	close(wellID);
	selectWindow("Longest shortest paths");
	saveAs("tiff", image_output + substring(wellID, 0, lengthOf(wellID) - 4) + "_longest_path.tif");
	close(substring(wellID, 0, lengthOf(wellID) - 4) + "_longest_path.tif");
	selectWindow("Branch information");
	saveAs("results", MATLAB_path_info + substring(wellID, 0, lengthOf(wellID) - 4) + "_MATLAB.csv");
	close(substring(wellID, 0, lengthOf(wellID) - 4) + "_MATLAB.csv");
	selectWindow("Results");
	saveAs("results", longest_shortest + substring(wellID, 0, lengthOf(wellID) - 4) + "_ImageJ.csv");
	close("Results");
	if (isOpen("Tagged skeleton")){
		close("Tagged skeleton");
	}
}

setOption("JFileChooser", true);
plate_directory = getDirectory("Choose Skeleton Analysis Input Plate:");
wells = getFileList(plate_directory);
well_num = wells.length;

longest_shortest_directory = getDirectory("Choose Longest Shortest Path Data Output Folder:");
longest_path_image_directory = getDirectory("Choose Longest Shortest Path Image Output Folder:");
MATLAB_path_input_directory = getDirectory("Choose MATLAB Path Analysis Input Folder");
setBatchMode("show");

for (i = 0; i<well_num; i++){
	well_directory = plate_directory + wells[i];
	processSkeleton(well_directory, longest_shortest_directory, longest_path_image_directory, MATLAB_path_input_directory);
}