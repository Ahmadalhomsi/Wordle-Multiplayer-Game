import 'dart:math';

class WordleGame {
  int rowId = 0;
  int letterId = 0;
  int numColumns; // Variable to store the number of columns

  static String game_message = "";
  static String game_guess = "";
  static List<String> word_list = [
    "WORLD",
    "FIGHT",
    "BRAIN",
    "PLANE",
    "EARTH",
    "ROBOT"
  ];

  static bool gameOver = false;

  // Extra
  static String wordToSend = ""; // to send it to the competetor

// Game row
  static List<Letter> wordleRow = List.generate(5, (index) => Letter("", 0));

// Game board
  late List<List<Letter>> wordleBoard;

  // Constructor
  WordleGame(this.numColumns) {
    print(numColumns);
    wordleBoard = List.generate(
        5, (index) => List.generate(numColumns, ((index) => Letter("", 0))));
    initGame();
  }

// The game basics function
  static void initGame() {
    final random = Random();
    int index = random.nextInt(word_list.length);
    game_guess = word_list[index];
    print(game_guess);
  }

// Game insertion
  void insertWord(index, word) {
    wordleBoard[rowId][index] = word;
  }

  bool checkWordExist(String word) {
    return game_guess.contains(word);
  }
}

class Letter {
  String? letter;
  int code = 0;
  Letter(this.letter, this.code);
}
