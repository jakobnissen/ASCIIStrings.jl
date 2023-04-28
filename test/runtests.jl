using ASCIIStrings
using Test

@testset "Instantiation" begin
    @test_throws ErrorException ASCIIString("½")
    @test_throws ErrorException ASCIIString("abcdeæac")
    @test_throws ErrorException ASCIIString("å!!")

    for s in ["", "\0\0", "\0\x7f", "\x7f", "abcdef", "!!~+_:,AXB"]
        @test ASCIIString(s) isa ASCIIString
        @test ASCIIString(Test.GenericString(s)) isa ASCIIString
    end
end

@testset "String comparison" begin
    for s in ["", "\0\0", "\0\x7f", "\x7f", "abcdef", "!!~+_:,AXB"]
        a = ASCIIString(s)
        @test a == s
        @test a == ASCIIString(Test.GenericString(s))
        @test isequal(a, s)
        @test hash(a) == hash(s)
        @test codeunits(a) == codeunits(s)
    end
end

@testset "Basic properties" begin
    @test isempty(ASCIIString(""))
    @test !isempty(ASCIIString("!"))

    for s in ["", "\0\0", "\0\x7f", "\x7f", "abcdef", "!!~+_:,AXB"]
        a = ASCIIString(s)
        @test ncodeunits(a) == length(a) == ncodeunits(s)
        @test isascii(a)
    end
end

@testset "Indexing" begin
    s1 = ASCIIString("Abracadabra!") # 12 codeunits

    @test !isvalid(s1, -3)
    @test !isvalid(s1, 0)
    @test !isvalid(s1, 13)

    @test_throws BoundsError codeunit(s1, 0)
    @test_throws BoundsError codeunit(s1, 13)

    @test_throws BoundsError s1[0]
    @test_throws BoundsError s1[-5]
    @test_throws BoundsError s1[13]

    for i in 1:ncodeunits(s1)
        @test thisind(s1, i) == i
        @test prevind(s1, i) == i - 1
        @test nextind(s1, i) == i + 1
        @test isvalid(s1, i)
        @test Char(codeunit(s1, i)) == s1[i]
    end
end

@testset "Other string ops" begin
    v = [
        "",
        "\0\0",
        "\0\x7f",
        "\x7f",
        "abcdef",
        "!!~+_:,AXB",
        "This Is some longEr string :!cc<<",
    ]
    for s in v
        a = ASCIIString(s)
        @test reverse(a) == reverse(s)
        @test uppercase(a) == uppercase(s)
        @test lowercase(a) == lowercase(s)
        @test collect(a) == collect(s)
    end
    @test sort(v) == sort(map(ASCIIString, v))
end
