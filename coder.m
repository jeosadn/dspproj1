%no popups
set(gcf, 'Visible', 'off');

%imports
addpath('./export_fig/');

%--------------------------------------------------------------------------
% Read audio File
%--------------------------------------------------------------------------
%Input characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
[sampleData, sampleFrequency] = audioread('./sample.wav');

%--------------------------------------------------------------------------
% Segment signal
%--------------------------------------------------------------------------
segmentSize = 400;
Channel = 1;

signalSize = size(sampleData(:,Channel));
segmentTotal = ceil(signalSize(1)/segmentSize);
v = rand(segmentTotal,segmentSize);

index = 0;
for i = 1:segmentTotal
    for j = 1:segmentSize
        index = index+1;
        if (index < signalSize(1))
            v(i,j) = sampleData(index,Channel);
        else
            v(i,j) = 0;   
        end
    end
end

%--------------------------------------------------------------------------
% Multiplexing
%--------------------------------------------------------------------------
metaData = round(rand(segmentTotal,1));
syms H0(z) H1(z);

a0 = 0.2;
t0 = 0.8;
H0(z) = 1 + a0*z^(-t0);

a1 = 0.8;
t1 = 0.2;
H1(z) = 1 + a1*z^(-t1);

% y1(z) = z;
% y0(z) = z;
% 
% index1 = 0;
% index0 = 0;
% for i = 1:segmentTotal
%     for j = 1:segmentSize
%         if(metaData(i))
%             index1 = index1 + 1;
%             y1(index1) = y1(index)+(H1*v(i,j)*z^(-j+1)); 
%         else
%         
%         end
%     end
% end

%--------------------------------------------------------------------------
% Write audio file
%--------------------------------------------------------------------------
%Output characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
audiowrite('./output.wav', sampleData, sampleFrequency);
