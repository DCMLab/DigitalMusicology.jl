module External

using DigitalMusicology
import Base: show
using NodeJS: nodejs_cmd

export musescore, verovio, HumDrumString, exampleHumDrumString

# Musescore
# ---------

"""
    musescore(id, [corpus])

Opens the midi file of the piece that `id` refers to using Musescore.
If `corpus` is not supplied, the current default corpus is used.
"""
musescore(id, corpus = get_corpus()) = begin
    file = piece_path(id, "m", ".mid", corpus)
    run(`musescore $file`)
end

# verovio output in notebooks
# ---------------------------

# humdrum string type

"""
    HumDrumString("some humdrum")

A wrapper class that enables rendering and midi playback
of humdrum code in the browser using verovio.
When a HumDrumString is the result of a jupyter notebook cell,
its content will be rendered to the output cell automatically.
"""
struct HumDrumString
    content :: String
end

show(io::IO, ::MIME"text/plain", hds::HumDrumString) =
    write(io, hds.content)

# output in notebooks

# <script src="https://code.jquery.com/jquery-3.1.1.min.js"
#         type="text/javascript" ></script>
# <script src="http://verovio-script.humdrum.org/scripts/verovio-toolkit.js"
#         type="text/javascript"></script>
# <script src="http://www.verovio.org/javascript/midi-player/wildwebmidi.js"
#         type="text/javascript"></script>
# <script src="http://www.verovio.org/javascript/midi-player/midiplayer.js"
#         type="text/javascript"></script>

scrpath = joinpath(Pkg.dir("DigitalMusicology"), "data", "")

kernhtml(cellid, content) = """
<script id="$(cellid)-input" type="text/humdrum">
$(content)</script>
"""

# TODO:: load wildwebmidi.data from local file, not verovio.org
veroviohtml(cellid, svg) = """
<div id="$(cellid)-svg-out">$(svg)</div>
<button id="$(cellid)-play-button" type="button">Play</button>

<script type="text/javascript">
  setup_player("http://www.verovio.org/");
  setup_cell("$(cellid)");
</script>
"""

show(io::IO, ::MIME"text/html", hds::HumDrumString) = begin
    id = string("vero-", rand(Int))
    svg = veroviosvg(hds)
    write(io, kernhtml(id, hds.content), veroviohtml(id, svg))
end

"""
    verovio()

Set up display of [`HumDrumString`](@ref)s in Jupyter Notebooks.
"""
function verovio()
    if isdefined(Main, :IJulia)
        scrpath = joinpath(Pkg.dir("DigitalMusicology"), "data", "")
        vero = readstring(scrpath * "verovio-toolkit.js")
        wwm  = readstring(scrpath * "wildwebmidi.js")
        mp   = readstring(scrpath * "midiplayer.js")
        main = readstring(scrpath * "julia_verovio.js")
        map([vero, wwm, mp, main]) do js
            display(MIME"text/html"(), "<script type=\"text/javascript\">$(js)</script>")
        end
    else
        error("Not in an IJulia session, won't set up verovio viewer.")
    end
    return
end

function veroviosvg(hds::HumDrumString)
    script = joinpath(Pkg.dir("DigitalMusicology"), "data", "mksvg.js")
    (proc_out, proc_in, proc) = readandwrite(`$(nodejs_cmd()) $(script)`)
    write(proc_in, hds.content)
    close(proc_in)
    svg = readstring(proc_out)
    close(proc_out)
    return svg
end

# example instance

exampleHumDrumString = HumDrumString("""
**kern	**kern
*clefF4	*clefG2
*k[f#]	*k[f#]
*M4/4	*M4/4
=-	=-
8GL	8ddL
8AJ	8ccJ
16BLL	2.b;
16A	.
16G	.
16F#JJ	.
2G;	.
==	==
*-	*-
""")

end # module
