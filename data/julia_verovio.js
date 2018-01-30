var setup;
if (setup == undefined) {
    vtk = new verovio.toolkit();
    setup = false;
}

// quick hacks: create invisible elements for the midi player
midiPlayer_bar = document.createElement("div");
midiPlayer_progress = document.createElement("div");
midiPlayer_playingTime = document.createElement("div");
midiPlayer_play = document.createElement("a");
midiPlayer_pause = document.createElement("a");
midiPlayer_stop = document.createElement("a");
midiPlayer_totalTime = document.createElement("div");

function setup_player(path) {
    if (setup) return;
    console.log("script path: "+path);
    MidiPlayer.filePackagePrefixURL = path;
    MidiModule(MidiPlayer);
    setup = true;
}

function setup_cell(cellid) {
    var data;
    
    var ids = [];
    var midiUpdate = function(time) {
        var vrvTime = Math.max(0, time - 400);
        var elementsattime = vtk.getElementsAtTime(vrvTime);
        if (elementsattime.page > 0) {
            if ((elementsattime.notes.length > 0) && (ids != elementsattime.notes)) {
                ids.forEach(function(noteid) {
                    if ($.inArray(noteid, elementsattime.notes) == -1) {
                        $("#" + cellid + "-" + noteid ).attr("fill", "#000");
                        $("#" + cellid + "-" + noteid ).attr("stroke", "#000");
                        //$("#" + noteid ).removeClassSVG("highlighted");
                    }
                });
                ids = elementsattime.notes;
                ids.forEach(function(noteid) {
                    if ($.inArray(noteid, elementsattime.notes) != -1) {
                        //console.log(noteid);
                        $("#" + cellid + "-" + noteid ).attr("fill", "#c00");
                        $("#" + cellid + "-" + noteid ).attr("stroke", "#c00");;
                        //$("#" + noteid ).addClassSVG("highlighted");
                    }
                });
            }
        }
    };

    var midiStop = function() {
        ids.forEach(function(noteid) {
            $("#" + cellid + "-" + noteid ).attr("fill", "#000");
            $("#" + cellid + "-" + noteid ).attr("stroke", "#000");
            //$("#" + noteid ).removeClassSVG("highlighted");
        });
    };
    
    var play_midi = function() {
        vtk.loadData(data);
        var base64midi = vtk.renderToMidi();
        var song = 'data:audio/midi;base64,' + base64midi;

        midiPlayer_onStop = midiStop;
        midiPlayer_onUpdate = midiUpdate; 
        midiPlayer_updateRate = 20; // 50 orig.

        //play song without jQuery plugin
        if (midiPlayer_isLoaded == false) {
            midiPlayer_input = song;
        }
        else {
            var byteArray = convertDataURIToBinary(song);
            if (midiPlayer_totalSamples > 0) {
                stop();
                // a timeout is necessary because otherwise writing to the disk is not done
                setTimeout(function() {convertFile("player.midi", byteArray);}, 200);
            }
            else {
                convertFile("player.midi", byteArray);
            }
        }
    };

    //options
    var options = {
        inputFormat: "auto",
        adjustPageHeight: 1,
        pageHeight: 1000,
        pageWidth: 1000,
        scale: 40,
        //border: 40,
        font: "Leipzig"
    };

    //svg
    var input = document.querySelector("#"+cellid+"-input");
    data = input.textContent.replace(/^\s+/g, "");
    console.log(data);
    var svg = vtk.renderData(data, options);
    // replace in svg:
    // * ids (id="someid")
    svg2 = svg.replace(/id="(.*)"/g, "id=\""+cellid+"-$1\"");
    // * links (xlink:href="#someid")
    svg3 = svg2.replace(/xlink:href="#(.*)"/g, "xlink:href=\"#"+cellid+"-$1\"");
    $("#"+cellid+"-svg-out").html(svg3);
    $("#"+cellid+"-play-button").click(play_midi);
}
