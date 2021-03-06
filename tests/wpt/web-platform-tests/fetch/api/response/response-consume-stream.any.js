// META: global=window,worker
// META: title=Response consume
// META: script=../resources/utils.js

promise_test(function(test) {
    var body = "";
    var response = new Response("");
    return validateStreamFromString(response.get_body().getReader(), "");
}, "Read empty text response's body as readableStream");

promise_test(function(test) {
    var response = new Response(new Blob([], { "type" : "text/plain" }));
    return validateStreamFromString(response.get_body().getReader(), "");
}, "Read empty blob response's body as readableStream");

var formData = new FormData();
formData.append("name", "value");
var textData = JSON.stringify("This is response's body");
var blob = new Blob([textData], { "type" : "text/plain" });
var urlSearchParamsData = "name=value";
var urlSearchParams = new URLSearchParams(urlSearchParamsData);

promise_test(function(test) {
    var response = new Response(blob);
    return validateStreamFromString(response.get_body().getReader(), textData);
}, "Read blob response's body as readableStream");

promise_test(function(test) {
    var response = new Response(textData);
    return validateStreamFromString(response.get_body().getReader(), textData);
}, "Read text response's body as readableStream");

promise_test(function(test) {
    var response = new Response(urlSearchParams);
    return validateStreamFromString(response.get_body().getReader(), urlSearchParamsData);
}, "Read URLSearchParams response's body as readableStream");

promise_test(function(test) {
    var arrayBuffer = new ArrayBuffer(textData.length);
    var int8Array = new Int8Array(arrayBuffer);
    for (var cptr = 0; cptr < textData.length; cptr++)
        int8Array[cptr] = textData.charCodeAt(cptr);

    return validateStreamFromString(new Response(arrayBuffer).body.getReader(), textData);
}, "Read array buffer response's body as readableStream");

promise_test(function(test) {
    var response = new Response(formData);
    return validateStreamFromPartialString(response.get_body().getReader(),
      "Content-Disposition: form-data; name=\"name\"\r\n\r\nvalue");
}, "Read form data response's body as readableStream");

test(function() {
    assert_equals(Response.error().body, null);
}, "Getting an error Response stream");

test(function() {
    assert_equals(Response.redirect("/").body, null);
}, "Getting a redirect Response stream");
