import 'dart:math';

class WordleGame {
  int rowId = 0;
  int letterId = 0;
  int numColumns; // Variable to store the number of columns

  static String game_message = "";
  static String game_guess = ""; // to be guessed
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
  WordleGame(this.numColumns, String gameWord, int gameType, int tries) {
    // 1 Random, 2 User Input
    print(numColumns);
    print(gameWord);
    print("Game Type: $gameType");
    wordleBoard = List.generate(tries,
        (index) => List.generate(numColumns, ((index) => Letter("", 0))));

    if (gameType == 1) {
      initGame();
    } else {
      game_guess = gameWord;
      print(game_guess);
    }
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
