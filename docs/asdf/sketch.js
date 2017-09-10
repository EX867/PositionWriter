function setup() {
  createCanvas(windowWidth, windowHeight);
  stroke(255);
  fill(255);
  textAlign(CENTER, CENTER);
  display();
}

function draw() {
  if (mouseIsPressed) {
    line(pmouseX, pmouseY, mouseX, mouseY);
  }
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  display();
}

function display() {
  background(0);
  strokeWeight(2);
  textSize(min(windowWidth, windowHeight) / 8);
  text("I like\nProcessing!", windowWidth / 2, windowHeight / 2);
  strokeWeight(10);
}
