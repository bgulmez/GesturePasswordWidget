import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gesture_password_widget/model/point_item.dart';
import 'package:gesture_password_widget/widget/line_painter.dart';

/// Callback function when a point is selected
typedef OnHitPoint = void Function();

/// Callback function when gesture sliding ends
/// [result] The result set of all selected points
typedef OnComplete = void Function(List<int?> result);

typedef OnCancel = void Function();

/// A highly customizable gesture password widget that meets most daily needs
///
/// [简体中文](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/README-CN.md)
/// [English](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/README.md) <br>
///
/// Demo:
/// ```dart
/// GesturePasswordWidget(
///      lineColor: Colors.white,
///      errorLineColor: Colors.redAccent,
///      singleLineCount: 3,
///      identifySize: 80.0,
///      minLength: 4,
///      hitShowMilliseconds: 40,
///      errorItem: Container(
///        width: 10.0,
///        height: 10.0,
///        decoration: BoxDecoration(
///          color: Colors.redAccent,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      normalItem: Container(
///        width: 10.0,
///        height: 10.0,
///        decoration: BoxDecoration(
///          color: Colors.white,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      selectedItem: Container(
///        width: 10.0,
///        height: 10.0,
///        decoration: BoxDecoration(
///          color: Colors.white,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      hitItem: Container(
///        width: 15.0,
///        height: 15.0,
///        decoration: BoxDecoration(
///          color: Colors.white,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      arrowItem: Image.asset(
///         'images/arrow.png',
///         width: 20.0,
///         height: 20.0,
///         color: const Color(0xff0C6BFE),
///         fit: BoxFit.fill,
///      ),
///      errorArrowItem: Image.asset(
///         'images/arrow.png',
///         width: 20.0,
///         height: 20.0,
///         fit: BoxFit.fill,
///         color: const Color(0xffFB2E4E),
///      ),
///      answer: [0, 1, 2, 4, 7],
///      color: Color(0xff252534),
///      onComplete: (data) {
///        setState(() {
///          result = data.join(', ');
///        });
///      },
/// )
/// ```
///
class GesturePasswordWidget extends StatefulWidget with DiagnosticableTreeMixin {
  /// The width and height of GesturePasswordWidget.
  final double size;

  /// The area size used to determine whether a point is selected. The larger the value, the more accurate the recognition.
  final double identifySize;

  /// The widget displayed in the normal state.
  final Widget? normalItem;

  /// The widget displayed in the selected state.
  final Widget? selectedItem;

  /// The widget displayed in the error state. Only takes effect when [minLength] or [answer] is set.
  /// 1) When [minLength] is not null, if the number of selected points is less than minLength, [errorItem] is displayed.
  /// For example, if minLength = 4, but the result set is [0,1,3] with only 3 points selected, which is less than 4.
  /// 2) When [answer] is not null, if the result set does not match [answer], [errorItem] is displayed.
  /// For example, if answer = [0,1,2,4,7], but the result set is [0,1,2,5,8], which does not match answer.
  /// The display duration of [errorItem] is controlled by [completeWaitMilliseconds].
  final Widget? errorItem;

  /// The widget displayed when this point is selected. Its display duration is controlled by [hitShowMilliseconds].
  /// After the display duration, it continues to show [selectedItem].
  final Widget? hitItem;

  /// The arrow widget displayed in the normal state.
  /// When rotating with the gesture, the positive x-axis direction is 0 degrees, so if you use an arrow, make sure it points in the positive x-axis direction.
  final Widget? arrowItem;

  /// The arrow widget displayed in the error state. If [errorArrowItem] is set, [arrowItem] must also be set,
  /// otherwise [errorArrowItem] will not be displayed.
  /// When rotating with the gesture, the positive x-axis direction is 0 degrees, so if you use an arrow, make sure it points in the positive x-axis direction.
  final Widget? errorArrowItem;

  /// The x-axis offset of [arrowItem] and [errorArrowItem], with the origin at the center of [normalItem].
  /// When -1 < [arrowXAlign] < 1, [arrowItem] and [errorArrowItem] are drawn within the [normalItem] bounds.
  /// When [arrowXAlign] > 1 or [arrowXAlign] < -1, they are drawn outside the [normalItem] bounds.
  final double arrowXAlign;

  /// The y-axis offset of [arrowItem] and [errorArrowItem], with the origin at the center of [normalItem].
  /// When -1 < [arrowYAlign] < 1, [arrowItem] and [errorArrowItem] are drawn within the [normalItem] bounds.
  /// When [arrowYAlign] > 1 or [arrowYAlign] < -1, they are drawn outside the [normalItem] bounds.
  final double arrowYAlign;

  /// Number of points per row. The total count equals singleLineCount * singleLineCount.
  final int singleLineCount;

  /// Background color of GesturePasswordWidget. Defaults to [Theme.of].[scaffoldBackgroundColor].
  final Color? color;

  /// Callback function when a point is selected.
  final OnHitPoint? onHitPoint;

  /// Callback function when gesture sliding ends.
  final OnComplete? onComplete;

  /// The color of the line.
  final Color lineColor;

  /// The color of the line in error scenarios. See [errorItem].
  final Color errorLineColor;

  /// The width of the line.
  final double lineWidth;

  /// Whether to use the loose strategy. Defaults to true.
  /// Consider this case: the first selected point has index = 0, and the second has index = 6.
  /// At this time, points with index = 0, index = 3, and index = 6 are on the same line.
  /// If loose is true, the output is [0, 3, 6].
  /// If loose is false, the output is [0, 6].
  final bool loose;

  /// The correct answer. Example: [0, 1, 2, 4, 7]
  final List<int>? answer;

  /// The duration that all selected points and drawn lines are displayed on screen after completion.
  /// After the time expires, all points are cleared and reset to the initial state.
  /// Before the time expires, GesturePasswordWidget will not accept any gesture events.
  final int completeWaitMilliseconds;

  /// See [hitItem].
  final int hitShowMilliseconds;

  /// If this value is set, [errorItem] and [errorLineColor] are shown when the selected length is insufficient.
  final int? minLength;

  ///Used to cancel the drawn pattern
  final Widget? cancelButton;

  ///The size of the area used to judge whether the cancel point is selected, the larger the value, the more accurate the recognition.
  final double cancelIdentifySize;

  ///Callback function when the cancelled
  final OnCancel? onCancel;

  final VoidCallback? onPointChange;

  /// Space value between PasswordWidget and CancelButton
  final double? cancelButtonSpace;

  /// CancelButton height area
  final double? cancelButtonHeight;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
    properties.add(DoubleProperty('identifySize', identifySize));
    properties.add(DiagnosticsProperty<Widget>('normalItem', normalItem));
    properties.add(DiagnosticsProperty<Widget>('selectedItem', selectedItem));
    properties.add(DiagnosticsProperty<Widget>('errorItem', errorItem));
    properties.add(DiagnosticsProperty<Widget>('hitItem', hitItem));
    properties.add(DiagnosticsProperty<Widget>('arrowItem', arrowItem));
    properties.add(DiagnosticsProperty<Widget>('errorArrowItem', errorArrowItem));
    properties.add(DoubleProperty('arrowXAlign', arrowXAlign));
    properties.add(DoubleProperty('arrowYAlign', arrowYAlign));
    properties.add(IntProperty('singleLineCount', singleLineCount));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<OnHitPoint>('onHitPoint', onHitPoint));
    properties.add(DiagnosticsProperty<OnComplete>('onComplete', onComplete));
    properties.add(ColorProperty('lineColor', lineColor));
    properties.add(ColorProperty('errorLineColor', errorLineColor));
    properties.add(IterableProperty('answer', answer));
    properties.add(DoubleProperty('lineWidth', lineWidth));
    properties.add(FlagProperty('loose', value: loose, ifFalse: 'loose: false', ifTrue: 'loose: true', defaultValue: true));
    properties.add(IntProperty('completeWaitMilliseconds', completeWaitMilliseconds));
    properties.add(IntProperty('hitShowMilliseconds', hitShowMilliseconds));
    properties.add(IntProperty('minLength', minLength));
  }

  GesturePasswordWidget({
    this.size = 300.0,
    this.identifySize = 50.0,
    this.normalItem,
    this.selectedItem,
    this.errorItem,
    this.hitItem,
    this.arrowItem,
    this.errorArrowItem,
    this.arrowXAlign = 0.6,
    this.arrowYAlign = 0.0,
    this.singleLineCount = 3,
    this.color,
    this.onHitPoint,
    this.onComplete,
    this.onCancel,
    this.lineColor = Colors.green,
    this.errorLineColor = Colors.redAccent,
    this.lineWidth = 2.0,
    this.answer,
    this.loose = true,
    this.completeWaitMilliseconds = 300,
    this.hitShowMilliseconds = 40,
    this.minLength,
    this.cancelIdentifySize = 50.0,
    this.cancelButton,
    this.onPointChange,
    this.cancelButtonSpace = 30,
    this.cancelButtonHeight = 70,
  }) : assert(singleLineCount > 1, 'singLineCount must not be smaller than 1'),
       assert(identifySize > 0),
       assert(size > identifySize),
       assert(!(errorArrowItem != null && arrowItem == null), 'when arrowItem == null, errorArrowItem will not be shown.');

  @override
  _GesturePasswordWidgetState createState() => _GesturePasswordWidgetState();
}

class _GesturePasswordWidgetState extends State<GesturePasswordWidget> {
  late Point origin;
  late int totalCount;
  Point<double>? lastPoint;
  Point<double>? lastDragPoint;
  Widget? normalItem;
  Widget? defaultNormalItem;
  Widget? selectedItem;
  Widget? defaultSelectedItem;
  Widget? errorItem;
  Widget? defaultErrorItem;
  Color? lineColor;
  bool ignoring = false;
  final points = <PointItem>[];
  final linePoints = <Point<double>>[];
  final result = <int?>[];
  final double defaultSize = 10.0;
  late PointItem cancelPoint;
  bool cancelButtonVisibility = false;

  @override
  void initState() {
    super.initState();
    defaultNormalItem = Container(
      width: defaultSize,
      height: defaultSize,
      decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(50.0)),
    );
    defaultSelectedItem = Container(
      width: defaultSize,
      height: defaultSize,
      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(50.0)),
    );
    defaultErrorItem = Container(
      width: defaultSize,
      height: defaultSize,
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(50.0)),
    );

    lineColor = widget.lineColor;
    normalItem = widget.normalItem ?? defaultNormalItem;
    selectedItem = widget.selectedItem ?? defaultSelectedItem;
    errorItem = widget.errorItem ?? defaultErrorItem;

    cancelPoint = PointItem(x: widget.size * 0.5, y: widget.size + 50, isSelected: false);

    totalCount = widget.singleLineCount * widget.singleLineCount;
    origin = Point<double>(widget.size * 0.5, widget.size * 0.5);
    calculatePointPosition();
  }

  @override
  void didUpdateWidget(GesturePasswordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lineColor != oldWidget.lineColor) {
      lineColor = widget.lineColor;
    }

    if (widget.normalItem != oldWidget.normalItem) {
      normalItem = widget.normalItem ?? defaultNormalItem;
    }

    if (widget.selectedItem != oldWidget.selectedItem) {
      selectedItem = widget.selectedItem ?? defaultSelectedItem;
    }

    if (widget.errorItem != oldWidget.errorItem) {
      errorItem = widget.errorItem ?? defaultErrorItem;
    }

    if (widget.singleLineCount != oldWidget.singleLineCount ||
        widget.size != oldWidget.size ||
        widget.identifySize != oldWidget.identifySize) {
      totalCount = widget.singleLineCount * widget.singleLineCount;
      origin = Point<double>(widget.size * 0.5, widget.size * 0.5);
      points.clear();
      calculatePointPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignoring,
      child: widget.cancelButton != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildGesturePasswordWidget(),
                SizedBox(height: widget.cancelButtonSpace),
                Container(
                  height: widget.cancelButtonHeight,
                  child: Visibility(child: widget.cancelButton!, visible: cancelButtonVisibility),
                ),
              ],
            )
          : buildGesturePasswordWidget(),
    );
  }

  Widget buildGesturePasswordWidget() {
    return Container(
      alignment: Alignment.center,
      color: widget.color ?? Theme.of(context).scaffoldBackgroundColor,
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: createPointsWidget()
          ..add(
            GestureDetector(
              onPanDown: handlePanDown,
              onPanUpdate: handlePanUpdate,
              onPanEnd: handPanEnd,
              onPanCancel: () {
                print("onPanCancel ");
                handPanEnd(null);
              },
              child: CustomPaint(
                painter: LinePainter(points: linePoints, lineColor: lineColor, lineWidth: widget.lineWidth),
                willChange: true,
                size: Size(widget.size, widget.size),
              ),
            ),
          ),
      ),
    );
  }

  // Calculate the position of each point
  void calculatePointPosition() {
    double initX = widget.identifySize * 0.5;
    double initY = widget.identifySize * 0.5;
    double gap = (widget.size - widget.identifySize) / (widget.singleLineCount - 1);

    for (int i = 0; i < totalCount; i++) {
      double centerX = initX + i % widget.singleLineCount * gap;
      double centerY = initY + i ~/ widget.singleLineCount * gap;
      points.add(PointItem(x: centerX, y: centerY, index: i));
    }
  }

  // Create the widget for each point
  List<Widget> createPointsWidget() {
    return points.map<Widget>((p) {
      double reference = 1 - (widget.identifySize / widget.size);
      double x = (p.x - origin.x) / (widget.size * 0.5) / reference;
      double y = (p.y - origin.y) / (widget.size * 0.5) / reference;

      Widget? child = normalItem;
      if (p.isError) {
        child = errorItem;
      } else if (p.isFirstSelected) {
        child = widget.hitItem;
      } else if (p.isSelected) {
        child = selectedItem;
      }

      Widget? arrowItem = widget.arrowItem;
      if (p.isError && widget.errorArrowItem != null) {
        arrowItem = widget.errorArrowItem;
      }

      return Align(
        alignment: Alignment(x, y),
        child: Container(
          color: Colors.transparent,
          width: widget.identifySize,
          height: widget.identifySize,
          alignment: Alignment.center,
          child: widget.arrowItem == null || p.angle == double.infinity
              ? child
              : Transform.rotate(
                  angle: p.angle,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      child!,
                      Align(alignment: Alignment(widget.arrowXAlign, widget.arrowYAlign), child: arrowItem),
                    ],
                  ),
                ),
        ),
      );
    }).toList();
  }

  void handlePanDown(DragDownDetails details) {
    Point<double> curPoint = Point(details.localPosition.dx, details.localPosition.dy);
    final point = calculateHintPoint(curPoint);
    if (point != null) {
      if (!linePoints.contains(Point(point.x, point.y))) {
        addPointToResult(point.index);
        setState(() {
          point.isSelected = true;
          linePoints.add(Point(point.x, point.y));
          cancelButtonVisibility = true;
        });
      }
    }
  }

  void checkCancelPoint(Point<double> curPoint) {
    final point = calculateCancelHintPoint(curPoint);
    if (point != null) {
      cancelPoint.isSelected = true;
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    Point<double> curPoint = Point(details.localPosition.dx, details.localPosition.dy);
    final hitPoint = calculateHintPoint(curPoint);
    if (hitPoint != null) {
      if (!linePoints.contains(Point(hitPoint.x, hitPoint.y))) {
        final drawPoint = Point(hitPoint.x, hitPoint.y);
        // Under the loose strategy, if three points are collinear, automatically set the middle point as selected.
        if (widget.loose && linePoints.isNotEmpty) {
          handleLooseCase(points[result.last!], hitPoint);
        }

        // Handle arrow angle display
        if (widget.arrowItem != null) {
          for (int i = 0; i < result.length - 1; i++) {
            final p1 = math.Point(points[result[i]!].x, points[result[i]!].y);
            final p2 = math.Point(points[result[i + 1]!].x, points[result[i + 1]!].y);

            points[result[i]!].angle = calculateAngle(p1, p2);
          }
        }

        if (result.isNotEmpty) {
          int length = result.length;
          final p1 = Point(points[result[length - 1]!].x, points[result[length - 1]!].y);

          double angle = calculateAngle(p1, math.Point(hitPoint.x, hitPoint.y));
          points[result[length - 1]!].angle = angle;
        }
        addPointToResult(hitPoint.index);
        widget.onPointChange?.call();
        setState(() {
          linePoints.remove(lastPoint);
          hitPoint.isSelected = true;
          linePoints.add(drawPoint);
          cancelButtonVisibility = true;
        });
      }
    } else {
      if (linePoints.isNotEmpty) {
        if (widget.arrowItem != null) {
          int length = result.length;
          final p1 = Point(points[result[length - 1]!].x, points[result[length - 1]!].y);

          double angle = calculateAngle(p1, curPoint);
          points[result[length - 1]!].angle = angle;
        }

        setState(() {
          linePoints.remove(lastPoint);
          linePoints.add(curPoint);
        });
        lastPoint = curPoint;
      }
    }
    lastDragPoint = curPoint;
    checkCancelPoint(curPoint);
  }

  void handPanEnd(DragEndDetails? details) async {
    if (result.isEmpty) {
      return;
    }

    /// When user release finger below the gesture area, cancel process.
    final isBelowGestureArea = lastDragPoint != null && lastDragPoint!.y > widget.size;
    if (isBelowGestureArea) {
    } else {
      widget.onComplete?.call(result);
      if (!mounted) {
        return;
      }

      linePoints.removeLast();

      if ((widget.answer != null && widget.answer!.join() != result.join()) ||
          (widget.minLength != null && widget.minLength! > result.length)) {
        lineColor = widget.errorLineColor;
        for (int i = 0; i < result.length; i++) {
          points[result[i]!].isError = true;
        }
      }

      // Clear the angle of the last point
      points[result.last!].angle = double.infinity;

      if (!mounted) {
        return;
      }

      setState(() {
        ignoring = true;
      });
      await Future.delayed(Duration(milliseconds: widget.completeWaitMilliseconds));
      ignoring = false;
      lineColor = widget.lineColor;

      if (!mounted) {
        return;
      }
    }

    setState(() {
      points.forEach((p) {
        p.isSelected = false;
        p.isError = false;
        p.angle = double.infinity;
      });
      linePoints.clear();
      result.clear();
      cancelPoint.isSelected = false;
      cancelButtonVisibility = false;
      lastDragPoint = null;
    });
  }

  // Calculate the hit point
  PointItem? calculateHintPoint(Point<double> curPoint) {
    for (int i = 0; i < points.length; i++) {
      final p = Point(points[i].x, points[i].y);
      if (p.distanceTo(curPoint) + 0.5 < widget.identifySize * 0.5) {
        if (points[i].isSelected) {
          return null;
        }
        return points[i];
      }
    }
    return null;
  }

  PointItem? calculateCancelHintPoint(Point<double> curPoint) {
    final p = Point(cancelPoint.x, cancelPoint.y);
    if (p.distanceTo(curPoint) + 0.5 < widget.cancelIdentifySize) {
      return cancelPoint;
    }
    return null;
  }

  void addPointToResult(int? index) {
    widget.onHitPoint?.call();
    result.add(index);

    if (widget.hitItem != null) {
      setState(() {
        points[index!].isFirstSelected = true;
      });
      Future.delayed(Duration(milliseconds: widget.hitShowMilliseconds), () {
        setState(() {
          points[index!].isFirstSelected = false;
        });
      });
    }
  }

  // Calculate the triangle area using Heron's formula. When the area is 0, the three points are considered collinear.
  // If this point is in the middle of the collinear points, set it as selected and add it to the result.
  void handleLooseCase(PointItem pre, PointItem next) {
    List<int?> midItems = [];
    points.forEach((item) {
      if (item != pre && item != next && item.isSelected == false) {
        final itemDrawPoint = Point<double>(item.x, item.y);
        final preDrawPoint = Point<double>(pre.x, pre.y);
        final nextDrawPoint = Point<double>(next.x, next.y);
        double a = itemDrawPoint.distanceTo(preDrawPoint);
        double b = itemDrawPoint.distanceTo(nextDrawPoint);
        double c = preDrawPoint.distanceTo(nextDrawPoint);
        double p = (a + b + c) * 0.5;
        double area = p * (p - a) * (p - b) * (p - c);

        double halfDistance = c * 0.5;
        Point<double> mid = Point((pre.x + next.x) * 0.5, (pre.y + next.y) * 0.5);

        if (area - 0.5 <= 0 && itemDrawPoint.distanceTo(mid) < halfDistance) {
          item.isSelected = true;
          midItems.add(item.index);
        }
      }
    });

    if (next.index! > pre.index!) {
      midItems.sort((a, b) => a! - b!);
    } else {
      midItems.sort((a, b) => b! - a!);
    }

    midItems.forEach((index) {
      addPointToResult(index);
    });
  }

  // Calculate the angle between the line connecting two points and the x-axis, returns radians
  double calculateAngle(Point p1, Point p2) {
    return math.atan2((p2.y - p1.y), (p2.x - p1.x)); // radians
  }
}
