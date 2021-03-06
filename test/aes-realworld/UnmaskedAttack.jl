

include("ParseData.jl")

"""
    hamming_distance_power_estimate(ciphertext, key_guess_index, key_guess)

A power estimation function targeting the last round of AES under the Hamming distance model, suitable for the real-word data provided. For more information on power estimation, see the [main section](@ref power_estimation_function).
"""
function hamming_distance_power_estimate(ciphertext, key_guess_index, key_guess)
    state = permutedims(reshape(ciphertext, 4, 4), [2,1])
    AES.shift_rows!(state)

    final_state = state[((key_guess_index - 1) ÷ 4) + 1, ((key_guess_index - 1) % 4) + 1]
    AES.inv_shift_rows!(state)
    state[((key_guess_index - 1) ÷ 4) + 1, ((key_guess_index - 1) % 4) + 1] ⊻= key_guess
    AES.inv_sub_bytes!(state)
    preround_state = state[((key_guess_index - 1) ÷ 4) + 1, ((key_guess_index - 1) % 4) + 1]
    Base.count_ones(preround_state ⊻ final_state)
end

function attack(; number_of_traces = 7000)
    @time begin
        println("Parsing $(number_of_traces) traces.")

        inputs = parse_input_file("/home/simon/Documents/Uni/cam/thesis/traces/001_cipher.txt", number_of_traces)
        traces = parse_trace_file("/home/simon/Documents/Uni/cam/thesis/traces/001_trace_int.txt", number_of_traces)
    end
    println("Parsing completed, starting attack")

    @assert length(inputs) == size(traces, 2)

    @time begin
    last_round_key = CPA.CPA_AES_analyze_manual(inputs, traces, hamming_distance_power_estimate)
    aes_128_key = AES.inv_key_expand(last_round_key)[1:16]
    end

    REFERENCE_KEY = hex2bytes("000102030405060708090A0B0C0D0E0F")
    println("Reconstructed last round key: $(bytes2hex(last_round_key))")
    reference_last_round_key = AES.key_expand(REFERENCE_KEY)[end-15:end]
    println("Reference     last round key: $(bytes2hex(reference_last_round_key))")

    println("Reconstructed key: $(bytes2hex(aes_128_key))")
    println("Reference     key: $(bytes2hex(REFERENCE_KEY))")

    if REFERENCE_KEY == aes_128_key
        println("Reconstructed key matches.")
    else
        println("Reconstructed key does not match.")
    end
end

attack()


end
