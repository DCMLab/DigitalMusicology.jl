const verovio = require('verovio-dev');
//const readline = require('readline');

var vtk = new verovio.toolkit();
var input = '';

process.stdin.on('data', function(data){
    input += data.toString();
});
process.stdin.on('end', function(){
    //onsole.log('input: ');
    //console.log(input);
    
    var options = {
        inputFormat: "auto",
        adjustPageHeight: 1,
        pageHeight: 1000,
        pageWidth: 1000,
        scale: 40,
        //border: 40,
        font: "Leipzig"
    };


    var svg = vtk.renderData(input, options);
    console.log(svg);
});
process.stdin.resume();
