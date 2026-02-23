import java.awt.datatransfer.*;
import java.awt.Toolkit;
//Text input
int[] secretCount = new int[26];
int[] bookCount   = new int[26];
color ColorBook = color(255, 200, 50);
color ColorSecret = color(255, 35, 255);
String currentText = "";
String[] loadedFile;
boolean typing = true;
int guessedShift = 3;
PImage menuImage;

// Shift buttons
float shiftPlusX, shiftPlusY, shiftW = 60, shiftH = 50;
float shiftMinusX, shiftMinusY;


//Button widths and heights
float w = 160;
float h = 80;
float wT = 300;
float hT = 80;
PFont font;
// stores file lines

// NEXT button click
float nextX, nextY, nextW = 140, nextH = 60;
//Screens
final int MENU = 0;
final int PLAY_SCREEN = 1;
final int TUTORIAL_SCREEN = 2;
final int TUTORIAL_ON = 3;
//Class variables
Play play;
Tutorial tutorial;
//Default to menu screen
int screen = MENU;
int showFreq = 0;




//Settings like screen and font
void settings() {
  size(1000, 850);
  font = loadFont("SitkaText-48.vlw");
}

void setup() {
  play = new Play();
  tutorial = new Tutorial();
  nextX = width - 180;
  nextY = height - 90;
  fileBtnX = 20;
  fileBtnY = height - fileBtnH - 20;
  boxY = height - boxH - 20;

  shiftPlusX = width - 160;
  shiftPlusY = 300;

  shiftMinusX = width - 240;
  shiftMinusY = 300;
  englishModelCount = buildEnglishModelCounts(10); // increase number if you want smoother-looking bars
  
  menuImage = loadImage("ceaserWax.jpg"); // use your file name
}

void draw() {

  if (screen == MENU) {
    drawMenu();
  } else if (screen == PLAY_SCREEN) {
    play.display();
  } else if (screen == TUTORIAL_SCREEN) {
    tutorial.display();
  } else if (screen == TUTORIAL_ON) {
    play.display();
  }
}



void mousePressed() {

  if (screen == MENU) {
    // Play
    if (mouseX >= playX && mouseX <= playX + playW &&
      mouseY >= playY - playH/2 && mouseY <= playY + playH/2) {
      screen = PLAY_SCREEN;
      return;
    }

    // Tutorial
    if (mouseX >= tutX && mouseX <= tutX + tutW &&
      mouseY >= tutY - tutH/2 && mouseY <= tutY + tutH/2) {
      screen = TUTORIAL_SCREEN;
      return;
    }
  }

  // Tutorial Next Button clicked
  if (mouseX > nextX && mouseX < nextX + nextW &&
    mouseY > nextY && mouseY < nextY + nextH &&
    screen == TUTORIAL_SCREEN) {
    screen = PLAY_SCREEN;
  }
  //file button
  if (mouseX > fileBtnX && mouseX < fileBtnX + fileBtnW &&
    mouseY > fileBtnY && mouseY < fileBtnY + fileBtnH && screen == PLAY_SCREEN) {
    selectInput("Select a text file:", "fileSelected");
  }

  if (screen == PLAY_SCREEN) {

    // Minus button
    if (mouseX > shiftMinusX && mouseX < shiftMinusX + shiftW &&
      mouseY > shiftMinusY && mouseY < shiftMinusY + shiftH) {

      guessedShift--;
      if (guessedShift < 0) guessedShift = 25;
    }

    // Plus button
    if (mouseX > shiftPlusX && mouseX < shiftPlusX + shiftW &&
      mouseY > shiftPlusY && mouseY < shiftPlusY + shiftH) {

      guessedShift++;
      if (guessedShift > 25) guessedShift = 0;
    }
  }
}


int[] countLetters(String text) {
  int[] counts = new int[26];

  text = text.toUpperCase();

  for (int i = 0; i < text.length(); i++) {
    char c = text.charAt(i);

    if (c >= 'A' && c <= 'Z') {
      counts[c - 'A']++;
    }
  }

  return counts;
}


void keyPressed() {
  if (screen != PLAY_SCREEN && screen != TUTORIAL_ON) return;

  if (key == BACKSPACE) {
    if (currentText.length() > 0) {
      currentText = currentText.substring(0, currentText.length() - 1);
    }
    return;
  }

  if (key == ENTER || key == RETURN) {
    currentText = cleanText(currentText);

    // make the secret actually encrypted
    String secretCipher = caesarEncrypt(currentText, guessedShift);

    // count letters from ciphertext (pink bars + auto guess)
    secretCount = countLetters(secretCipher);

    // store ciphertext so you can display it as "Secret:"
    currentText = secretCipher;

    showFreq = 1;
    return;
  }
}

boolean hasSecret() {
  return cleanText(currentText).length() > 0;
}

boolean hasBook() {
  return loadedFile != null && loadedFile.length > 0;
  // or: return totalCount(bookCount) > 0;
}

int totalCount(int[] counts) {
  int sum = 0;
  for (int i = 0; i < counts.length; i++) sum += counts[i];
  return sum;
}

void fileSelected(File selection) {
  if (selection == null) {
    println("No file selected.");
  } else {
    loadedFile = loadStrings(selection.getAbsolutePath());
    String bookText = join(loadedFile, " ");
    bookText = bookText.replaceAll("[^A-Za-z ]", "");
    bookCount = countLetters(bookText);
    println("Book loaded.");
  }
}


void drawHistogram(int[] counts, float x, float y, float w, float h, color barColor) {


  // Find max for scaling
  int maxVal = 1;
  for (int i = 0; i < 26; i++) {
    if (counts[i] > maxVal) maxVal = counts[i];
  }
  // --- Text Frequency Legend ---
  fill(ColorBook);
  noStroke();
  rect(80, 20, 18, 18);   // small square

  fill(0);
  textAlign(LEFT, CENTER);
  textSize(22);
  text("Text Frequency", 105, 30);


  // --- Secret Frequency Legend ---
  fill(ColorSecret);
  rect(420, 20, 18, 18);   // small square

  fill(0);
  text("Secret Frequency", 445, 30);

  // Chart padding
  float pad = 40;
  float left = x + pad;
  float right = x + w - pad;
  float top = y + pad;
  float bottom = y + h - pad;

  // Bar layout
  float barAreaW = right - left;
  float barW = barAreaW / 26.0;
  float gap = barW * 0.25;           // space between bars
  float actualBarW = barW - gap;

  // Bars (outlined, no With Specific color)
  strokeWeight(4);
  fill(barColor);

  for (int i = 0; i < 26; i++) {
    float barH = map(counts[i], 0, maxVal, 0, bottom - top);
    float bx = left + i * barW + gap/2;
    float by = bottom - barH;
    rect(bx, by, actualBarW, barH);
  }

  // Labels A B C ... Z (simple)
  fill(0);
  noStroke();
  textAlign(CENTER, TOP);
  textSize(17);

  for (int i = 0; i < 26; i++) {               // A-Z
    float cx = left + i * barW + barW/2;
    text(char('A' + i), cx, bottom + 8);
  }

  // Secret (what user typed / ciphertext)
  fill(0);
  textAlign(RIGHT, TOP);
  textSize(23);

  float rightMargin = width - 30;
  float boxWidth = 350;

  text("Secret:", rightMargin, 30);
  text(currentText, rightMargin - boxWidth, 60, boxWidth, 60);

  // Deciphered (decrypted plaintext)
  String decrypted = caesarDecrypt(currentText, guessedShift);

  text("Deciphered:", rightMargin, 140);
  text(decrypted, rightMargin - boxWidth, 170, boxWidth, 120);
}


String caesarDecrypt(String text, int shift) {

  String result = "";

  text = text.toUpperCase();

  for (int i = 0; i < text.length(); i++) {
    char c = text.charAt(i);

    if (c >= 'A' && c <= 'Z') {
      int shifted = (c - 'A' - shift + 26) % 26;
      result += char(shifted + 'A');
    } else {
      result += c;  // keep spaces/punctuation
    }
  }

  return result;
}

void keyTyped() {
  if (screen != PLAY_SCREEN) return;

  // Block control chars
  if (key < 32) return;

  if (Character.isLetter(key) || key == ' ') {
    char upper = Character.toUpperCase(key);

    // Try adding the char
    String candidate = currentText + upper;

    // Only accept if it still fits in the typing box
    if (canAddCharToBox(candidate)) {
      currentText = candidate;
    } else {
      // Optional debug
      // println("Box full, ignoring input");
    }
  }
}

String cleanText(String s) {
  return s.replaceAll("[^A-Za-z ]", "").toUpperCase();
}

String caesarEncrypt(String text, int shift) {
  String result = "";
  text = text.toUpperCase();

  for (int i = 0; i < text.length(); i++) {
    char c = text.charAt(i);

    if (c >= 'A' && c <= 'Z') {
      int shifted = (c - 'A' + shift) % 26;  // <-- forward shift
      result += char(shifted + 'A');
    } else {
      result += c;
    }
  }
  return result;
}
