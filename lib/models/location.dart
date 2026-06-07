class LocationLabel {
  static List<LocationLabel> locationSet = [
    LocationLabel(label: "中国", nationCode: "+86"),
    LocationLabel(label: "美国", nationCode: "+1"),
  ];

  final String label;
  final String nationCode;
  const LocationLabel({required this.label, required this.nationCode});

  @override
  int get hashCode => label.hashCode ^ nationCode.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationLabel &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          nationCode == other.nationCode;
}
