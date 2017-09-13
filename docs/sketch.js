function setup() {
  createCanvas(windowWidth, windowHeight);
  textAlign(LEFT, CENTER);
  display();
}

function draw() {
  //do nothing now...
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  display();
}

function display() {
  background(0);
  fill(255, 150);
  rect(0, 0, windowWidth, windowHeight / 12);
  fill(0);
  textsize(0);
  text("PositionWriter site - under cunstruction", windowHeight / 24,
    widowHeight / 24);

}
