// loader.js
request = new XMLHttpRequest();
request.open('GET', '/wasm/dsxm.wasm');
request.responseType = 'arraybuffer';
request.send();

request.onload = function() {
  var bytes = request.response;
  WebAssembly.instantiate(bytes, {
    env: {}
  }).then(result => {
    var dsx_f2c = result.instance.exports.dsx_f2c;
    console.log(dsx_f2c(102.0));
  });
};
