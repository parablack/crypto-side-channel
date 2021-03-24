import Base.:+

module CSC
    using StaticArrays

    include("types/GenericLog.jl")
    include("types/Masking.jl")

    include("cipher/AES.jl")
    include("cipher/SPECK.jl")


    include("attack/DPA.jl")
    include("attack/CPA.jl")
    include("attack/Template.jl")

    export AES
    export SPECK
    export Logging
    export Masking
    export DPA
    export CPA
    export TemplateAttacks

end # module