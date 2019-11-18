function setup() {
  createCanvas(windowWidth, windowHeight);
  textAlign(LEFT, CENTER);
  textSize(0);
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
  text("go to asdf, links, versioninfo", windowHeight / 24,
    windowHeight / 24);

}
