clf;
close all;
clear;
clc;

basicMeasurementsDir = uigetdir(cd, "Select Basic Measurements Directory");
pathAnalysisDir = uigetdir(cd, "Select MATLAB Path Analysis Output Directory");
widthMeasurementsDir = uigetdir(cd, "Select MATLAB Width Measurements Directory");
roughnessMeasurementsDir = uigetdir(cd, "Select MATLAB Roughness Measurements Directory");
summaryDir = uigetdir(cd, "Select Summarized Measurements Directory");
unitConversion = input("Enter Unit Conversion: 1 px = __ um >> ");

cd(basicMeasurementsDir);
plates = ls("*.csv");
for i = 1:size(plates, 1)
    cd(basicMeasurementsDir);
    basicMeasurements = readcell(strip(convertCharsToStrings(plates(i, :)), 'right'));
    measurementsSummary = cell(size(basicMeasurements, 1), 6);
    measurementsSummary(1, :) = {'Well', 'Length (mm)', 'Average Width Entire Scratch (um)', 'Average Width Scratch Middle (um)', 'Tortuosity', 'Average Roughness (um)'};
    labels = split(basicMeasurements(2:end, 2), '.');
    measurementsSummary(2:end, 1) = labels(:, 1);
    measurementsSummary(2:end, 2) = num2cell( 0.001*unitConversion*cell2mat( basicMeasurements(2:end, 5) ) );
    areas = cell2mat(basicMeasurements(2:end, 3));

    cd(pathAnalysisDir);
    pathAnalysis = readcell(strip(convertCharsToStrings(plates(i, :)), 'right'));
    averageWidthEntireScratch = unitConversion * ( areas ./ cell2mat(pathAnalysis(2:end,  10)) );
    measurementsSummary(2:end, 3) = num2cell(averageWidthEntireScratch);
    measurementsSummary(2:end, 5) = pathAnalysis(2:end, 8);

    cd(widthMeasurementsDir);
    widthMeasurements = readcell(strip(convertCharsToStrings(plates(i, :)), 'right'));
    averageWidthScratchMiddle = unitConversion * cell2mat(widthMeasurements(2:end, 2));
    measurementsSummary(2:end, 4) = num2cell(averageWidthScratchMiddle);
    
    cd(roughnessMeasurementsDir);
    roughnessMeasurements = readcell(strip(convertCharsToStrings(plates(i, :)), 'right'));
    averageRoughness = unitConversion * cell2mat(roughnessMeasurements(2:end, 2));
    measurementsSummary(2:end, 6) = num2cell(averageRoughness);
    
    cd(summaryDir);
    writecell(measurementsSummary, strip(convertCharsToStrings(plates(i, :)), 'right'));
end
