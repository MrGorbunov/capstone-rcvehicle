
import http.*;

SimpleHTTPServer server;

void setup () {
  size(400, 400);

  server = new SimpleHTTPServer(this);
  server.serve("bg", "bg.html", "readRequest");
}

void readRequest(String uri, HashMap<String, String> parameterMap) {
  println(parameterMap);
}

void draw () {
  background(50);
}

