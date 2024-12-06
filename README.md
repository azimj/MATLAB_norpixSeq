# MATLAB NorPix SEQ file reader:  MATLAB_norpixSeq

A MATLAB package to read frames, timestamp and file header from [Norpix/StreamPix][norpix] SEQ files. The code is based on Brett Shoelson's [`Norpix2MATLAB` function][Norpix2MATLAB].

[MATLAB R2020b][MATLAB-url]

## Installation

Add project folder to your MATLAB path.

## Package functions

List of functions provided in the package

* `readNorpixSeqHeader`
* `readNorpixSeqImage`
* `readNorpixSeqTimeStamp`
* `extractTimeStamp`
* `seq2avi`

## Usage Examples

```MATLAB
% Get File Header data
header_data=seq.readNorpixHeader(norpix_file_name);

% Read frames from file
[frame_sequence, frame_time_stamps]=seq.readNorpixImage(norpix_file_name,StartFrame,<EndFrame>);

% Read numeric and string time stamps
[numericTimeStamp, stringTimeStamp]=seq.readNorpixTimeStamp(norpix_file_name,StartFrame,<EndFrame>;

% Convert SEQ to AVI
seq2avi(norpix_file_name,'startFrame',1,'endFrame',100, ...
        'outputFrameRate',30,'videoProfile','Archival')
```

## ToDo

* [ ] Clean up help comments
* [ ] Create MATLAB deployable toolbox [MATLAB-toobox]

<!-- Markdown link & img definitions -->
[norpix]: https://www.norpix.com/
[Norpix2MATLAB]: https://www.norpix.com/support/Norpix2MATLAB.m
[MATLAB-image]: https://www.mathworks.com/etc/designs/mathworks/img/pic-header-mathworks-logo.svg
[MATLAB-url]: https://www.mathworks.com/products/matlab.html
[MATLAB-toobox]: https://www.mathworks.com/help/matlab/matlab_prog/create-and-share-custom-matlab-toolboxes.html
