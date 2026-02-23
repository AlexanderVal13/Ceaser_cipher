// --- MENU layout values (global) ---
float playX, playY, playW, playH;
float tutX,  tutY,  tutW,  tutH;

void drawMenu() {
  background(0);
  imageMode(CENTER);
  image(menuImage, width/2, height * 0.85, 300, 350);


  textFont(font);

  // ---- Title ----
  textAlign(CENTER, CENTER);
  fill(255, 80, 60);
  textSize(90);

  float titleY = height * 0.18;
  text("Caesar-cipher", width/2, titleY);

  // ---- Buttons  ----
  textSize(70);
  fill(40, 90, 255);

  // spacing
  float gap = 120;

  playY = titleY + gap;
  tutY  = playY + gap;

  // draw labels
  text("Play", width/2, playY);
  text("Learn", width/2, tutY);

  // build clickable boxes around the text
  playW = textWidth("Play");
  playH = textAscent() + textDescent();
  playX = width/2 - playW/2;

  tutW = textWidth("Tutorial");
  tutH = textAscent() + textDescent();
  tutX = width/2 - tutW/2;
}
