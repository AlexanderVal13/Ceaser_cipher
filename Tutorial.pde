class Tutorial {

  String fullText;

  Tutorial() {
    String[] lines = loadStrings("tutorialText.txt");
    fullText = join(lines, " ");
  }

  void display() {

    background(100, 190, 255);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(24);

    // This makes text wrap automatically
    text(fullText, 50, 60, width - 100, height - 120);

    // --- NEXT BUTTON ---
    float nextX = width - 180;
    float nextY = height - 90;
    float nextW = 140;
    float nextH = 60;

    // visible button (so you can see it)
    fill(255, 200, 50);
    rect(nextX, nextY, nextW, nextH, 10);

    fill(0);
    textSize(30);
    text("Next", (nextX-33) + nextW/2, (nextY-12) + nextH/2);
  }
}
