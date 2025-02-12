class SudokuCell {
  final int? value;
  final bool isInitial;
  final bool isHint;
  final List<int> annotations;

  const SudokuCell({
    this.value,
    this.isInitial = false,
    this.isHint = false,
    this.annotations = const [],
  });

  SudokuCell copyWith({
    int? value,
    bool? isInitial,
    bool? isHint,
    List<int>? annotations,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      isInitial: isInitial ?? this.isInitial,
      isHint: isHint ?? this.isHint,
      annotations: annotations ?? this.annotations,
    );
  }
}
