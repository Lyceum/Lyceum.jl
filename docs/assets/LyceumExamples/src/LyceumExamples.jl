module LyceumExamples

import IJulia

function notebooks() 
  IJulia.notebook(dir=joinpath(@__DIR__, "../notebooks"), detatched=true)
end

end # module
