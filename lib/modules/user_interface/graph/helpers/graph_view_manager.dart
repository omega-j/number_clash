class GraphViewManager {
  double viewStart = 0;
  double viewEnd = 10;
  double viewRange = 10;

  void adjustView(double start, double end) {
    viewStart = start;
    viewEnd = end;
  }

  void zoomIn() {
    viewRange = (viewRange / 1.2).clamp(1, double.infinity);
    viewEnd = viewStart + viewRange;
  }

  void zoomOut() {
    viewRange = (viewRange * 1.2).clamp(1, double.infinity);
    viewEnd = viewStart + viewRange;
  }

  void scrollLeft() {
    viewStart -= viewRange / 2;
    viewEnd = viewStart + viewRange;
  }

  void scrollRight() {
    viewStart += viewRange / 2;
    viewEnd = viewStart + viewRange;
  }
}