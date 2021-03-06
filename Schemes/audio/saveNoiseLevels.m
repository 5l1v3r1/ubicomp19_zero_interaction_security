function [] = saveNoiseLevels(nL1, nL2, noiseData)
% SAVENOISELEVELS Save noise levels to a JSON file

%   Input args:
%   - nL1 - Nose levels of generated from signal S1 (Mx1 vector)
%   - nL2 - Nose levels of generated from signal S2 (Mx1 vector)
%   - noiseData - Structure storing metadata (struct)

%   Output args: None

% Construct metadata struct
metadata = struct;

% Metadata struct: generator_version
metadata.generator_version = noiseData.scriptVersion;

% Get file paths like this Sensor-xx/audio/xx.flac
res = split(noiseData.filePath1, noiseData.expPath);
if strcmp(res{2}(1), '\') | strcmp(res{2}(1), '/')
    res{2} = res{2}(2:end);
end
pathNl1 = res{2};

% FileInfo struct: pack file paths (file hashes) and audioDuration
fileInfo = struct;
fileInfo.file = strcat(pathNl1, ' (', noiseData.nL1Hash, ')');

% Length of the audio recording over which noise levels were computed
fileInfo.audio_len = strcat(num2str(noiseData.nNoiseSamples), ' sec'); 

% Metadata struct: source_file
metadata.source_file = fileInfo;

% Metadata struct: generator_script
metadata.generator_script = strcat(mfilename, '.m');

% Feature struct: snapshot_len, noiseLevel array
feature = struct;
feature.noise_lev_sample_len_sec = noiseData.sampleLenSec;
feature.n_noise_lev_samples = length(nL1);
feature.noise_lev_samples = nL1;

% Metadata struct: created_on
metadata.created_on = datestr(datetime('now'), noiseData.dateFormat);

% Output struct: contains both metadata and results
output.metadata = metadata; 
output.results = feature;

% Save nL1 to a file
fileName = extractBetween(pathNl1, 'audio/', '.flac');
res = strsplit(pathNl1, '/');
logPath = strcat(noiseData.expPath, '/', res{1}, '/', res{2}); 
if isempty(noiseData.feature)
    mainLogFile = strcat(logPath, '/', 'Noise-', fileName, '.json');
else
    mainLogFile = strcat(logPath, '/', noiseData.feature, '/', ...
    'Noise-', fileName, '.json');
end

saveJsonFile(char(mainLogFile), output);

% Update fields for nL2

% Get file paths like this Sensor-xx/audio/xx.flac
res = split(noiseData.filePath2, noiseData.expPath);
if strcmp(res{2}(1), '\') | strcmp(res{2}(1), '/')
    res{2} = res{2}(2:end);
end
pathNl2 = res{2};

% Update "file" field in fileInfo
fileInfo.file = strcat(pathNl2, ' (', noiseData.nL2Hash, ')');
metadata.source_file = fileInfo;

% Update feature struct: snapshot_len, noiseLevel array
feature.n_noise_lev_samples = length(nL2);
feature.noise_lev_samples = nL2;

% Update output struct: contains both metadata and results
output.metadata = metadata; 
output.results = feature;

% Save nL2 to a file
fileName = extractBetween(pathNl2, 'audio/', '.flac');
res = strsplit(pathNl2, '/');
logPath = strcat(noiseData.expPath, '/', res{1}, '/', res{2}); 
if isempty(noiseData.feature)
    mainLogFile = strcat(logPath, '/', 'Noise-', fileName, '.json');
else
    mainLogFile = strcat(logPath, '/', noiseData.feature, '/', ...
    'Noise-', fileName, '.json');
end

saveJsonFile(char(mainLogFile), output);

end