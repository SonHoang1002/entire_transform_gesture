import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

enum _FlipAxisMode { image, screen }

class DemoFlipRotateRect extends StatefulWidget {
  const DemoFlipRotateRect({super.key});

  @override
  State<DemoFlipRotateRect> createState() => _DemoFlipRotateRectState();
}

class _DemoFlipRotateRectState extends State<DemoFlipRotateRect> {
  String assetPath = "asset/preview.jpg";
  bool isLoading = true;

  late Rect mainRect;
  Matrix4Transform matrix4transform = Matrix4Transform();
  _FlipAxisMode _flipAxisMode = _FlipAxisMode.image;

  // start property
  Rect _startRect = Rect.zero;
  Offset _startOffset = Offset.zero;
  Matrix4Transform _startMatrix4transform = Matrix4Transform();

  Size get screenSize => MediaQuery.sizeOf(context);
  Size get getSizeMediaTool => const Size(255, 48);
  Rect get surroundingRect {
    Size surroundingSize = MatrixUtils.transformRect(
      matrix4transform.m,
      mainRect,
    ).size;
    return Rect.fromCenter(
      center: mainRect.center,
      width: surroundingSize.width,
      height: surroundingSize.height,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        mainRect = Rect.fromCenter(
          center: Offset(screenSize.width / 2, screenSize.height / 2),
          width: screenSize.width * 2 / 3,
          height: screenSize.width * 2 / 3 / 1800 * 1075,
        );
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: isLoading
            ? CircularProgressIndicator(color: Colors.blue)
            : SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fromRect(
                      rect: surroundingRect,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: mainRect,
                      child: Transform(
                        key: const ValueKey('image-transform'),
                        transform: matrix4transform.matrix4,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          onScaleEnd: _onScaleEnd,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(70),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            width: mainRect.width,
                            height: mainRect.height,
                            child: Image.asset(assetPath, fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                    // Positioned.fromRect(
                    //   rect: mainRect,
                    //   child: Center(
                    //     child: Container(
                    //       width: 50,
                    //       height: 50,
                    //       alignment: Alignment.center,
                    //       color: Colors.blue,
                    //       child: Text(
                    //         matrix4transform.m.getDoubleRotationByDegrees,
                    //         style: TextStyle(color: Colors.red, fontSize: 20),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // _buildImageToolBottomMedia(),
                    _buildSnapScrollList(),
                    _buildFlipControls(),
                  ],
                ),
              ),
      ),
    );
  }

  // Widget _buildImageToolBottomMedia() {
  //   double left = surroundingRect.center.dx - getSizeMediaTool.width / 2;
  //   double top = surroundingRect.bottom + getSizeMediaTool.height;
  //   return Positioned(
  //     left: left,
  //     top: top,
  //     child: SizedBox(
  //       width: getSizeMediaTool.width,
  //       height: getSizeMediaTool.height,
  //       child: WEdit1.buildBottomImageTool(
  //         context: context,
  //         onSelected: _onSelectedImageTool,
  //         // currentDrawContainer: getCurrentDrawContainer,
  //         isMediaText: false,
  //       ),
  //     ),
  //   );
  // }

  int _indexSelected = 0;
  final List<GlobalKey> _itemKeys = List.generate(1000, (index) => GlobalKey());
  final ScrollController _scrollController = ScrollController();

  Widget _buildSnapScrollList() {
    return Positioned(
      bottom: 112,
      child: Container(
        height: 50,
        width: MediaQuery.sizeOf(context).width,
        alignment: Alignment.bottomCenter,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 1000,
          itemBuilder: (context, item) {
            return GestureDetector(
              onTap: () {
                Scrollable.ensureVisible(
                  _itemKeys[item].currentContext!,
                  duration: const Duration(milliseconds: 500),
                  alignment: 0.5,
                );
                _indexSelected = item;
                setState(() {});
              },
              child: Container(
                key: _itemKeys[item],
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: _indexSelected == item ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(999),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Center(
                  child: Text(
                    item.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlipControls() {
    return Positioned(
      bottom: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<_FlipAxisMode>(
            key: const ValueKey('flip-axis-mode'),
            segments: const [
              ButtonSegment(
                value: _FlipAxisMode.image,
                label: Text('Theo ảnh'),
              ),
              ButtonSegment(
                value: _FlipAxisMode.screen,
                label: Text('Theo màn hình'),
              ),
            ],
            selected: {_flipAxisMode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() => _flipAxisMode = selection.first);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _onSelectedImageTool(0),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Lật ngang'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _onSelectedImageTool(1),
                icon: const Icon(Icons.swap_vert),
                label: const Text('Lật dọc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool isFlipHorizontal = false, isFlipVertical = false;
  void _onSelectedImageTool(int index) {
    switch (index) {
      case 0:
        matrix4transform = _flipAxisMode == _FlipAxisMode.image
            ? matrix4transform.scaleBy(x: -1)
            : _flipAroundScreenAxis(horizontal: true);
        isFlipHorizontal = !isFlipHorizontal;
        break;
      case 1:
        matrix4transform = _flipAxisMode == _FlipAxisMode.image
            ? matrix4transform.scaleBy(y: -1)
            : _flipAroundScreenAxis(horizontal: false);
        isFlipVertical = !isFlipVertical;
        break;
      case 2:
        double targetDegree = -90;
        if ((isFlipVertical && !isFlipHorizontal) ||
            (!isFlipVertical && isFlipHorizontal)) {
          targetDegree = 90;
        }
        matrix4transform = matrix4transform.rotateDegrees(targetDegree);
        break;
      case 3:
        double targetDegree = 90;
        if ((isFlipVertical && !isFlipHorizontal) ||
            (!isFlipVertical && isFlipHorizontal)) {
          targetDegree = -90;
        }
        matrix4transform = matrix4transform.rotateDegrees(targetDegree);
        break;
      default:
        return;
    }
    setState(() {});
  }

  Matrix4Transform _flipAroundScreenAxis({required bool horizontal}) {
    final reflection = Matrix4Transform().scaleBy(
      x: horizontal ? -1 : 1,
      y: horizontal ? 1 : -1,
    );
    return Matrix4Transform.from(
      reflection.m..multiply(matrix4transform.m),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startOffset = details.focalPoint;
    _startRect = mainRect;
    _startMatrix4transform = matrix4transform;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    Offset delta = details.focalPoint - _startOffset;

    if (details.pointerCount == 1) {
      mainRect = _startRect.shift(delta);
    } else if (details.pointerCount == 2) {
      Rect targetRectImage;

      Size targetSize = _startRect.size * details.scale;

      // Vector từ start offset đến center ban đầu
      Offset vectorStartCenterAndStartOffset = _startRect.center - _startOffset;

      // Scale vector từ start offset
      Offset scaleVector = vectorStartCenterAndStartOffset * details.scale;

      // Tính center mới sau scale (giữ nguyên start offset làm tâm scale)
      Offset targetCenter = scaleVector + _startOffset;

      // Tạo rect mới sau scale
      targetRectImage = Rect.fromCenter(
        center: targetCenter,
        width: targetSize.width,
        height: targetSize.height,
      );

      // XOAY: Lấy start offset làm điểm gốc để xoay
      if (details.rotation != 0) {
        // Vector từ start offset đến center mới (sau scale)
        Offset rotationVector = targetCenter - _startOffset;

        // Xoay vector này quanh start offset
        Offset rotatedVector = Offset(
          rotationVector.dx * cos(details.rotation) -
              rotationVector.dy * sin(details.rotation),
          rotationVector.dx * sin(details.rotation) +
              rotationVector.dy * cos(details.rotation),
        );

        // Tính center mới sau khi xoay
        Offset rotatedCenter = _startOffset + rotatedVector;

        // Cập nhật rect với center đã xoay
        targetRectImage = Rect.fromCenter(
          center: rotatedCenter,
          width: targetSize.width,
          height: targetSize.height,
        );
      }
      mainRect = targetRectImage.shift(delta);
      double targetRotation = details.rotation;
      if ((isFlipHorizontal && !isFlipVertical) ||
          (!isFlipHorizontal && isFlipVertical)) {
        targetRotation = -targetRotation;
      }
      matrix4transform = _startMatrix4transform.rotate(targetRotation);
    } else {
      // nothing
    }
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) {
    debugPrint("ScaleEnd: velocity: ${details.velocity}");
  }
}
