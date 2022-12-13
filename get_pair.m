function pair = get_pair(N_mic,size)
    vec_N_mic = 1:N_mic;
    pair = nchoosek(vec_N_mic,2);
    pair = pair(1:size,:);
