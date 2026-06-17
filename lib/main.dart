import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const GamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int gridSize = 4;
  late List<List<int>> grid;
  int score = 0;
  bool gameOver = false;
  bool gameWon = false;
  final Random random = Random();

  // 方塊對應顏色
  final Map<int, Color> tileColors = {
    0: const Color(0xFFCDC1B4),
    2: const Color(0xFFEEE4DA),
    4: const Color(0xFFEDE0C8),
    8: const Color(0xFFF2B179),
    16: const Color(0xFFF59563),
    32: const Color(0xFFF67C5F),
    64: const Color(0xFFF65E3B),
    128: const Color(0xFFEDCF72),
    256: const Color(0xFFEDCC61),
    512: const Color(0xFFEDC850),
    1024: const Color(0xFFEDC53F),
    2048: const Color(0xFFEDC22E),
  };

  // 文字顏色
  Color getTextColor(int value) {
    return value <= 4 ? const Color(0xFF776E65) : Colors.white;
  }

  @override
  void initState() {
    super.initState();
    initGame();
  }

  // 初始化遊戲
  void initGame() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    score = 0;
    gameOver = false;
    gameWon = false;
    addRandomTile();
    addRandomTile();
    setState(() {});
  }

  // 隨機生成一個方塊 (90% 機率 2, 10% 機率 4)
  void addRandomTile() {
    List<Point<int>> emptyTiles = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          emptyTiles.add(Point(i, j));
        }
      }
    }
    if (emptyTiles.isEmpty) return;

    Point<int> pos = emptyTiles[random.nextInt(emptyTiles.length)];
    grid[pos.x][pos.y] = random.nextInt(10) == 0 ? 4 : 2;
  }

  // 向左滑動邏輯
  bool moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = grid[i].where((n) => n != 0).toList();
      List<int> newRow = [];
      int j = 0;
      while (j < row.length) {
        if (j + 1 < row.length && row[j] == row[j + 1]) {
          int merged = row[j] * 2;
          newRow.add(merged);
          score += merged;
          if (merged == 2048) gameWon = true;
          j += 2;
        } else {
          newRow.add(row[j]);
          j++;
        }
      }
      while (newRow.length < gridSize) {
        newRow.add(0);
      }
      if (newRow != grid[i]) moved = true;
      grid[i] = newRow;
    }
    return moved;
  }

  // 向右滑動
  bool moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = grid[i].where((n) => n != 0).toList();
      List<int> newRow = [];
      int j = row.length - 1;
      while (j >= 0) {
        if (j - 1 >= 0 && row[j] == row[j - 1]) {
          int merged = row[j] * 2;
          newRow.insert(0, merged);
          score += merged;
          if (merged == 2048) gameWon = true;
          j -= 2;
        } else {
          newRow.insert(0, row[j]);
          j--;
        }
      }
      while (newRow.length < gridSize) {
        newRow.insert(0, 0);
      }
      if (newRow != grid[i]) moved = true;
      grid[i] = newRow;
    }
    return moved;
  }

  // 向上滑動
  bool moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> col = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != 0) col.add(grid[i][j]);
      }
      List<int> newCol = [];
      int i = 0;
      while (i < col.length) {
        if (i + 1 < col.length && col[i] == col[i + 1]) {
          int merged = col[i] * 2;
          newCol.add(merged);
          score += merged;
          if (merged == 2048) gameWon = true;
          i += 2;
        } else {
          newCol.add(col[i]);
          i++;
        }
      }
      while (newCol.length < gridSize) {
        newCol.add(0);
      }
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != newCol[i]) moved = true;
        grid[i][j] = newCol[i];
      }
    }
    return moved;
  }

  // 向下滑動
  bool moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> col = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != 0) col.add(grid[i][j]);
      }
      List<int> newCol = [];
      int i = col.length - 1;
      while (i >= 0) {
        if (i - 1 >= 0 && col[i] == col[i - 1]) {
          int merged = col[i] * 2;
          newCol.insert(0, merged);
          score += merged;
          if (merged == 2048) gameWon = true;
          i -= 2;
        } else {
          newCol.insert(0, col[i]);
          i--;
        }
      }
      while (newCol.length < gridSize) {
        newCol.insert(0, 0);
      }
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != newCol[i]) moved = true;
        grid[i][j] = newCol[i];
      }
    }
    return moved;
  }

  // 檢查遊戲是否結束
  bool checkGameOver() {
    // 還有空格就沒結束
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) return false;
      }
    }
    // 檢查水平相鄰是否可合併
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (grid[i][j] == grid[i][j + 1]) return false;
      }
    }
    // 檢查垂直相鄰是否可合併
    for (int j = 0; j < gridSize; j++) {
      for (int i = 0; i < gridSize - 1; i++) {
        if (grid[i][j] == grid[i + 1][j]) return false;
      }
    }
    return true;
  }

  // 處理滑動
  void handleSwipe(DragEndDetails details) {
    if (gameOver) return;

    double dx = details.velocity.pixelsPerSecond.dx;
    double dy = details.velocity.pixelsPerSecond.dy;
    bool moved = false;

    // 判斷主要滑動方向
    if (dx.abs() > dy.abs()) {
      // 水平滑動
      if (dx > 0) {
        moved = moveRight();
      } else {
        moved = moveLeft();
      }
    } else {
      // 垂直滑動
      if (dy > 0) {
        moved = moveDown();
      } else {
        moved = moveUp();
      }
    }

    if (moved) {
      addRandomTile();
      if (checkGameOver()) {
        gameOver = true;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // 標題與分數 - 縮小字體節省空間
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '2048',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF776E65),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBADA0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            color: Color(0xFFEEE4DA),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 遊戲說明與重新開始按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      '滑動方塊，合併相同數字，達成 2048！',
                      style: TextStyle(
                        color: Color(0xFF776E65),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: initGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F7A66),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('New Game'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 遊戲網格 - 加最大寬度限制，避免寬屏過大溢出
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: GestureDetector(
                      onVerticalDragEnd: handleSwipe,
                      onHorizontalDragEnd: handleSwipe,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBADA0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: gridSize * gridSize,
                            itemBuilder: (context, index) {
                              int row = index ~/ gridSize;
                              int col = index % gridSize;
                              int value = grid[row][col];
                              return _buildTile(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 遊戲結束/獲勝提示
              if (gameOver || gameWon) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gameWon
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gameWon ? '🎉 恭喜！你達成 2048 了！' : '遊戲結束！',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: gameWon ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 建構單個方塊 - 字體對應縮小
  Widget _buildTile(int value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: tileColors[value] ?? const Color(0xFF3C3A32),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          value == 0 ? '' : '$value',
          style: TextStyle(
            fontSize: value >= 1000 ? 20 : value >= 100 ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: getTextColor(value),
          ),
        ),
      ),
    );
  }
}