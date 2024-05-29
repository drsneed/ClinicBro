// loader.js

var mapViewer = null;

var canvas = window.document.getElementById("map-canvas");
var ctx = canvas.getContext('2d');

canvas.addEventListener()

window.document.body.onload = function() {
    var env = { env: {} };
    WebAssembly.instantiateStreaming(fetch("/wasm/dsxm.wasm"), env).then(result => {
        console.log("Loaded the WASM!");
        mapViewer = result.instance.exports;
        //mapViewer.loaded = true;
        //mapViewer.init(); // initialize world
        run(); // begin
    });
};


var run = function() {
    var loop = function() {
        ctx.fillStyle = "black"; // clear the canvas
        ctx.fillRect(0, 0, 100, 100);
        // for(var x = 0; x < 10; x++) {
        //     for(var y = 0; y < 10; y++) {
        //     var cell = Game.get_pos(x, y);
        //     if (cell == 1)
        //         ctx.fillStyle = "red";
        //     else if (cell == 2)
        //         ctx.fillStyle = "grey";
        //     else
        //         ctx.fillStyle = "white";
        //     ctx.fillRect(x*10, y*10, (x*10)+10, (y*10)+10);
        //     }
        // }
        if (mapViewer.running)
            window.requestAnimationFrame(loop);
    };
    loop();
};

// request = new XMLHttpRequest();
// request.open('GET', '/wasm/dsxm.wasm');
// request.responseType = 'arraybuffer';
// request.send();
// request.onload = function() {
//   var bytes = request.response;
//   WebAssembly.instantiate(bytes, {
//     env: {}
//   }).then(result => {
//     console.log(result.instance.exports);
//     mapViewer = result.instance.exports;
//     console.log(mapViewer.f2c(102.0));
//   });
// };
