%no popups
set(gcf, 'Visible', 'off');

%imports
addpath('./export_fig/');

%Parameters
segmentSize = 6000;             %This should come from the parameters.
Channel = 1;                    %This should come from the parameters.
a0 = 0.831;                       %Gain of first eco.
t0 = 792;                       %Delay of first eco.
a1 = 0.628;                       %Gain of second eco.
t1 = 837;                       %Gain of second eco.
decoder_delay_tolerance = 3;    %Delay tolerance in decoder.

% FIXME (JOSE): 
% This is only to test, remove when metaData will be ready
[sampleData, sampleFrequency] = audioread('./sample2.wav');
signalSize = size(sampleData(:,Channel));
segmentTotal = ceil(signalSize(1)/segmentSize);

hola = xcorr(sampleData(:,Channel));
metaData = round(rand(segmentTotal,1)); %This should be real metaData.
% END FIXME

% Calling coder
coder('./sample2.wav',metaData,a0,t0,a1,t1,segmentSize,Channel);

% Calling decoder
[dataDecoded] = decoder(a0,t0,a1,t1,segmentSize,Channel,decoder_delay_tolerance);

% Checking data correctness
number_wrong_bits = 0;
for i = 1:segmentTotal
    if (metaData(i)~= dataDecoded(i))
        if(i==1)
            fprintf('Wrong data in index: ');
        end
        fprintf('%d:%d, ',i,metaData(i));
        number_wrong_bits = number_wrong_bits + 1;
    end
end
fprintf('\nNumber of wrong bits %d\n',number_wrong_bits);