%% Please read the file ReadMe.txt in the same directory
% clc % this command clears the screen of previous printouts 
clear % this clears the list of variables

%% FileObject stores the data for each I62-file
% Starting with the fields

field1 = 'Npoints'; value1=0;
field2 = 'Deltax'; value2=0;
field3 = 'IndexOfFirstData'; value3=0;
field4 = 'DataSeries'; value4=0;
field5 = 'sigma'; value5=0;
field6 = 'mean'; value6=0;
field7 = 'Events'; value7=0;
field8 = 'NumberOfEvents'; value8=0;
field9 = 'PeakWidths'; value9=0;
field10 = 'NumberOfPeaks'; value10=0;
field11 = 'Filename'; value11=0;
field12 = 'ModEvents'; value12=0;
field13 = 'NoEvents'; value13=0;
field14 = 'ModNumberOfEvents'; value14=0;
field15 = 'ModSigma'; value15=0;
field16 = 'ModMean'; value16=0;
field17 = 'ModPeakWidths'; value17=0;
field18 = 'ModNumberOfPeaks'; value18=0;
field19 = 'ListOfFilesWithEvents'; value19=0;
field20 = 'pointsTo'; value20=0;
field21 = 'PeakVolumes'; value21=0;

% FieldObject or FileObject = FO
FO = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field7,value7,field8,value8,field9,value9,field10,value10,field11,value11,field12,value12,field13,value13,field14,value14,field15,value15,field16,value16,field17,value17,field18,value18,field19,value19,field20,value20,field21,value21);

%% This function gets the user's input on file names and file path
[fileName,filePath,plotJN,pdfJN] = GetUserInput(); % to be used in the call MakeListOfFiles...

%% This function creates a list of the files that are to be analyzed
[fileList, numberOfFiles] = MakeListOfFiles(filePath, fileName); % What files are there in the folder?
% [~,numberOfFiles] = size(fileList);

%% The function Constants stores all the constants
% NOT NEEDED
% SizeOfHeader = Constants(1);

%% Makes the header in the output text file.
MakeOutPutFileHeader();


% setting all sorts of utility-variables. Maybe do it in a function?
n=1;    % iterator for ListOfFilesWithEvents
PeakWidthArray = 0;     % needs to be declared to be a concatenatable variable
ModPeakWidthArray = 0;  % needs to be declared to be a concatenatable variable
ArrayOfPeakVolumes = 0;
% end of utility-variables

for fileIter = 1:numberOfFiles

    %% Storing the file list in the FileObject
    FO(fileIter).Filename = fileList(fileIter);
    
    %% OpenAndReadFile opens and reads a file and returns Npoints, Deltax and index of the First Data
    [FO(fileIter).Npoints, FO(fileIter).Deltax, FO(fileIter).IndexOfFirstData] = OpenAndReadFile(fileList(fileIter)); 
    
    %% ReadDataSeries takes a file, opens, reads and returns an array with the data values
    [FO(fileIter).DataSeries] = ReadDataSeries(FO(fileIter).Npoints,fileList(fileIter));
       
    %% CalcSigmaAndMean calculates the sigma and mean of a given dataseries
    [FO(fileIter).sigma, FO(fileIter).mean] = CalcSigmaAndMean(FO(fileIter).DataSeries);

    %% CalcEvents calculates the events, stored in an array, and the number of events as a scalar
    [FO(fileIter).Events, FO(fileIter).NumberOfEvents] = CalcEvents(FO(fileIter).sigma, FO(fileIter).mean, FO(fileIter).DataSeries);

    %% Creates a list of only the files with events in them
    [FO(n).ListOfFilesWithEvents, FO(n).pointsTo, n] = GetListOfFilesWithEvents(FO(fileIter).NumberOfEvents, FO(fileIter).DataSeries, n, fileIter);
       
    %% Counts the number of peaks and peakwidths
    [FO(fileIter).PeakWidths, FO(fileIter).NumberOfPeaks] = PeakWidth(FO(fileIter).Events);

    %% Getting modified Events based on mean and sigma without the events
    [FO(fileIter).NoEvents] = GetNoEvents(FO(fileIter).DataSeries);
    [FO(fileIter).ModSigma, FO(fileIter).ModMean] = CalcSigmaAndMean(FO(fileIter).NoEvents);
    [FO(fileIter).ModEvents, FO(fileIter).ModNumberOfEvents] = CalcEvents(FO(fileIter).ModSigma, FO(fileIter).ModMean, FO(fileIter).DataSeries);
    
    %% Getting the volumes of the peaks
    [FO(fileIter).PeakVolumes, ArrayOfPeakVolumes] = PeakVolume(FO(fileIter).ModEvents,FO(fileIter).DataSeries, ArrayOfPeakVolumes);
    
    
    %% Getting the mod numbers from the ModEvents array
    [FO(fileIter).ModPeakWidths, FO(fileIter).ModNumberOfPeaks] = PeakWidth(FO(fileIter).ModEvents);
    
    %% Creating arrays from PW and MPW
    [PeakWidthArray,ModPeakWidthArray] = ArrayFromPeakWidths(PeakWidthArray,FO(fileIter).PeakWidths,ModPeakWidthArray,FO(fileIter).ModPeakWidths);
    
    %% Writes the filename and number of events to a .txt-file
    OutputResultsToOutputFile(FO(fileIter).Filename, FO(fileIter).NumberOfEvents, FO(fileIter).ModNumberOfEvents, FO(fileIter).ModMean);
end

%% Creates a graph with the threshold value as a horizontal line and the number of events
% checking for user inputs of plots and pdf        
if (plotJN == 'J' || pdfJN == 'J')           
    OutputPlots(fileList,plotJN,pdfJN);     % plotting and outputting to .pdf-files
end

%% Outputs a histogram of the peak widths
PeakWidthsHistograms(PeakWidthArray, ModPeakWidthArray); % plotting histograms of peak widths
GlobalHistogram(FO, ArrayOfPeakVolumes); % maybe come up with a less crude way of sending arguments to the function

