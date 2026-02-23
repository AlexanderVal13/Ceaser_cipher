float fileBtnW = 180;
float fileBtnH = 60;
float fileBtnX;
float fileBtnY;
String[] userFileLines;

float boxX = 20;
float boxY;
float boxW = 400;
float boxH = 200;

// --- English reference model (percent-ish) ---
final float[] ENGLISH_FREQ = {
  8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0,
  6.1, 7.0, 0.15, 0.8, 4.0, 2.4,
  6.7, 7.5, 1.9, 0.1, 6.0,
  6.3, 9.1, 2.8, 1.0, 2.4,
  0.15, 2.0, 0.07
};

int[] englishModelCount = new int[26]; // will hold a fake "bookCount" if no file loaded

// =====================================================
// LIMIT INPUT TO WHAT FITS IN THE TEXT BOX
// =====================================================
boolean canAddCharToBox(String newText) {
  // MUST match how you draw text inside the box
  textSize(3);
  float leading = textAscent() + textDescent() + 6;
  textLeading(leading);

  float innerW = boxW - 20;
  float innerH = boxH - 20;

  String clipped = clipToBoxCharWrap(newText, innerW, innerH, leading);
  return clipped.length() == newText.length();
}

String clipToBoxCharWrap(String s, float maxW, float maxH, float leading) {
  String out = "";
  float x = 0;
  float y = 0;

  for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);

    if (c == '\n') {
      x = 0;
      y += leading;
      if (y + leading > maxH) break;
      out += c;
      continue;
    }

    float cw = textWidth(str(c));

    if (x + cw > maxW) {
      x = 0;
      y += leading;
      if (y + leading > maxH) break;
      out += '\n';
    }

    out += c;
    x += cw;
  }

  return out;
}

void drawHistogramBoth(int[] book, int[] secret, float x, float y, float w, float h) {



  // totals
  float bookTotal = 0;
  float secretTotal = 0;
  for (int i = 0; i < 26; i++) {
    bookTotal += book[i];
    secretTotal += secret[i];
  }
  if (bookTotal == 0) bookTotal = 1;
  if (secretTotal == 0) secretTotal = 1;

  float maxBook = 0.001;
  float maxSecret = 0.001;

  for (int i = 0; i < 26; i++) {
    float b = book[i] / bookTotal;
    float s = secret[i] / secretTotal;
    if (b > maxBook) maxBook = b;
    if (s > maxSecret) maxSecret = s;
  }

  // Legends
  fill(ColorBook);
  noStroke();
  rect(80, 20, 18, 18);
  fill(0);
  textAlign(LEFT, CENTER);
  textSize(22);
  text("Text Frequency", 105, 30);

  fill(ColorSecret);
  rect(420, 20, 18, 18);
  fill(0);
  text("Secret Frequency", 445, 30);

  // chart area
  float pad = 40;
  float left = x + pad;
  float right = x + w - pad;
  float top = y + pad;
  float bottom = y + h - pad;

  float barAreaW = right - left;
  float barW = barAreaW / 26.0;
  float gap = barW * 0.25;
  float actualBarW = barW - gap;

  // BOOK bars (percent)
  strokeWeight(4);
  fill(ColorBook);
  // BOOK bars (percent) - use book[] and maxBook
  strokeWeight(4);
  fill(ColorBook);
  for (int i = 0; i < 26; i++) {
    float pct = book[i] / bookTotal;
    float barH = map(pct, 0, maxBook, 0, bottom - top);
    float bx = left + i * barW + gap/2;
    float by = bottom - barH;
    rect(bx, by, actualBarW, barH);
  }

  // SECRET bars (percent) - use secret[] and maxSecret
  float secretW = actualBarW * 0.55;
  fill(ColorSecret);
  for (int i = 0; i < 26; i++) {
    float pct = secret[i] / secretTotal;
    float barH = map(pct, 0, maxSecret, 0, bottom - top);
    float bx = left + i * barW + gap/2 + (actualBarW - secretW)/2;
    float by = bottom - barH;
    rect(bx, by, secretW, barH);
  }

  // A-Z labels
  fill(0);
  noStroke();
  textAlign(CENTER, TOP);
  textSize(17);
  for (int i = 0; i < 26; i++) {
    float cx = left + i * barW + barW/2;
    text(char('A' + i), cx, bottom + 8);
  }
}

// =====================================================
// PLAY SCREEN
// =====================================================
class Play {

  void display() {

    // -------- TYPING SCREEN --------
    if (showFreq == 0) {
      background(0);

      // File button
      fill(75, 140, 220);
      noStroke();
      rect(fileBtnX, fileBtnY, fileBtnW, fileBtnH, 10);

      fill(255);
      textAlign(CENTER, CENTER);
      textSize(22);
      text("Load TXT File", fileBtnX + fileBtnW/2, fileBtnY + fileBtnH/2);

      // Text input box
      boxX = width - boxW - 20;
      boxY = height - boxH - 20;
      fill(40);
      stroke(200);
      rect(boxX, boxY, boxW, boxH, 8);

      // Text inside box
      fill(255);
      textSize(20);
      textAlign(LEFT, TOP);
      text(currentText, boxX + 10, boxY + 10, boxW - 20, boxH - 20);

      // Cursor (simple)
      if (typing && frameCount % 60 < 30) {
        float lineHeight = textAscent() + textDescent();
        String[] lines = split(currentText, "\n");
        if (lines.length == 0) lines = new String[] { "" };

        float cursorY = boxY + 10 + (lines.length - 1) * lineHeight;
        float cursorX = boxX + 10 + textWidth(lines[lines.length - 1]);

        stroke(255);
        line(cursorX, cursorY, cursorX, cursorY + lineHeight);
      }

      // Shift buttons
      fill(200);
      noStroke();
      rect(shiftMinusX, shiftMinusY, shiftW, shiftH);
      rect(shiftPlusX, shiftPlusY, shiftW, shiftH);

      fill(0);
      textAlign(CENTER, CENTER);
      textSize(40);
      text("-", shiftMinusX + shiftW/2, shiftMinusY + shiftH/2);
      text("+", shiftPlusX + shiftW/2, shiftPlusY + shiftH/2);

      fill(160);
      textSize(40);
      textAlign(LEFT, TOP);
      text("Shift: " + guessedShift, width - 240, 250);

      // Live encrypted preview
      float previewX = 30;
      float previewY = 20;
      float previewW = width - 60;
      float previewH = 120;

      noStroke();
      fill(0, 160);
      rect(previewX - 10, previewY - 10, previewW + 20, previewH + 20, 8);

      fill(255);
      textAlign(LEFT, TOP);
      textSize(20);
      float leading = textAscent() + textDescent() + 6;
      textLeading(leading);

      String label = "Encrypted (shift " + guessedShift + "):";
      String liveEncrypted = caesarEncrypt(currentText, guessedShift);

      text(label, previewX, previewY);

      float remainingH = previewH - leading;
      if (remainingH < leading) remainingH = leading;

      String clipped = clipToBoxCharWrap(liveEncrypted, previewW, remainingH, leading);
      text(clipped, previewX, previewY + leading, previewW, remainingH);

      return;
    }

    // -------- HISTOGRAM SCREEN --------
    background(255);

    // draw combined histogram (yellow = TXT file OR English model if no file)
    drawHistogramBoth(getReferenceCounts(), secretCount, 60, 60, 580, 580);

    // compute guesses
    int autoGuess = guessShiftFromFrequency(secretCount);
    int bookTotal = 0;
    for (int i = 0; i < 26; i++) {
      bookTotal += bookCount[i];
    }

    int autoGuess2;

    if (bookTotal == 0) {
      // No book loaded -> fallback to English
      autoGuess2 = guessShiftFromFrequency(secretCount);
    } else {
      // Book loaded -> use book model
      autoGuess2 = guessShiftUsingBook(secretCount, bookCount);
    }

    // show text on right
    // show text on right (STACKED WITH SPACING)
    fill(0);
    textAlign(RIGHT, TOP);
    textSize(23);

    float rightMargin = width - 30;
    float boxWidth    = 350;

    float yCursor = 30;       // start top of right column
    float gap     = 18;       // space between sections

    // Make consistent text wrapping look nicer
    float leading = textAscent() + textDescent() + 6;
    textLeading(leading);

    // ----- SECRET -----
    text("Secret:", rightMargin, yCursor);
    yCursor += 30;

    float secretH = 130;
    text(currentText, rightMargin - boxWidth, yCursor, boxWidth, secretH);
    yCursor += secretH + gap;

    // ----- MANUAL DECRYPT (guessedShift) -----
    text("Deciphered:", rightMargin, yCursor);
    yCursor += 30;

    float manualH = 150;
    text(caesarDecrypt(currentText, guessedShift),
      rightMargin - boxWidth, yCursor, boxWidth, manualH);
    yCursor += manualH + gap;

    // ----- ENGLISH MODEL GUESS -----
    textSize(22);
    text("English Frequency Guess Shift: " + autoGuess, rightMargin, yCursor);
    yCursor += 30;

    text("Decrypted (English Model):", rightMargin, yCursor);
    yCursor += 30;

    float engH = 140;
    text(caesarDecrypt(currentText, autoGuess),
      rightMargin - boxWidth, yCursor, boxWidth, engH);
    yCursor += engH + gap;

    // ----- TXT FILE MODEL (OR DEFAULT MESSAGE) -----
    if (bookTotal == 0) {
      text("No text file loaded.", rightMargin, yCursor);
      yCursor += 30;
      text("Using default English frequency model.", rightMargin, yCursor);
    } else {
      text("Text File Frequency Guess Shift: " + autoGuess2, rightMargin, yCursor);
      yCursor += 30;

      text("Decrypted (Text File Model):", rightMargin, yCursor);
      yCursor += 30;

      float bookH = 140;
      text(caesarDecrypt(currentText, autoGuess2),
        rightMargin - boxWidth, yCursor, boxWidth, bookH);
    }
  }
}

// =====================================================
// GUESS FUNCTIONS
// =====================================================
int guessShiftFromFrequency(int[] secretCounts) {

  float[] englishFreq = {
    8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0,
    6.1, 7.0, 0.15, 0.8, 4.0, 2.4,
    6.7, 7.5, 1.9, 0.1, 6.0,
    6.3, 9.1, 2.8, 1.0, 2.4,
    0.15, 2.0, 0.07
  };

  int bestShift = 0;
  float bestScore = Float.MAX_VALUE;

  for (int shift = 0; shift < 26; shift++) {
    float score = 0;

    for (int i = 0; i < 26; i++) {
      int shiftedIndex = (i + shift) % 26;

      float observed = secretCounts[shiftedIndex];
      float expected = englishFreq[i];

      score += abs(observed - expected);
    }

    if (score < bestScore) {
      bestScore = score;
      bestShift = shift;
    }
  }

  return bestShift;
}

int guessShiftUsingBook(int[] secretCounts, int[] bookCounts) {

  float secretTotal = 0;
  float bookTotal = 0;
  for (int i = 0; i < 26; i++) {
    secretTotal += secretCounts[i];
    bookTotal += bookCounts[i];
  }
  if (secretTotal == 0 || bookTotal == 0) return 0;

  int bestShift = 0;
  float bestScore = Float.MAX_VALUE;

  for (int shift = 0; shift < 26; shift++) {
    float score = 0;

    for (int i = 0; i < 26; i++) {
      int shiftedIndex = (i + shift) % 26;

      float observed = secretCounts[shiftedIndex] / secretTotal;
      float expected = bookCounts[i] / bookTotal;

      score += abs(observed - expected);
    }

    if (score < bestScore) {
      bestScore = score;
      bestShift = shift;
    }
  }

  return bestShift;
}


int totalCountCeaser(int[] arr) {
  int t = 0;
  for (int i = 0; i < arr.length; i++) t += arr[i];
  return t;
}

// Build a "counts" array from the English frequency model
int[] buildEnglishModelCounts(int scale) {
  int[] counts = new int[26];
  for (int i = 0; i < 26; i++) {
    counts[i] = max(1, round(ENGLISH_FREQ[i] * scale));  // keep >0 so bars show
  }
  return counts;
}

// TXT file counts if loaded, otherwise English model
int[] getReferenceCounts() {
  return (totalCountCeaser(bookCount) > 0) ? bookCount : englishModelCount;
}
