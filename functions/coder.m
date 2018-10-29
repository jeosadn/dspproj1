function coder(audio_input_filename, audio_output_filename, metaData, a0, t0, a1, t1, segmentSize, Channel)
    %--------------------------------------------------------------------------
    % Read audio File
    %--------------------------------------------------------------------------
    %Input characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    [sampleData, sampleFrequency] = audioread(audio_input_filename);

    %--------------------------------------------------------------------------
    % Segment signal
    %--------------------------------------------------------------------------
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
    H0 = zeros(t0,1);
    H0(1) = 1;
    H0(t0) = a0;
    h0 = impz(H0,1);
    h0 = h0';

    H1 = zeros(t1,1);
    H1(1) = 1;
    H1(t1) = a1;
    h1 = impz(H1,1);
    h1 = h1';

    temp0 = zeros(1,segmentSize+t0-1);
    temp1 = zeros(1,segmentSize+t1-1);

    ex0 = zeros(1,t0-1);
    ex1 = zeros(1,t1-1);

    tMax = t1;
    if (t0>t1)
        tMax = t0;
    end

    temp_y = zeros(segmentTotal,segmentSize+tMax-1);

    if (length(metaData) > segmentTotal)
        fprintf('Error, metaData longer than number of segments\n');
    else
        metaData(length(metaData)+1:segmentTotal+tMax-1) = 0;
    end

    for i = 1:segmentTotal
        if(metaData(i))
            temp1 = conv(v(i,:),h1);
            for j = 1:segmentSize+t1-1
                temp_y(i,j) = temp1(j);
            end
        else
            temp0 = conv(v(i,:),h0);
            for j = 1:segmentSize+t0-1
                temp_y(i,j) = temp0(j);
            end
        end
    end

    %--------------------------------------------------------------------------
    % Combining
    %--------------------------------------------------------------------------
    y = zeros(segmentTotal,segmentSize);
    ex = zeros(segmentTotal,tMax-1);

    for i = 1:segmentTotal
        for j = 1:segmentSize+tMax-1
            if (j<=segmentSize)
                if (j>tMax-1)
                    y(i,j) = temp_y(i,j);
                else
                    y(i,j) = temp_y(i,j)+ex(i,j);
                end
            else
                ex(i,j-segmentSize) = temp_y(i,j);
            end
        end
    end

    %--------------------------------------------------------------------------
    % Unifying segments
    %--------------------------------------------------------------------------
    index = 0;
    for i = 1:segmentTotal
        for j = 1:segmentSize
            index = index+1;
            if (index < signalSize(1))
                sampleData(index,Channel) = y(i,j);
            end
        end
    end

    % Adding this to remove warning from audiowrite function.
    maxValue = max( abs(sampleData(:,Channel)) );
    for i = 1:signalSize(1)
        sampleData(i,Channel) = sampleData(i,Channel)/maxValue;
    end

    %--------------------------------------------------------------------------
    % Write audio file
    %--------------------------------------------------------------------------
    %Output characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    audiowrite(audio_output_filename, sampleData, sampleFrequency);
end
