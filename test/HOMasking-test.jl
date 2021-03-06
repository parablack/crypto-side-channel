using Test, StaticArrays, Random, CryptoSideChannel.Masking

TEST_VECTOR = [0,1,2,3,4,13,255,1337,2^31-1, 2^32, -1, -2, -10, -100, -1337, -2^32, 0x0, 0xAB, 0xFF, 0xCAFE, 0xFFFF]
TEST_VECTOR_SMALL = [0,1,255,2^32,-3,0xAA]

aa(x) = Masking.ArithmeticMask(Masking.ArithmeticMask((x)))
bb(x) = Masking.BooleanMask(Masking.BooleanMask((x)))
uu = (Masking.unmask ∘ Masking.unmask)

for i = TEST_VECTOR
    val1 = bb(i)
    @test uu(val1) == i
    @test uu(Masking.booleanToArithmetic(val1)) == i
    @test uu(~val1) == ~i

    val2 = aa(i)
    @test uu(val2) == i
    @test uu(Masking.arithmeticToBoolean(val2)) == i
    @test uu(~val2) == ~i
end

for i = TEST_VECTOR_SMALL
    for j = TEST_VECTOR_SMALL
        b1 = bb(i)
        b2 = bb(j)
        a1 = aa(i);
        a2 = aa(j);
        for op = [xor, |, &, +, -, *]

            @test uu(op(b1, j)) == op(i, j)
            @test uu(op(i, b2)) == op(i, j)
            @test uu(op(b1, b2)) == op(i, j)

            @test uu(op(a1, j)) == op(i, j)
            @test uu(op(i, a2)) == op(i, j)
            @test uu(op(a1, a2)) == op(i, j)

            @test uu(op(b1, a2)) == op(i, j)
            @test uu(op(a1, b2)) == op(i, j)
        end
        @test (i == j) == (b1 == b2)
        @test (i == j) == (a1 == a2)
        @test (i == j) == (a1 == b2)
        @test (i == j) == (b1 == a2)

    end
end
a = """
for i = TEST_VECTOR
    for j = (0:32)
        for op = [>>>, <<, Base.bitrotate]
            val1 = Masking.BooleanMask(i);
            val2 = Masking.ArithmeticMask(i);

            @test Masking.unmask(op(val1, j)) == op(i, j)
            @test Masking.unmask(op(val2, j)) == op(i, j)
        end
    end
end

for i = TEST_VECTOR_SMALL
    for j = TEST_VECTOR_SMALL
        for k = TEST_VECTOR_SMALL
            for op1 = [xor, +, -]
                for op2 = [xor, +, -]
                    val1 = Masking.BooleanMask(i);
                    val2 = Masking.BooleanMask(j);
                    val3 = Masking.BooleanMask(k);
                    masres = op1(val1, op2(val2, val3));
                    refres = op1(i, op2(j, k))
                    @test Masking.unmask(masres) == refres
                end
            end
        end
    end
end
"""

TEST_TUPLE = (0x2, 0x4, 0x6)
TEST_ARRAY = [123, 125, 1337, 42, 45, 45, 45, 45, 45]

for index = 1:length(TEST_TUPLE)
    masked_index = aa(index)
    @test uu(TEST_TUPLE[masked_index]) == TEST_TUPLE[index]
    masked_index = bb(index)
    @test uu(TEST_TUPLE[masked_index]) == TEST_TUPLE[index]
end
for index = 1:length(TEST_ARRAY)
    masked_index = aa(index)
    @test uu(TEST_ARRAY[masked_index]) == TEST_ARRAY[index]
    masked_index = bb(index)
    @test uu(TEST_ARRAY[masked_index]) == TEST_ARRAY[index]
end
