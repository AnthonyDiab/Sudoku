import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultimate Sudoku',
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
      ),
      home: const SudokuScreen(),
    );
  }
}

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  List<List<int>> board = List.generate(9, (_) => List.generate(9, (_) => 0));
  List<List<int>> solution = List.generate(9, (_) => List.generate(9, (_) => 0));
  List<List<bool>> isOriginal = List.generate(9, (_) => List.generate(9, (_) => false));
  List<List<TextEditingController>> controllers = List.generate(9, (_) => List.generate(9, (_) => TextEditingController()));
  final Random _random = Random();
  String difficulty = 'Medium';

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  int getDifficultyCount() {
    switch (difficulty) {
      case 'Easy':
        return 45; // Show 45 numbers
      case 'Medium':
        return 35; // Show 35 numbers
      case 'Hard':
        return 25; // Show 25 numbers
      default:
        return 35;
    }
  }

  void generatePuzzle() {
    clearBoard();
    generateSolvedBoard();
    for (int i = 0; i < 9; i++) {
      solution[i] = List.from(board[i]);
    }

    int numbersToKeep = getDifficultyCount();
    int totalCells = 81;
    int numbersToRemove = totalCells - numbersToKeep;

    while (numbersToRemove > 0) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);
      if (board[row][col] != 0) {
        board[row][col] = 0;
        numbersToRemove--;
      }
    }

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        controllers[row][col].text = board[row][col] == 0 ? '' : board[row][col].toString();
        isOriginal[row][col] = board[row][col] != 0;
      }
    }
    setState(() {});
  }

  void generateSolvedBoard() {
    clearBoard();
    for (int i = 0; i < 9; i += 3) {
      fillBox(i, i);
    }
    solve(board);
  }

  void fillBox(int row, int col) {
    List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    numbers.shuffle(_random);
    int currentIndex = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[row + i][col + j] = numbers[currentIndex];
        currentIndex++;
      }
    }
  }

  bool isValidMove(int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (x != col && board[row][x] == num) return false;
    }

    for (int x = 0; x < 9; x++) {
      if (x != row && board[x][col] == num) return false;
    }

    int boxRow = row - row % 3;
    int boxCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((boxRow + i != row || boxCol + j != col) && board[boxRow + i][boxCol + j] == num) {
          return false;
        }
      }
    }

    return true;
  }

  void checkSolution() {
    bool isComplete = true;
    bool isCorrect = true;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          isComplete = false;
          break;
        }
        if (board[row][col] != solution[row][col]) {
          isCorrect = false;
          break;
        }
      }
    }

    if (!isComplete) {
      _showErrorDialog("Puzzle is not complete yet!");
    } else if (!isCorrect) {
      _showErrorDialog("Solution is incorrect. Keep trying!");
    } else {
      _showSuccessDialog("Congratulations! You solved the puzzle correctly!");
    }
  }

  void solveSudoku() {
    setState(() {
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (isOriginal[row][col]) {
            continue; // Skip original numbers
          }
          int num = int.tryParse(controllers[row][col].text) ?? 0;
          if (num != 0) {
            board[row][col] = num;
          }
        }
      }
      if (solve(board)) {
        for (int row = 0; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            controllers[row][col].text = board[row][col] == 0 ? '' : board[row][col].toString();
          }
        }
      } else {
        _showErrorDialog("No solution found for the entered numbers.");
      }
    });
  }

  bool solve(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(board, row, col, num)) {
              board[row][col] = num;
              if (solve(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  void clearBoard() {
    setState(() {
      board = List.generate(9, (_) => List.generate(9, (_) => 0));
      solution = List.generate(9, (_) => List.generate(9, (_) => 0));
      isOriginal = List.generate(9, (_) => List.generate(9, (_) => false));
      for (var row in controllers) {
        for (var controller in row) {
          controller.clear();
        }
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          "Ultimate Sudoku",
        
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          )
          
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? const Color.fromARGB(255,53,133,151,) : const Color.fromARGB(255,53,133,151,) ,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode 
              ? [Colors.indigo[900]!, Colors.black]
              : [const Color.fromARGB(255,53,133,151,), const Color.fromARGB(255,53,133,151,)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Difficulty Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.indigo[800] : const Color.fromARGB(106, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Difficulty: ",
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          )
                          
                        ),
                        DropdownButton<String>(
                          value: difficulty,
                          dropdownColor: isDarkMode ? Colors.indigo[800] : Colors.white,
                          items: <String>['Easy', 'Medium', 'Hard']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: GoogleFonts.dmSerifDisplay(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                )
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              difficulty = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Sudoku Grid
                Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.indigo[800] : const Color.fromARGB(121, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(152, 0, 0, 0).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate cell size based on screen width
                        double gridSize = MediaQuery.of(context).size.width < 400 
                            ? MediaQuery.of(context).size.width - 60 // for smaller screens
                            : 320; // maximum grid size
                        double cellSize = gridSize / 9;
                        double fontSize = 12; // Proportional font size

                        return SizedBox(
                          width: gridSize,
                          height: gridSize,
                          child: Column(
                            children: List.generate(9, (row) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(9, (col) {
                                     return Container(
                                            width: cellSize,
                                            height: cellSize,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: (col + 1) % 3 == 0 ? const Color.fromARGB(175, 63, 81, 181) : Colors.grey.withOpacity(0.3),
                                                  width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
                                                ),
                                                bottom: BorderSide(
                                                  color: (row + 1) % 3 == 0 ? const Color.fromARGB(175, 63, 81, 181) : Colors.grey.withOpacity(0.3),
                                                  width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
                                                ),
                                                // Add these new borders
                                                left: BorderSide(
                                                  color: col == 0 ? const Color.fromARGB(175, 63, 81, 181) : Colors.transparent,
                                                  width: col == 0 ? 2.0 : 0.0,
                                                ),
                                                top: BorderSide(
                                                  color: row == 0 ? const Color.fromARGB(175, 63, 81, 181) : Colors.transparent,
                                                  width: row == 0 ? 2.0 : 0.0,
                                                ),
                                              ),
                                              color: isOriginal[row][col]
                                                ? (isDarkMode ? const Color.fromARGB(58, 63, 81, 181) : Colors.indigo[50])
                                                : (isDarkMode ? const Color.fromARGB(91, 63, 81, 181) : const Color.fromARGB(129, 255, 255, 255)),
                                            ),
                                    child: Center(
                                      child: Container(
                                        width: cellSize * 0.9, // Slightly smaller than the cell
                                        height: cellSize * 0.9,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(cellSize * 0.2),
                                          color: isOriginal[row][col]
                                              ? (isDarkMode ? const Color.fromARGB(58, 63, 81, 181) : const Color.fromARGB(0, 79, 83, 104))
                                              : Colors.transparent,
                                        ),
                                        child: Center(
                                          child: TextField(
                                            controller: controllers[row][col],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: isOriginal[row][col] ? FontWeight.bold : FontWeight.normal,
                                              color: isDarkMode ? Colors.white : Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              isCollapsed: true,
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                              // Add subtle background effect for better visibility
                                              filled: !isOriginal[row][col],
                                              fillColor: isDarkMode 
                                                  ? Colors.white.withOpacity(0.05)
                                                  : Colors.black.withOpacity(0.02),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(1),
                                              FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
                                            ],
                                            enabled: !isOriginal[row][col],
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                int num = int.parse(value);
                                                if (!isValidMove(row, col, num)) {
                                                  _showErrorDialog("Invalid move! This number already exists in the same row, column, or 3x3 box.");
                                                  controllers[row][col].clear();
                                                  setState(() {
                                                    board[row][col] = 0;
                                                  });
                                                } else {
                                                  setState(() {
                                                    board[row][col] = num;
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  board[row][col] = 0;
                                               });
                                        }
                                      },
                                    ),
                                  ),
                                      ),
                                    ),
                                     );
                                }),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 30),
                  
                  // Control Buttons
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildButton(
                        onPressed: generatePuzzle,
                        icon: Icons.refresh,
                        label: "New Puzzle",
                        color: const Color.fromARGB(255, 244, 168, 150),
                        isDarkMode: isDarkMode,
                      ),
                      _buildButton(
                        onPressed: checkSolution,
                        icon: Icons.check_circle,
                        label: "Check",
                        color:  const Color.fromARGB(255, 244, 168, 150),
                        isDarkMode: isDarkMode,
                      ),
                      _buildButton(
                        onPressed: solveSudoku,
                        icon: Icons.lightbulb,
                        label: "Solve",
                        color:  const Color.fromARGB(255, 244, 168, 150),
                        isDarkMode: isDarkMode,
                      ),
                      _buildButton(
                        onPressed: clearBoard,
                        icon: Icons.delete_sweep,
                        label: "Clear",
                        color:  const Color.fromARGB(255, 244, 168, 150),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? color.withOpacity(0.8) : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}